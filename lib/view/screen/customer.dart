import 'package:dio/dio.dart';
import 'package:ezbooking_admin/cloud_functions/functions.dart';
import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:ezbooking_admin/core/utils/dialogs.dart';
import 'package:ezbooking_admin/core/utils/encryption_helper.dart';
import 'package:ezbooking_admin/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  UserModel? _selectedUser;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _showUserForm({UserModel? user}) {
    _selectedUser = user;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _fullNameController.text = user.fullName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _birthdayController.text = user.birthday ?? '';
      _selectedGender = user.gender;
    } else {
      _emailController.clear();
      _fullNameController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _birthdayController.clear();
      _selectedGender = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(user == null ? 'Add User' : 'Edit User'),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    enabled: user == null,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter an email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_selectedUser == null)
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) =>
                          _selectedUser == null && (value?.isEmpty ?? true)
                              ? 'Please enter a password'
                              : null,
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthdayController,
                    decoration: const InputDecoration(
                      labelText: 'Birthday',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) => _selectedGender = value,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveUser,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.primaryColor),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      DialogUtils.showLoadingDialog(context);
      try {
        final user = UserModel(
          id: _selectedUser?.id,
          email: _emailController.text,
          fullName: _fullNameController.text,
          password: _selectedUser == null ? _passwordController.text : _selectedUser?.password,
          phoneNumber: _phoneController.text,
          gender: _selectedGender,
          avatarUrl: _selectedUser?.avatarUrl,
          birthday: _birthdayController.text,
          createdAt: _selectedUser?.createdAt ?? Timestamp.now(),
          isDelete: false,
        );

        if (_selectedUser == null) {
          try {
            // Check if the email already exists in FirebaseAuth
            final authResult = await FirebaseAuth.instance
                .fetchSignInMethodsForEmail(_emailController.text);

            if (authResult.isNotEmpty) {
              // Show error if email exists
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email already in use.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return; // Stop the process if the email exists
            }

            // Create the user in FirebaseAuth
            final authUser =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );

            // Now, create the user in Firestore
            final user = UserModel(
              id: authUser.user!.uid,
              // Use the UID from FirebaseAuth
              email: _emailController.text,
              fullName: _fullNameController.text,
              password: _passwordController.text,
              // Note: In practice, avoid storing passwords
              phoneNumber: _phoneController.text,
              gender: _selectedGender,
              birthday: _birthdayController.text,
              createdAt: Timestamp.now(),
              avatarUrl: "",
              isDelete: false,
            );

            await FirebaseFirestore.instance
                .collection('users')
                .doc(authUser.user!.uid)
                .set(user.toJson());
            // Send password to email
            await sendCode(user.email ?? "", user.password ?? "");
            // Close dialog
            Navigator.pop(context);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primaryColor,
                  content: const Text(
                    'User added successfully',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),
              );
            }
            return;
          } catch (e) {
            if (e is FirebaseAuthException) {
              String errorMessage = 'An unknown error occurred.';

              // Check for specific FirebaseAuth error codes
              switch (e.code) {
                case 'email-already-in-use':
                  errorMessage =
                      'The email address is already in use by another account.';
                  break;
                case 'invalid-email':
                  errorMessage = 'The email address is invalid.';
                  break;
                case 'weak-password':
                  errorMessage = 'The password is too weak.';
                  break;
                case 'operation-not-allowed':
                  errorMessage =
                      'The operation is not allowed. Please enable email/password authentication in Firebase.';
                  break;
                case 'network-request-failed':
                  errorMessage = 'Network error. Please try again later.';
                  break;
                default:
                  errorMessage = e.message ?? errorMessage;
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
            } else {
              // Handle other exceptions
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        } else {
          var snapshot = await _firestore
              .collection('users')
              .where('phoneNumber', isEqualTo: user.phoneNumber)
              .get();

          if (snapshot.docs.isNotEmpty && snapshot.docs[0].id != user.id) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: Phone number is already in use.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Proceed to update the user if phone number is unique

          await _firestore
              .collection('users')
              .doc(user.id)
              .update(user.toJson());
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryColor,
              content: Text(
                _selectedUser == null
                    ? 'User added successfully'
                    : 'User updated successfully',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 64,
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            color: Colors.black26,
            child: Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Customers/",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    _showUserForm();
                  },
                  icon: const Icon(Icons.add),
                  color: Colors.white70,
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where("isDelete", isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data?.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return UserModel.fromJson({...data, 'id': doc.id});
                    }).toList() ??
                    [];

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: Breakpoints.isDesktop(context)
                        ? size.width * 0.7
                        : size.width * 3,
                    child: DataTable(
                      headingTextStyle: const TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold),
                      dataTextStyle: const TextStyle(color: Colors.white70),
                      columns: const [
                        DataColumn(label: Text('Full Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Gender')),
                        DataColumn(label: Text('Birthday')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: users.map((user) {
                        String dob = "-";
                        if (user.birthday != "" || user.birthday != null) {
                          RegExp regex = RegExp(
                              r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$');
                          if (regex.hasMatch(user.birthday!)) {
                            dob = DateFormat("yyyy-MM-dd")
                                .format(DateTime.parse(user.birthday!));
                          }
                        }
                        return DataRow(
                          cells: [
                            DataCell(Text(user.fullName ?? '-')),
                            DataCell(Text(user.email ?? '-')),
                            DataCell(Text(user.phoneNumber ?? "-")),
                            DataCell(Text(user.gender ?? '-')),
                            DataCell(
                              Text(dob),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () => _showUserForm(user: user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete User'),
                                        content: Text(
                                            'Are you sure you want to delete ${user.fullName}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              DialogUtils.showLoadingDialog(
                                                  context);
                                              try {
                                                await FirebaseCloudFunctions
                                                    .instance
                                                    .deleteUser(user.id ?? "");
                                              } on Exception catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content:
                                                          Text(e.toString()),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }

                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                            ),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
