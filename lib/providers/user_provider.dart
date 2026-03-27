import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

/// Manages the current user's profile and nearby Malayalee users.
class UserProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  UserModel? _currentUser;
  bool _isVerified = false;
  bool _isRadarActive = false;
  double _radarRange = AppConstants.defaultRadarRange;
  List<UserModel> _nearbyUsers = [];

  UserModel? get currentUser => _currentUser;
  bool get isVerified => _isVerified;
  bool get isRadarActive => _isRadarActive;
  double get radarRange => _radarRange;
  List<UserModel> get nearbyUsers => _nearbyUsers;

  /// Indicates whether the user has completed initial setup.
  bool get isSetupComplete =>
      _currentUser != null && _isVerified;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final isVerified = prefs.getBool('is_verified') ?? false;

    if (userId != null) {
      _currentUser = UserModel(
        id: userId,
        name: prefs.getString('user_name') ?? 'Malayali',
        hometown: prefs.getString('user_hometown') ?? 'Kerala',
        currentCity: prefs.getString('user_city') ?? 'Mumbai',
        isVerifiedMalayali: isVerified,
        latitude: AppConstants.defaultLat,
        longitude: AppConstants.defaultLon,
        lastSeen: DateTime.now(),
        isOnline: true,
      );
      _isVerified = isVerified;
    }
    notifyListeners();
  }

  Future<void> createUser({
    required String name,
    required String hometown,
    required String currentCity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final id = _uuid.v4();
    await prefs.setString('user_id', id);
    await prefs.setString('user_name', name);
    await prefs.setString('user_hometown', hometown);
    await prefs.setString('user_city', currentCity);

    _currentUser = UserModel(
      id: id,
      name: name,
      hometown: hometown,
      currentCity: currentCity,
      isVerifiedMalayali: false,
      latitude: AppConstants.defaultLat,
      longitude: AppConstants.defaultLon,
      lastSeen: DateTime.now(),
      isOnline: true,
    );
    notifyListeners();
  }

  Future<void> verifyUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_verified', true);
    _isVerified = true;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isVerifiedMalayali: true);
    }
    notifyListeners();
  }

  void updateLocation(double lat, double lon) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(latitude: lat, longitude: lon);
      _refreshNearbyUsers();
      notifyListeners();
    }
  }

  void toggleRadar() {
    _isRadarActive = !_isRadarActive;
    if (_isRadarActive) {
      _refreshNearbyUsers();
    } else {
      _nearbyUsers = [];
    }
    notifyListeners();
  }

  void setRadarRange(double range) {
    _radarRange = range;
    if (_isRadarActive) {
      _refreshNearbyUsers();
    }
    notifyListeners();
  }

  /// Simulates fetching nearby Malayalees within [_radarRange] km.
  void _refreshNearbyUsers() {
    if (_currentUser == null) return;
    final rand = Random();
    final baseLat = _currentUser!.latitude;
    final baseLon = _currentUser!.longitude;

    // Generate mock nearby users scattered around the current location
    _nearbyUsers = _mockUsers(baseLat, baseLon, rand)
        .where((u) => u.distanceFrom(baseLat, baseLon) <= _radarRange)
        .toList();
  }

  List<UserModel> _mockUsers(double baseLat, double baseLon, Random rand) {
    final names = [
      'Arjun Nair', 'Priya Menon', 'Vishnu Kumar', 'Ananya Pillai',
      'Rohith Varma', 'Deepa Krishnan', 'Sanjay Mohan', 'Lakshmi Unni',
      'Arun Raj', 'Meera Suresh', 'Nithin Babu', 'Divya Nambiar',
      'Rahul Pillai', 'Anjali Varma', 'Sreejith Kumar',
    ];
    final hometowns = AppConstants.keralaDistricts;
    final cities = ['Mumbai', 'Bengaluru', 'Chennai', 'Delhi', 'Hyderabad', 'Pune'];

    return List.generate(names.length, (i) {
      // Spread within ±0.5° (~55 km)
      final dlat = (rand.nextDouble() - 0.5) * (_radarRange / 55);
      final dlon = (rand.nextDouble() - 0.5) * (_radarRange / 55);
      return UserModel(
        id: 'mock_$i',
        name: names[i],
        hometown: hometowns[rand.nextInt(hometowns.length)],
        currentCity: cities[rand.nextInt(cities.length)],
        isVerifiedMalayali: rand.nextBool(),
        latitude: baseLat + dlat,
        longitude: baseLon + dlon,
        lastSeen: DateTime.now().subtract(Duration(minutes: rand.nextInt(60))),
        isOnline: rand.nextBool(),
      );
    });
  }
}
