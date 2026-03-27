import 'dart:math';

/// Represents a user of the MalayaliFinder app.
class UserModel {
  final String id;
  final String name;
  final String? photoUrl;
  final String hometown; // District in Kerala
  final String currentCity;
  final bool isVerifiedMalayali;
  final double latitude;
  final double longitude;
  final DateTime lastSeen;
  final bool isOnline;
  final int points; // Engagement points

  const UserModel({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.hometown,
    required this.currentCity,
    required this.isVerifiedMalayali,
    required this.latitude,
    required this.longitude,
    required this.lastSeen,
    this.isOnline = false,
    this.points = 0,
  });

  /// Distance in km from a given lat/lon.
  double distanceFrom(double lat, double lon) {
    const earthRadius = 6371.0;
    final dLat = _toRad(latitude - lat);
    final dLon = _toRad(longitude - lon);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat)) * cos(_toRad(latitude)) * sin(dLon / 2) * sin(dLon / 2);
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? hometown,
    String? currentCity,
    bool? isVerifiedMalayali,
    double? latitude,
    double? longitude,
    DateTime? lastSeen,
    bool? isOnline,
    int? points,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      hometown: hometown ?? this.hometown,
      currentCity: currentCity ?? this.currentCity,
      isVerifiedMalayali: isVerifiedMalayali ?? this.isVerifiedMalayali,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      points: points ?? this.points,
    );
  }
}
