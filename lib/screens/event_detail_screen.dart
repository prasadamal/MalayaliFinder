import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Detailed view of a single event.
class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final event = context.watch<EventsProvider>().getById(eventId);
    if (event == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child: Text('Event not found',
                style: TextStyle(color: AppColors.textPrimary))),
      );
    }

    final currentUser = context.read<UserProvider>().currentUser;
    final isJoined =
        currentUser != null && event.participantIds.contains(currentUser.id);
    final isCreator = currentUser?.id == event.creatorId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.surface,
            expandedHeight: 200,
            pinned: true,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    event.categoryIcon,
                    size: 72,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Status
                  Row(
                    children: [
                      _Chip(
                        icon: event.categoryIcon,
                        label: event.categoryLabel,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(status: event.status),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'About',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info tiles
                  _InfoTile(
                    icon: Icons.person_outline,
                    label: 'Organised by',
                    value: event.creatorName,
                  ),
                  _InfoTile(
                    icon: Icons.calendar_today,
                    label: 'Date & Time',
                    value: DateFormat('EEEE, d MMM y • h:mm a')
                        .format(event.eventDate),
                  ),
                  _InfoTile(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: event.location,
                  ),

                  const SizedBox(height: 20),

                  // Participants
                  _ParticipantsSection(event: event),

                  const SizedBox(height: 24),

                  // Join / Leave button
                  if (!isCreator && event.status == EventStatus.upcoming)
                    _JoinLeaveButton(
                      event: event,
                      isJoined: isJoined,
                      userId: currentUser!.id,
                    ),

                  if (isCreator)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: AppColors.accent, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'You created this event',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final EventStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color c;
    String label;
    switch (status) {
      case EventStatus.upcoming:
        c = AppColors.success;
        label = '● Upcoming';
        break;
      case EventStatus.ongoing:
        c = AppColors.info;
        label = '● Live';
        break;
      case EventStatus.cancelled:
        c = AppColors.error;
        label = '✕ Cancelled';
        break;
      case EventStatus.completed:
        c = AppColors.textSecondary;
        label = '✓ Completed';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(color: c, fontSize: 12)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantsSection extends StatelessWidget {
  final EventModel event;
  const _ParticipantsSection({required this.event});

  @override
  Widget build(BuildContext context) {
    final filled = event.participantIds.length;
    final max = event.maxParticipants;
    final min = EventModel.minimumParticipants;
    final needed = (min - filled).clamp(0, min);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Participants',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              '$filled / $max',
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: filled / max,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation(
              event.isFull ? AppColors.error : AppColors.primary,
            ),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),

        if (!event.hasMinimumParticipants)
          Row(
            children: [
              const Icon(Icons.warning_amber,
                  color: AppColors.warning, size: 16),
              const SizedBox(width: 6),
              Text(
                'Need $needed more to confirm (min $min)',
                style: const TextStyle(
                    color: AppColors.warning, fontSize: 12),
              ),
            ],
          ),

        if (event.hasMinimumParticipants && !event.isFull)
          Text(
            '${event.spotsLeft} spot${event.spotsLeft == 1 ? '' : 's'} left',
            style: const TextStyle(
                color: AppColors.textAccent, fontSize: 12),
          ),

        if (event.isFull)
          const Text(
            'Event is full!',
            style: TextStyle(color: AppColors.error, fontSize: 12),
          ),
      ],
    );
  }
}

class _JoinLeaveButton extends StatelessWidget {
  final EventModel event;
  final bool isJoined;
  final String userId;

  const _JoinLeaveButton({
    required this.event,
    required this.isJoined,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final canJoin = !event.isFull && !isJoined;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final ep = context.read<EventsProvider>();
          if (isJoined) {
            ep.leaveEvent(event.id, userId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You have left the event.'),
                backgroundColor: AppColors.warning,
              ),
            );
          } else if (canJoin) {
            ep.joinEvent(event.id, userId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 You joined the event!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isJoined
              ? AppColors.surface
              : canJoin
                  ? AppColors.primary
                  : AppColors.divider,
          foregroundColor: isJoined
              ? AppColors.textSecondary
              : AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          side: isJoined
              ? const BorderSide(color: AppColors.divider)
              : BorderSide.none,
        ),
        child: Text(
          isJoined
              ? 'Leave Event'
              : event.isFull
                  ? 'Event Full'
                  : 'Join Event 🌴',
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
