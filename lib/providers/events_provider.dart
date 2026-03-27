import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/event_model.dart';
import '../utils/constants.dart';

/// Manages events in MalayaliFinder.
class EventsProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  final List<EventModel> _events = [];

  List<EventModel> get events => List.unmodifiable(_events);

  List<EventModel> get upcomingEvents => _events
      .where((e) =>
          e.status == EventStatus.upcoming &&
          e.eventDate.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

  List<EventModel> userEvents(String userId) =>
      _events.where((e) => e.participantIds.contains(userId)).toList();

  EventsProvider() {
    _loadMockEvents();
  }

  void _loadMockEvents() {
    final now = DateTime.now();
    _events.addAll([
      EventModel(
        id: _uuid.v4(),
        title: 'Biriyani Friday in Bandra',
        description:
            'Craving some authentic Malabar biriyani? Let\'s head to Hotel Deluxe in Bandra! Malayalees only 🌴',
        creatorId: 'mock_0',
        creatorName: 'Arjun Nair',
        category: EventCategory.food,
        location: 'Hotel Deluxe, Bandra West, Mumbai',
        latitude: 19.0596,
        longitude: 72.8295,
        eventDate: now.add(const Duration(days: 2, hours: 7)),
        createdAt: now.subtract(const Duration(hours: 3)),
        maxParticipants: 10,
        participantIds: ['mock_0', 'mock_1', 'mock_2', 'mock_5'],
        status: EventStatus.upcoming,
      ),
      EventModel(
        id: _uuid.v4(),
        title: 'Onam Celebration 2024',
        description:
            'Pookalam, Sadhya and Thiruvathira! Let\'s celebrate Onam together away from home. All Malayalees welcome!',
        creatorId: 'mock_3',
        creatorName: 'Ananya Pillai',
        category: EventCategory.cultural,
        location: 'Shivaji Park, Dadar, Mumbai',
        latitude: 19.0281,
        longitude: 72.8388,
        eventDate: now.add(const Duration(days: 14)),
        createdAt: now.subtract(const Duration(days: 1)),
        maxParticipants: 50,
        participantIds: ['mock_3', 'mock_7', 'mock_9'],
        status: EventStatus.upcoming,
      ),
      EventModel(
        id: _uuid.v4(),
        title: 'Cricket at Azad Maidan',
        description:
            'Mallus vs the world! Sunday morning cricket match at Azad Maidan. Bring your energy!',
        creatorId: 'mock_6',
        creatorName: 'Sanjay Mohan',
        category: EventCategory.sports,
        location: 'Azad Maidan, Mumbai',
        latitude: 18.9344,
        longitude: 72.8338,
        eventDate: now.add(const Duration(days: 3, hours: 4)),
        createdAt: now.subtract(const Duration(hours: 12)),
        maxParticipants: 22,
        participantIds: ['mock_6', 'mock_10', 'mock_11', 'mock_13'],
        status: EventStatus.upcoming,
      ),
      EventModel(
        id: _uuid.v4(),
        title: 'Malayalam Movie Night',
        description:
            'Watching the latest Mohanlal blockbuster together! Popcorn and chai included 😄',
        creatorId: 'mock_2',
        creatorName: 'Vishnu Kumar',
        category: EventCategory.cultural,
        location: 'PVR Cinemas, Lower Parel, Mumbai',
        latitude: 19.0038,
        longitude: 72.8298,
        eventDate: now.add(const Duration(days: 1, hours: 5)),
        createdAt: now.subtract(const Duration(hours: 6)),
        maxParticipants: 15,
        participantIds: ['mock_2', 'mock_4', 'mock_8'],
        status: EventStatus.upcoming,
      ),
      EventModel(
        id: _uuid.v4(),
        title: 'Kathakali Performance',
        description:
            'A classical Kathakali performance by visiting artists from Thrissur. Limited seats!',
        creatorId: 'mock_14',
        creatorName: 'Sreejith Kumar',
        category: EventCategory.music,
        location: 'NCPA, Nariman Point, Mumbai',
        latitude: 18.9247,
        longitude: 72.8233,
        eventDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 2)),
        maxParticipants: 30,
        participantIds: List.generate(28, (i) => 'mock_$i'),
        status: EventStatus.upcoming,
      ),
    ]);
  }

  void createEvent({
    required String title,
    required String description,
    required String creatorId,
    required String creatorName,
    required EventCategory category,
    required String location,
    required double latitude,
    required double longitude,
    required DateTime eventDate,
    required int maxParticipants,
  }) {
    final event = EventModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      creatorId: creatorId,
      creatorName: creatorName,
      category: category,
      location: location,
      latitude: latitude,
      longitude: longitude,
      eventDate: eventDate,
      createdAt: DateTime.now(),
      maxParticipants: maxParticipants,
      participantIds: [creatorId],
      status: EventStatus.upcoming,
    );
    _events.insert(0, event);
    notifyListeners();
  }

  bool joinEvent(String eventId, String userId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return false;
    final event = _events[index];
    if (event.isFull || event.participantIds.contains(userId)) return false;
    final updated = event.copyWith(
      participantIds: [...event.participantIds, userId],
    );
    _events[index] = updated;
    notifyListeners();
    return true;
  }

  bool leaveEvent(String eventId, String userId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return false;
    final event = _events[index];
    if (!event.participantIds.contains(userId)) return false;
    final updatedIds = event.participantIds.where((id) => id != userId).toList();
    EventStatus newStatus = event.status;
    // Auto-cancel if below minimum and event date hasn't passed
    if (updatedIds.length < EventModel.minimumParticipants &&
        event.eventDate.isAfter(DateTime.now())) {
      newStatus = EventStatus.cancelled;
    }
    _events[index] = event.copyWith(participantIds: updatedIds, status: newStatus);
    notifyListeners();
    return true;
  }

  /// Cancel events that still don't meet minimum participants 1 hour before start.
  void autoCancel() {
    final oneHourFromNow = DateTime.now().add(const Duration(hours: 1));
    for (int i = 0; i < _events.length; i++) {
      final event = _events[i];
      if (event.status == EventStatus.upcoming &&
          event.eventDate.isBefore(oneHourFromNow) &&
          !event.hasMinimumParticipants) {
        _events[i] = event.copyWith(status: EventStatus.cancelled);
      }
    }
    notifyListeners();
  }

  EventModel? getById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
