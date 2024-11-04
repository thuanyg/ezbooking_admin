import 'dart:math';

import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/models/event.dart';
import 'package:ezbooking_admin/models/organizer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ActionType {create, update, read, delete}

class EditEvent extends StatefulWidget {
  final Event? event;
  final Function(Event) onSave;
  final ActionType actionType;

  const EditEvent({super.key, this.event, required this.onSave, required this.actionType});

  @override
  _EditEventState createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController eventTypeController;
  late TextEditingController descriptionController;
  late TextEditingController ticketPriceController;
  late TextEditingController availableTicketsController;
  late TextEditingController thumbnailController;
  late TextEditingController posterController;
  late TextEditingController videoUrlController;
  late TextEditingController additionalInfoController;
  late DateTime selectedDate;

  // Organizer controllers
  late TextEditingController organizerNameController;
  late TextEditingController organizerEmailController;
  late TextEditingController organizerPhoneController;
  late TextEditingController organizerAddressController;
  late TextEditingController organizerFacebookController;
  late TextEditingController organizerYoutubeController;
  late TextEditingController organizerWebsiteController;

  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    final event = widget.event;

    // Initialize controllers with existing event data or empty strings
    nameController = TextEditingController(text: event?.name ?? '');
    locationController = TextEditingController(text: event?.location ?? '');
    eventTypeController = TextEditingController(text: event?.eventType ?? '');
    descriptionController =
        TextEditingController(text: event?.description ?? '');
    ticketPriceController =
        TextEditingController(text: event?.ticketPrice.toString() ?? '0.0');
    availableTicketsController =
        TextEditingController(text: event?.availableTickets.toString() ?? '0');
    thumbnailController = TextEditingController(text: event?.thumbnail ?? '');
    posterController = TextEditingController(text: event?.poster ?? '');
    videoUrlController = TextEditingController(text: event?.videoUrl ?? '');
    additionalInfoController =
        TextEditingController(text: event?.additionalInfo ?? '');

    // Organizer controllers
    organizerNameController =
        TextEditingController(text: event?.organizer?.name ?? '');
    organizerEmailController =
        TextEditingController(text: event?.organizer?.email ?? '');
    organizerPhoneController =
        TextEditingController(text: event?.organizer?.phoneNumber ?? '');
    organizerAddressController =
        TextEditingController(text: event?.organizer?.address ?? '');
    organizerFacebookController =
        TextEditingController(text: event?.organizer?.facebook ?? '');
    organizerYoutubeController =
        TextEditingController(text: event?.organizer?.youtube ?? '');
    organizerWebsiteController =
        TextEditingController(text: event?.organizer?.website ?? '');

    selectedDate = event?.date ?? DateTime.now();
    imageUrls = event?.imageUrls ?? [];
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    eventTypeController.dispose();
    descriptionController.dispose();
    ticketPriceController.dispose();
    availableTicketsController.dispose();
    thumbnailController.dispose();
    posterController.dispose();
    videoUrlController.dispose();
    additionalInfoController.dispose();
    organizerNameController.dispose();
    organizerEmailController.dispose();
    organizerPhoneController.dispose();
    organizerAddressController.dispose();
    organizerFacebookController.dispose();
    organizerYoutubeController.dispose();
    organizerWebsiteController.dispose();
    super.dispose();
  }

  void _handleSave() {

    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    
    if (_formKey.currentState!.validate()) {
      final event = Event(
        id: widget.event?.id ?? getRandomString(6),
        name: nameController.text,
        location: locationController.text,
        eventType: eventTypeController.text,
        description: descriptionController.text,
        date: selectedDate,
        ticketPrice: double.parse(ticketPriceController.text),
        availableTickets: int.parse(availableTicketsController.text),
        thumbnail:
            thumbnailController.text.isEmpty ? null : thumbnailController.text,
        poster: posterController.text.isEmpty ? null : posterController.text,
        imageUrls: imageUrls,
        videoUrl:
            videoUrlController.text.isEmpty ? null : videoUrlController.text,
        additionalInfo: additionalInfoController.text.isEmpty
            ? null
            : additionalInfoController.text,
        organizer: Organizer(
          name: organizerNameController.text,
          email: organizerEmailController.text,
          phoneNumber: organizerPhoneController.text,
          address: organizerAddressController.text,
          facebook: organizerFacebookController.text,
          youtube: organizerYoutubeController.text,
          website: organizerWebsiteController.text,
        ),
      );

      widget.onSave(event);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    widget.event == null ? 'Create Event' : 'Edit Event',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Event Details Section
              _buildSectionTitle('Event Details'),
              _buildTextFormField(
                controller: nameController,
                label: 'Event Name',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter event name' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: locationController,
                      label: 'Location',
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter location'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: eventTypeController,
                      label: 'Event Type',
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter event type'
                          : null,
                    ),
                  ),
                ],
              ),

              // Date and Tickets Section
              _buildDatePicker(),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: ticketPriceController,
                      label: 'Ticket Price',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return 'Please enter ticket price';
                        if (double.tryParse(value!) == null)
                          return 'Invalid price';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: availableTicketsController,
                      label: 'Available Tickets',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return 'Please enter available tickets';
                        if (int.tryParse(value!) == null)
                          return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              _buildTextFormField(
                controller: descriptionController,
                label: 'Description',
                maxLines: 5,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),

              // Media Section
              _buildSectionTitle('Media'),
              _buildTextFormField(
                controller: thumbnailController,
                label: 'Thumbnail URL',
              ),
              _buildTextFormField(
                controller: posterController,
                label: 'Poster URL',
              ),
              _buildTextFormField(
                controller: videoUrlController,
                label: 'Video URL',
              ),

              // Image URLs Section
              _buildImageUrlsList(),

              // Organizer Section
              _buildSectionTitle('Organizer Information'),
              _buildTextFormField(
                controller: organizerNameController,
                label: 'Organizer Name',
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: organizerEmailController,
                      label: 'Email',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: organizerPhoneController,
                      label: 'Phone',
                    ),
                  ),
                ],
              ),
              _buildTextFormField(
                controller: organizerAddressController,
                label: 'Address',
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: organizerFacebookController,
                      label: 'Facebook',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: organizerYoutubeController,
                      label: 'YouTube',
                    ),
                  ),
                ],
              ),
              _buildTextFormField(
                controller: organizerWebsiteController,
                label: 'Website',
              ),

              // Additional Information
              _buildSectionTitle('Additional Information'),
              _buildTextFormField(
                controller: additionalInfoController,
                label: 'Additional Info',
                maxLines: 3,
              ),

              // Action Buttons
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(AppColors.primaryColor)),
                      onPressed: _handleSave,
                      child: Text(
                        widget.actionType == ActionType.update ? 'Save' : "Add New",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDate)}',
              maxLines: 1,
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                currentDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(selectedDate),
                );
                if (time != null) {
                  setState(() {
                    selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            },
            child: Text(
              'Select',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUrlsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Image URLs'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...imageUrls.map((url) => Chip(
                  color: const WidgetStatePropertyAll(Colors.grey),
                  label: Text(
                    url,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onDeleted: () {
                    setState(() {
                      imageUrls.remove(url);
                    });
                  },
                )),
            ActionChip(
              color: const WidgetStatePropertyAll(Colors.white),
              label: const Text('Add Image URL'),
              onPressed: () async {
                final controller = TextEditingController();
                final result = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Image URL'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(controller.text),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
                if (result != null && result.isNotEmpty) {
                  setState(() {
                    imageUrls.add(result);
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
