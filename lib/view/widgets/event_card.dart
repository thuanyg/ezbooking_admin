import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:ezbooking_admin/core/utils/image_helper.dart';
import 'package:ezbooking_admin/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onView;

  const EventCard({
    super.key,
    required this.event,
    this.onEdit,
    this.onDelete,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final bool isDesktop = Breakpoints.isDesktop(context);
    final bool isMobile = Breakpoints.isMobile(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          print(event.poster);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main Event Image (Thumbnail or first image)
                  !isMobile
                      ? ImageHelper.loadNetworkImage(
                          event.poster ?? "",
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          radius: BorderRadius.circular(8),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 16),

                  // Event Details
                  Expanded(
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
                                  fontSize: 15,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildEventTypeChip(event.eventType),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Event basic info
                        _buildInfoRow(
                            Icons.calendar_today,
                            DateFormat('EEEE, MMM dd, yyyy • HH:mm')
                                .format(event.date.toUtc().add(Duration(hours: 7)))),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.location_on, event.location),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.confirmation_number,
                            '${event.availableTickets} tickets available'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.attach_money,
                            currencyFormatter.format(event.ticketPrice)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(
                      Icons.visibility,
                      color: Colors.white70,
                    ),
                    label: const Text(
                      'View',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onPressed: onView,
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white70,
                    ),
                    label: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white70,
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              // Description (collapsed)
              if (event.description.isNotEmpty) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 3.sp, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
