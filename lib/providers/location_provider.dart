import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/constants.dart';

/// Manages device location.
class LocationProvider extends ChangeNotifier {
  double _latitude = AppConstants.defaultLat;
  double _longitude = AppConstants.defaultLon;
  bool _hasPermission = false;
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStream;

  double get latitude => _latitude;
  double get longitude => _longitude;
  bool get hasPermission => _hasPermission;
  bool get isTracking => _isTracking;

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    _hasPermission = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    notifyListeners();
    return _hasPermission;
  }

  Future<void> startTracking() async {
    if (!_hasPermission) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition();
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      notifyListeners();
    } catch (_) {
      // Use defaults if location unavailable
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      _latitude = pos.latitude;
      _longitude = pos.longitude;
      _isTracking = true;
      notifyListeners();
    });
  }

  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
