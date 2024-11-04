import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:ezbooking_admin/core/utils/image_helper.dart';
import 'package:ezbooking_admin/models/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

class EventPreview extends StatelessWidget {
  final Event event;
  final Function(Event) onEdit;
  final VoidCallback? onClose;

  const EventPreview({
    super.key,
    required this.event,
    required this.onEdit,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageGallery(context),
                    const SizedBox(height: 24),
                    _buildEventDetails(),
                    if (event.description.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildDescriptionSection(),
                    ],
                    if (event.additionalInfo != null) ...[
                      const SizedBox(height: 24),
                      _buildAdditionalInfoSection(),
                    ],
                    const SizedBox(height: 24),
                    _buildOrganizerSection(),
                    if (event.videoUrl != null) ...[
                      const SizedBox(height: 24),
                      _buildVideoSection(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, size: 24),
          const SizedBox(width: 8),
          const Text(
            'Event Preview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => onEdit(event),
            tooltip: 'Edit Event',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose ?? () => Navigator.of(context).pop(),
            tooltip: 'Close Preview',
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    List<String> images = event.imageUrls;
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: Breakpoints.isMobile(context) ? 200 : 400,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            enableInfiniteScroll: images.length > 1,
            autoPlay: images.length > 1,
          ),
          items: images.map((imageUrl) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ImageHelper.loadNetworkImage(
                imageUrl,
                fit: BoxFit.contain,
              ),
            );
          }).toList(),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Swipe or wait for auto-play to see all ${images.length} images',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventDetails() {
    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  event.eventType,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_today,
            title: 'Date & Time',
            content:
                DateFormat('EEEE, MMMM dd, yyyy • HH:mm').format(event.date),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.location_on,
            title: 'Location',
            content: event.location,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.attach_money,
            title: 'Ticket Price',
            content: currencyFormatter.format(event.ticketPrice),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.confirmation_number,
            title: 'Available Tickets',
            content: '${event.availableTickets} tickets',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            event.description,
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            event.additionalInfo!,
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizerSection() {
    if (event.organizer == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Organizer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.person_outline,
            title: 'Name',
            content: event.organizer?.name ?? "Undefined",
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.contact_mail,
            title: 'Contact',
            content: event.organizer?.phoneNumber ?? "Undefined",
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Address',
            content: event.organizer?.address ?? "Undefined",
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.web,
            title: 'Website',
            content: event.organizer?.website ?? "Undefined",
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.web,
            title: 'Facebook',
            content: event.organizer?.facebook ?? "Undefined",
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Video',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            if (event.videoUrl != null) {
              final url = Uri.parse(event.videoUrl!);
              if (kIsWeb) {
                html.window.open(event.videoUrl!, '_blank');
                return;
              }
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.play_circle_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Watch Event Video',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
