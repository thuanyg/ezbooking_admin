import 'package:cloud_functions/cloud_functions.dart';

class Functions {
  static Future<void> deleteUserById(String userId) async {
    try {
      final FirebaseFunctions functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');
      final HttpsCallable callable = functions.httpsCallable('deleteUserById');


      final response = await callable.call({'userId': "1def1e122e12fffw3"});

      print('User deleted successfully: ${response.data['message']}');
    } catch (e) {
      rethrow;
    }
  }
}
