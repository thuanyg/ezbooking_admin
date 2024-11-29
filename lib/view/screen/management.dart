import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:ezbooking_admin/core/utils/dialogs.dart';
import 'package:ezbooking_admin/models/category.dart';
import 'package:ezbooking_admin/models/user.dart';
import 'package:ezbooking_admin/providers/categories/category_provider.dart';
import 'package:ezbooking_admin/view/screen/categories_management.dart';
import 'package:ezbooking_admin/view/screen/customer.dart';
import 'package:ezbooking_admin/view/screen/dashboard.dart';
import 'package:ezbooking_admin/view/screen/organizer_management.dart';
import 'package:ezbooking_admin/view/widgets/create_category_dialog.dart';
import 'package:ezbooking_admin/view/widgets/side_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum ScreenType { init, user, organizer, category, revenue }

class Management extends StatefulWidget {
  final GlobalKey<SidebarState> sideBarKey;

  const Management({super.key, required this.sideBarKey});

  @override
  State<Management> createState() => _ManagementState();
}

class _ManagementState extends State<Management> {
  ValueNotifier<ScreenType> screenType = ValueNotifier(ScreenType.init);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Breakpoints.isDesktop(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ValueListenableBuilder(
        valueListenable: screenType,
        builder: (context, value, child) {
          if (value == ScreenType.init) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Management',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: isDesktop ? 16 / 6 : 0.7,
                    children: [
                      _buildFeatureCard(
                        title: 'User Management',
                        description:
                            'Add, edit, delete users and manage permissions',
                        icon: Icons.people,
                        color: Colors.blue,
                        onTap: () {
                          screenType.value = ScreenType.user;
                        },
                      ),
                      _buildFeatureCard(
                        title: 'Category Management',
                        description:
                            'Manage event categories and subcategories',
                        icon: Icons.category,
                        color: Colors.green,
                        onTap: () {
                          screenType.value = ScreenType.category;
                        },
                      ),
                      _buildFeatureCard(
                        title: 'Event Organizer Management',
                        description: 'Review and approve event organizers',
                        icon: Icons.business,
                        color: Colors.orange,
                        onTap: () {
                          screenType.value = ScreenType.organizer;
                        },
                      ),
                      _buildFeatureCard(
                        title: 'Revenue Analytics',
                        description: 'Track system revenue and ticket sales',
                        icon: Icons.analytics,
                        color: Colors.purple,
                        onTap: () {
                          screenType.value = ScreenType.revenue;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildQuickActions(),
              ],
            );
          }
          if (value == ScreenType.user) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () => screenType.value = ScreenType.init,
                      child: Text(
                        'Admin Management',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 16,
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    ),
                    Text(
                      'Customers',
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Expanded(
                  child: CustomerScreen(),
                ),
                const SizedBox(height: 24),
                _buildQuickActions(),
              ],
            );
          }
          if (value == ScreenType.category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () => screenType.value = ScreenType.init,
                      child: Text(
                        'Admin Management',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 16,
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    ),
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Expanded(
                  child: CategoriesManagement(),
                ),
                const SizedBox(height: 24),
                _buildQuickActions(),
              ],
            );
          }
          if (value == ScreenType.organizer) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () => screenType.value = ScreenType.init,
                      child: Text(
                        'Admin Management',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 16,
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    ),
                    Text(
                      'Organizers',
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Expanded(
                  child: OrganizerManagement(),
                ),
                const SizedBox(height: 24),
                _buildQuickActions(),
              ],
            );
          }

          if (value == ScreenType.revenue) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () => screenType.value = ScreenType.init,
                      child: Text(
                        'Admin Management',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 16,
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    ),
                    Text(
                      'Revenues',
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Expanded(
                  child: DashboardScreen(),
                ),
                const SizedBox(height: 24),
                _buildQuickActions(),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Management',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: isDesktop ? 16 / 6 : 0.7,
                  children: [
                    _buildFeatureCard(
                        title: 'User Management',
                        description:
                            'Add, edit, delete users and manage permissions',
                        icon: Icons.people,
                        color: Colors.blue,
                        onTap: () {
                          screenType.value = ScreenType.user;
                        },
                        hasDesc: isDesktop),
                    _buildFeatureCard(
                      title: 'Category Management',
                      description: 'Manage event categories and subcategories',
                      icon: Icons.category,
                      color: Colors.green,
                      onTap: () {
                        screenType.value = ScreenType.category;
                      },
                      hasDesc: isDesktop,
                    ),
                    _buildFeatureCard(
                        title: 'Event Organizer Management',
                        description: 'Review and approve event organizers',
                        icon: Icons.business,
                        color: Colors.orange,
                        onTap: () {
                          screenType.value = ScreenType.organizer;
                        },
                        hasDesc: isDesktop),
                    _buildFeatureCard(
                      title: 'Revenue Analytics',
                      description: 'Track system revenue and ticket sales',
                      icon: Icons.analytics,
                      color: Colors.purple,
                      onTap: () {
                        screenType.value = ScreenType.revenue;
                      },
                      hasDesc: isDesktop,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildQuickActions(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      color: AppColors.drawerColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildActionButton(
                  label: 'Add User',
                  icon: Icons.person_add,
                  onTap: () {
                    // Handle add user
                    handleAddUser();
                  },
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  label: 'New Category',
                  icon: Icons.add_box,
                  onTap: () {
                    // Handle add category
                    handleAddCategory();
                  },
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  label: 'View Reports',
                  icon: Icons.bar_chart,
                  onTap: () {
                    // Handle view reports
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF1E88E5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void handleAddUser() {
    final _formKey = GlobalKey<FormState>();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _fullNameController = TextEditingController();
    TextEditingController _phoneController = TextEditingController();
    TextEditingController _birthdayController = TextEditingController();
    String? _selectedGender;

    DateTime? _selectedDate;

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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add User'),
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
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => (value?.isEmpty ?? true)
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
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
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

                  // Check if the phone number already exists in Firestore
                  final phoneQuery = await FirebaseFirestore.instance
                      .collection('users')
                      .where('phoneNumber', isEqualTo: _phoneController.text)
                      .get();

                  if (phoneQuery.docs.isNotEmpty) {
                    // Show error if phone number exists
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Phone number already in use.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return; // Stop the process if the phone number exists
                  }

                  // Create the user in FirebaseAuth
                  final authUser = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
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
                  );

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(authUser.user!.uid)
                      .set(user.toJson());

                  if (mounted) {
                    Navigator.pop(context);
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
                } catch (e) {
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
            },
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

  void handleAddCategory() {
    showDialog(
      context: context,
      builder: (contextDialog) {
        return CreateCategoryDialog(
          onCreate: (categoryName) async{
            // Handle category creation logic here
            final category = Category(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              categoryName: categoryName,
              createdAt: DateTime.now(),
            );
            final categoryProvider =
                Provider.of<CategoryProvider>(context, listen: false);
            categoryProvider.addCategory(context, category);
          },
        );
      },
    );
  }
}

Widget _buildFeatureCard({
  required String title,
  required String description,
  required IconData icon,
  required Color color,
  bool hasDesc = true,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 2,
    color: AppColors.drawerColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            if (hasDesc)
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    ),
  );
}
