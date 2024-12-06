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