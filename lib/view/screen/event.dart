import 'package:ezbooking_admin/core/configs/app_colors.dart';
import 'package:ezbooking_admin/core/configs/break_points.dart';
import 'package:ezbooking_admin/core/utils/dialogs.dart';
import 'package:ezbooking_admin/models/event.dart';
import 'package:ezbooking_admin/providers/events/create_event_provider.dart';
import 'package:ezbooking_admin/providers/events/delete_event_provider.dart';
import 'package:ezbooking_admin/providers/events/fetch_events_provider.dart';
import 'package:ezbooking_admin/providers/events/update_event_provider.dart';
import 'package:ezbooking_admin/view/widgets/event_card.dart';
import 'package:ezbooking_admin/view/widgets/event_detail_preview.dart';
import 'package:ezbooking_admin/view/widgets/event_edit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventScreen extends StatefulWidget {
  EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late FetchEventsProvider fetchEventsProvider;
  late UpdateEventProvider updateEventProvider;
  late CreateEventProvider createEventProvider;
  late DeleteEventProvider deleteEventProvider;

  @override
  void initState() {
    super.initState();
    initProvider();
    // Fetch Data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchEventsProvider.fetchEvents();
    });
    // Add listener
    updateEventProvider.addListener(
      () {
        if (updateEventProvider.isSuccess) {
          fetchEventsProvider.updateEvents(
            updateEventProvider.event,
            ActionType.update,
          );
        }
      },
    );

    createEventProvider.addListener(
      () {
        if (createEventProvider.isSuccess) {
          fetchEventsProvider.updateEvents(
            createEventProvider.event,
            ActionType.create,
          );
        }
      },
    );

    deleteEventProvider.addListener(
      () {
        if (deleteEventProvider.isSuccess) {
          fetchEventsProvider.updateEvents(
            deleteEventProvider.event,
            ActionType.delete,
          );
        }
      },
    );
  }

  void initProvider() {
    // Init Provider
    fetchEventsProvider =
        Provider.of<FetchEventsProvider>(context, listen: false);

    updateEventProvider =
        Provider.of<UpdateEventProvider>(context, listen: false);

    createEventProvider =
        Provider.of<CreateEventProvider>(context, listen: false);

    deleteEventProvider =
        Provider.of<DeleteEventProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = Breakpoints.isDesktop(context);
    final bool isTablet = Breakpoints.isTablet(context);
    return Column(
      children: [
        const SizedBox(height: 10),
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
                    "Event/",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    showCreateEventDialog();
                  },
                  icon: Icon(Icons.add),
                  color: Colors.white70,
                )
              ],
            )),
        const SizedBox(height: 10),
        Expanded(
          child: Consumer<FetchEventsProvider>(
            builder: (context, value, child) {
              if (fetchEventsProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white70,
                  ),
                );
              }
              if (fetchEventsProvider.events.isNotEmpty &&
                  !fetchEventsProvider.isLoading) {
                return GridView.builder(
                  itemCount: fetchEventsProvider.events.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop
                          ? 3
                          : isTablet
                              ? 2
                              : 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2),
                  itemBuilder: (context, index) {
                    return EventCard(
                      event: fetchEventsProvider.events[index],
                      onView: () =>
                          showEventPreview(fetchEventsProvider.events[index]),
                      onEdit: () => showEditEventDialog(
                          fetchEventsProvider.events[index]),
                      onDelete: () {
                        DialogUtils.showConfirmationDialog(
                          context: context,
                          size: size,
                          title: "Are you sure you want to delete this event?",
                          textCancelButton: "Cancel",
                          textAcceptButton: "Delete",
                          acceptPressed: () {
                            deleteEventProvider
                                .deleteEvent(fetchEventsProvider.events[index]);
                          },
                        );
                      },
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        )
      ],
    );
  }

  void showEventPreview(Event event) {
    final isMobile = Breakpoints.isMobile(context);
    final size = MediaQuery.of(context).size;
    showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(
          height: size.height * 0.8,
          width: isMobile ? size.width : size.width * 0.65,
          child: Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: size.height * 0.8,
                width: isMobile ? size.width : size.width * 0.65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: EventPreview(
                    event: event,
                    onEdit: (event) => showEditEventDialog(event),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showEditEventDialog(Event event) {
    final size = MediaQuery.of(context).size;
    final isMobile = Breakpoints.isMobile(context);
    showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(
          height: size.height * 0.8,
          width: isMobile ? size.width : size.width * 0.65,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: size.height * 0.8,
                width: isMobile ? size.width : size.width * 0.65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: EditEvent(
                    actionType: ActionType.update,
                    onSave: (eventUpdate) {
                      updateEventProvider.updateEvent(eventUpdate);
                    },
                    event: event,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showCreateEventDialog() {
    final size = MediaQuery.of(context).size;
    final isMobile = Breakpoints.isMobile(context);
    showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(
          height: size.height * 0.8,
          width: isMobile ? size.width : size.width * 0.65,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: size.height * 0.8,
                width: isMobile ? size.width : size.width * 0.65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: EditEvent(
                    actionType: ActionType.create,
                    onSave: (event) {
                      createEventProvider.createEvent(event);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
