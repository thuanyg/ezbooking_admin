import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/core/utils/app_utils.dart';
import 'package:ezbooking_admin/core/utils/dialogs.dart';
import 'package:ezbooking_admin/core/utils/encryption_helper.dart';
import 'package:ezbooking_admin/models/organizer.dart';
import 'package:ezbooking_admin/providers/organizers/organizer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

class OrganizerManagement extends StatefulWidget {
  const OrganizerManagement({Key? key}) : super(key: key);

  @override
  _OrganizerManagementScreenState createState() =>
      _OrganizerManagementScreenState();
}

class _OrganizerManagementScreenState extends State<OrganizerManagement> {
  final TextEditingController _searchController = TextEditingController();
  List<Organizer> _filteredOrganizers = [];
  late OrganizerProvider organizerProvider;

  @override
  void initState() {
    super.initState();
    organizerProvider = Provider.of<OrganizerProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      organizerProvider.fetchOrganizers();
    });
  }

  void _filterOrganizers(String query) {
    final organizerProvider =
        Provider.of<OrganizerProvider>(context, listen: false);
    setState(() {
      _filteredOrganizers = organizerProvider.organizers
          .where((organizer) =>
              (organizer.name?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (organizer.email?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();
    });
  }

  void _showOrganizerDialog({Organizer? organizer}) {
    final nameController = TextEditingController(text: organizer?.name ?? '');
    final emailController = TextEditingController(text: organizer?.email ?? '');
    final phoneController =
        TextEditingController(text: organizer?.phoneNumber ?? '');
    final addressController =
        TextEditingController(text: organizer?.address ?? '');
    final facebookController =
        TextEditingController(text: organizer?.facebook ?? '');
    final websiteController =
        TextEditingController(text: organizer?.website ?? '');

    bool enable = organizer == null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(organizer == null ? 'Add New Organizer' : 'Edit Organizer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Name', Icons.person, true),
                const SizedBox(height: 10),
                _buildTextField(emailController, 'Email', Icons.email, enable),
                const SizedBox(height: 10),
                _buildTextField(
                    phoneController, 'Phone Number', Icons.phone, true),
                const SizedBox(height: 10),
                _buildTextField(
                    addressController, 'Address', Icons.location_on, true),
                const SizedBox(height: 10),
                _buildTextField(
                    facebookController, 'Facebook', Icons.facebook, true),
                const SizedBox(height: 10),
                _buildTextField(websiteController, 'Website', Icons.web, true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  DialogUtils.showLoadingDialog(context);
                  final newOrganizer = Organizer(
                    id: organizer?.id ?? const Uuid().v1(),
                    name: nameController.text,
                    email: emailController.text,
                    phoneNumber: phoneController.text,
                    address: addressController.text,
                    facebook: facebookController.text,
                    website: websiteController.text,
                  );

                  if (organizer == null) {
                    await organizerProvider.registerOrganizer(newOrganizer);
                  } else {
                    await organizerProvider.updateOrganizer(
                      organizer.id!,
                      newOrganizer,
                    );
                  }

                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')));
                } finally {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
              child: Text(organizer == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool enable,
  ) {
    return TextField(
      controller: controller,
      enabled: enable,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              color: Colors.black26,
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Organizer/",
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
                      _showOrganizerDialog();
                    },
                    icon: const Icon(Icons.add),
                    color: Colors.white70,
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Organizer List
            Expanded(
              child: Consumer<OrganizerProvider>(
                builder: (context, organizerProvider, child) {
                  if (organizerProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final displayOrganizers = _searchController.text.isEmpty
                      ? organizerProvider.organizers
                      : _filteredOrganizers;

                  return ResponsiveGridView.builder(
                    gridDelegate: const ResponsiveGridDelegate(
                      crossAxisExtent: 280,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: displayOrganizers.length,
                    itemBuilder: (context, index) {
                      final organizer = displayOrganizers[index];
                      return _OrganizerCard(
                        organizer: organizer,
                        onEdit: () =>
                            _showOrganizerDialog(organizer: organizer),
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: Text(
                                  'Are you sure you want to delete ${organizer.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () async {
                                    await organizerProvider
                                        .deleteOrganizer(organizer.id!);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizerCard extends StatelessWidget {
  final Organizer organizer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OrganizerCard(
      {required this.organizer, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.drawerColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: organizer.avatarUrl != null
                  ? CachedNetworkImageProvider(organizer.avatarUrl!)
                  : null,
              child: organizer.avatarUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              organizer.name ?? 'Unnamed Organizer',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              organizer.email ?? 'No email',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
