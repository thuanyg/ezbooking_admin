import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:email_otp/email_otp.dart';
import 'package:ezbooking_admin/core/utils/app_utils.dart';
import 'package:ezbooking_admin/core/utils/encryption_helper.dart';
import 'package:ezbooking_admin/models/organizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class OrganizerProvider with ChangeNotifier {
  final CollectionReference _organizerCollection =
      FirebaseFirestore.instance.collection('organizers');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Organizer> _organizers = [];
  bool _isLoading = false;

  List<Organizer> get organizers => _organizers;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch organizers
  Future<void> fetchOrganizers() async {
    _setLoading(true);
    try {
      final querySnapshot = await _organizerCollection.get();
      _organizers = querySnapshot.docs
          .map((doc) => Organizer.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching organizers: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateOrganizer(String id, Organizer organizer) async {
    // Validate required fields
    if (organizer.name == null || organizer.name!.isEmpty) {
      throw Exception("Organizer name is required");
    }
    if (organizer.email == null || organizer.email!.isEmpty) {
      throw Exception("Organizer email is required");
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(organizer.email!)) {
      throw Exception("Invalid email format");
    }

    _setLoading(true);
    try {
      await _organizerCollection.doc(id).update(organizer.toJson());
      await fetchOrganizers(); // Refresh list
    } catch (e) {
      print("Error updating organizer: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Register organizer with email and password
  Future<void> registerOrganizer(Organizer organizer) async {
    if (organizer.email == null || organizer.email!.isEmpty) {
      throw Exception("Organizer email is required");
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(organizer.email!)) {
      throw Exception("Invalid email format");
    }

    _setLoading(true);
    try {
      // Check if an organizer with the same email already exists
      final existingOrganizerQuery = await _organizerCollection
          .where('email', isEqualTo: organizer.email)
          .limit(1)
          .get();

      if (existingOrganizerQuery.docs.isNotEmpty) {
        // Notify the user that the organizer already exists
        print("Organizer with this email already exists");
        throw Exception("An organizer with this email already exists");
      }

      // Generate a random password
      String password = generateRandomString(8);
      organizer.passwordHash =
          EncryptionHelper.encryptData(password, EncryptionHelper.secretKey);
      // Add the organizer document to Firestore
      await _organizerCollection.doc(organizer.id).set({
        ...organizer.toJson(),
        'id': organizer.id,
      });

      // Send the generated password to the organizer's email
      bool isSent = await sendCode(organizer.email!, password);
      if (!isSent) {
        throw Exception("Failed to send email with the password");
      }

      // Fetch the updated list of organizers
      await fetchOrganizers();
    } catch (e) {
      print("Error registering organizer: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Login organizer
  Future<User?> loginOrganizer(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email and password are required");
    }

    _setLoading(true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error logging in organizer: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete organizer
  Future<void> deleteOrganizer(String id) async {
    _setLoading(true);
    try {
      // Delete from Firestore
      await _organizerCollection.doc(id).delete();

      // Delete user from Firebase Authentication
      User? user = _auth.currentUser;
      if (user?.uid == id) {
        await user?.delete();
      }

      _organizers.removeWhere((organizer) => organizer.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting organizer: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendCode(String email, String otp) async {
    try {
      Dio dio = Dio();

      String url = 'https://htthuan.id.vn/ezbooking/sendMail.php/sendEmail.php';

      // Make the GET request with email and OTP as query parameters
      final response = await dio.get(url, queryParameters: {
        'email': email,
        'otp': otp,
      });

      // Handle the response based on the status
      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'success') {
          print('Email sent successfully');
          return true; // Successfully sent the email
        } else {
          print('Error: ${data['message']}');
          return false; // Failure case
        }
      } else {
        print('Failed to send request: ${response.statusCode}');
        return false; // HTTP error
      }
    } catch (e) {
      // Handle errors such as network issues
      print('Error: $e');
      return false;
    }
  }
}
