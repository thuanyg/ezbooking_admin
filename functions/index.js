const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall } = require("firebase-functions/v2/https");
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const admin = require("firebase-admin");
admin.initializeApp();
const bucket = admin.storage().bucket();

exports.uploadAvatar = onCall(async (data, context) => {

  try {
    // Lấy dữ liệu từ client
    const { base64Image, mimeType } = data;
    if (!base64Image || !mimeType) {
      throw new Error("Invalid image data.");
    }

    // Tạo tên file ngẫu nhiên
    const fileName = `images/avatars/${uuidv4()}`;
    const file = bucket.file(fileName);

    // Giải mã ảnh từ base64
    const buffer = Buffer.from(base64Image, "base64");

    // Tải file lên Firebase Storage
    await file.save(buffer, {
      metadata: { contentType: mimeType },
    });

    // Lấy URL tải xuống
    const downloadUrl = await file.getSignedUrl({
      action: "read",
      expires: "03-01-2500", // Thời gian hết hạn
    });

    return { downloadUrl: downloadUrl[0] };
  } catch (error) {
    console.error("Error uploading avatar:", error);
    throw new Error("Failed to upload avatar.");
  }
});
exports.deleteUser = onCall(async (request) => {
  const { userId } = request.data;

  if (!userId) {
    throw new Error("User ID is required");
  }

  try {
    await admin.auth().deleteUser(userId);;

    console.log(`User with UID ${userId} deleted in Authentication`);

    await admin.firestore().collection("users").doc(userId).update({
      isDelete: true,
      "phoneNumber": "",
      "email": "",
    });

    console.log(`User with UID ${userId} marked as disabled in Firestore`);

    return { message: `User with UID ${userId} deleted successfully` };
  } catch (error) {
    console.error(`Error deleting user with UID ${userId}:`, error);
    throw new Error(error.message);
  }
});

exports.sendNotificationWhenOrderUpdate = onDocumentUpdated('orders/{docId}', async (event) => {
  const orderId = event.params.docId;

  const orderSnapshot = await admin.firestore().collection('orders').doc(orderId).get();

  if (!orderSnapshot.exists) {
    console.log(`Orders with ID ${orderId} does not exist.`);
    return;
  }


  const orderData = orderSnapshot.data();

  console.log(orderData);


  if (orderData["status"] == "success") {
    const eventID = orderData["eventID"];

    const eventSnapshot = await admin.firestore().collection('events').doc(eventID).get();

    if (!eventSnapshot.exists) {
      console.log(`Event with ID ${eventID} does not exist.`);
      return;
    }
    const eventData = eventSnapshot.data();
    console.log(eventData);
    const organizerID = eventData["organizer"];

    const organizerSnapshot = await admin.firestore().collection('organizers').doc(organizerID).get();

    if (!organizerSnapshot.exists) {
      console.log(`Organizer with ID ${organizerID} does not exist.`);
      return;
    }

    const organizerData = organizerSnapshot.data();

    if (organizerData["fcmToken"]) {

      const tokens = [];
      tokens.push(organizerData.fcmToken);

      const payload = {
        notification: {
          title: `New order of ${organizerData["name"]}`,
          body: `Your event ${eventData["name"]} ....`,
        },
        data: {
          eventID: eventID,
        },

      };

      const response = await admin.messaging().sendEachForMulticast({
        tokens: tokens,
        notification: payload.notification,
        data: payload.data,
      });
      console.log(`Order: ${orderId}\n Event: ${eventData["name"]}`);
      console.log(`${response.successCount} messages were sent successfully.`);
      console.log(`${response.failureCount} messages failed.`);
    }
  }
});


exports.scheduleUpdateTicketStatus = onSchedule(
  {
    schedule: "0 0 * * *", // Cron job runs every day at 10 AM (adjust as needed)
    timeZone: "Asia/Ho_Chi_Minh",
  },
  async (event) => {
    try {
      const now = new Date().toLocaleString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" });
      console.log(`Đang update ticket lúc ${now}`);

      // Fetch all tickets
      const ticketsSnapshot = await admin.firestore().collection('tickets').get();

      // Loop through each ticket
      for (const ticketDoc of ticketsSnapshot.docs) {
        const ticket = ticketDoc.data();
        const eventID = ticket.eventID;

        // Fetch the event related to the ticket using the eventID
        const eventSnapshot = await admin.firestore().collection('events').doc(eventID).get();
        const event = eventSnapshot.data();

        if (event) {
          const eventDate = event.date.toDate(); // Assuming 'date' is a Firestore Timestamp field
          const currentTime = new Date();

          // Check if the event has passed and update ticket status
          if (eventDate < currentTime) {
            // Update ticket status to 'Expired'
            await admin.firestore().collection('tickets').doc(ticketDoc.id).update({
              status: 'Expired', // Or any status you prefer
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            console.log(`Ticket ID ${ticketDoc.id} status updated to 'Expired'`);
          }
        } else {
          console.log(`Event with ID ${eventID} not found for ticket ${ticketDoc.id}`);
        }
      }
    } catch (error) {
      console.error("Lỗi khi cập nhật status tickets:", error);
    }
  }
);
