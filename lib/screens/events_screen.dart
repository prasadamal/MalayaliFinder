import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/event_card.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';

/// Events list screen — browse, join, and create Malayalee meetups.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    final allEvents = eventsProvider.upcomingEvents;
    final myEvents = currentUser != null
        ? eventsProvider.userEvents(currentUser.id)
        : <EventModel>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _EventsHeader(
              onCreateTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CreateEventScreen()),
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryLight,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [
                Tab(text: 'All Events (${allEvents.length})'),
                Tab(text: 'My Events (${myEvents.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All events tab
                  _EventsList(
                    events: allEvents,
                    onTap: (e) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(eventId: e.id),
                      ),
                    ),
                  ),

                  // My events tab
                  _EventsList(
                    events: myEvents,
                    emptyLabel: 'You haven\'t joined any events yet.',
                    onTap: (e) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(eventId: e.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateEventScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }
}

class _EventsHeader extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EventsHeader({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mallu Meetups 🌟',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Min. ${AppConstants.eventMinParticipants} people needed for an event',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final List<EventModel> events;
  final String emptyLabel;
  final void Function(EventModel) onTap;

  const _EventsList({
    required this.events,
    this.emptyLabel = 'No events yet. Create one!',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌴', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              emptyLabel,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: events.length,
      itemBuilder: (_, i) => EventCard(
        event: events[i],
        onTap: () => onTap(events[i]),
      ),
    );
  }
}
