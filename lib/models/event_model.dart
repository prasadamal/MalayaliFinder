import 'package:flutter/material.dart';

/// Status of an event.
enum EventStatus { upcoming, ongoing, cancelled, completed }

/// Category of the event.
enum EventCategory { food, sports, cultural, music, travel, other }

/// A user-created event in MalayaliFinder.
class EventModel {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String creatorName;
  final EventCategory category;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime eventDate;
  final DateTime createdAt;
  final int maxParticipants;
  final List<String> participantIds;
  final EventStatus status;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.category,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.eventDate,
    required this.createdAt,
    required this.maxParticipants,
    required this.participantIds,
    required this.status,
  });

  /// Minimum participants needed for the event to proceed.
  static const int minimumParticipants = 3;

  bool get isFull => participantIds.length >= maxParticipants;

  bool get hasMinimumParticipants => participantIds.length >= minimumParticipants;

  int get spotsLeft => maxParticipants - participantIds.length;

  String get categoryLabel {
    switch (category) {
      case EventCategory.food:
        return 'Food & Dining';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.cultural:
        return 'Cultural';
      case EventCategory.music:
        return 'Music';
      case EventCategory.travel:
        return 'Travel';
      case EventCategory.other:
        return 'Other';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case EventCategory.food:
        return Icons.restaurant;
      case EventCategory.sports:
        return Icons.sports_cricket;
      case EventCategory.cultural:
        return Icons.temple_hindu;
      case EventCategory.music:
        return Icons.music_note;
      case EventCategory.travel:
        return Icons.flight;
      case EventCategory.other:
        return Icons.event;
    }
  }

  EventModel copyWith({
    String? title,
    String? description,
    EventStatus? status,
    List<String>? participantIds,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId,
      creatorName: creatorName,
      category: category,
      location: location,
      latitude: latitude,
      longitude: longitude,
      eventDate: eventDate,
      createdAt: createdAt,
      maxParticipants: maxParticipants,
      participantIds: participantIds ?? this.participantIds,
      status: status ?? this.status,
    );
  }
}
