import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Card widget for displaying an event in a list.
class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final eventsProvider = context.read<EventsProvider>();
    final currentUser = userProvider.currentUser;
    final isJoined = currentUser != null &&
        event.participantIds.contains(currentUser.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(event.categoryIcon, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    event.categoryLabel,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _StatusBadge(event: event),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date and location
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, h:mm a').format(event.eventDate),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Participants progress
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${event.participantIds.length} / ${event.maxParticipants} joined',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                                if (!event.hasMinimumParticipants)
                                  Text(
                                    'Need ${AppConstants.eventMinParticipants - event.participantIds.length} more',
                                    style: const TextStyle(
                                      color: AppColors.warning,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: event.participantIds.length /
                                    event.maxParticipants,
                                backgroundColor:
                                    AppColors.divider,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  event.isFull
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (currentUser != null &&
                          event.status == EventStatus.upcoming)
                        _JoinButton(
                          event: event,
                          isJoined: isJoined,
                          userId: currentUser.id,
                          eventsProvider: eventsProvider,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final EventModel event;
  const _StatusBadge({required this.event});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (event.status) {
      case EventStatus.upcoming:
        color = AppColors.success;
        label = 'Upcoming';
        break;
      case EventStatus.ongoing:
        color = AppColors.info;
        label = 'Ongoing';
        break;
      case EventStatus.cancelled:
        color = AppColors.error;
        label = 'Cancelled';
        break;
      case EventStatus.completed:
        color = AppColors.textSecondary;
        label = 'Done';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  final EventModel event;
  final bool isJoined;
  final String userId;
  final EventsProvider eventsProvider;

  const _JoinButton({
    required this.event,
    required this.isJoined,
    required this.userId,
    required this.eventsProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (event.isFull && !isJoined) {
      return const Text(
        'Full',
        style: TextStyle(color: AppColors.error, fontSize: 12),
      );
    }
    return ElevatedButton(
      onPressed: () {
        if (isJoined) {
          eventsProvider.leaveEvent(event.id, userId);
        } else {
          eventsProvider.joinEvent(event.id, userId);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isJoined
            ? AppColors.surface
            : AppColors.primary,
        foregroundColor: isJoined
            ? AppColors.textSecondary
            : AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isJoined
                ? AppColors.textSecondary.withOpacity(0.4)
                : Colors.transparent,
          ),
        ),
      ),
      child: Text(isJoined ? 'Leave' : 'Join',
          style: const TextStyle(fontSize: 12)),
    );
  }
}
