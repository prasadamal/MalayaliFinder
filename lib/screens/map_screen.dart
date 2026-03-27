import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../providers/location_provider.dart';
import '../providers/events_provider.dart';
import '../utils/app_colors.dart';

/// Map screen showing nearby Malayalees and upcoming events on
/// free OpenStreetMap tiles (no API key required).
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  bool _showUsers = true;
  bool _showEvents = true;

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocationProvider>();
    final userProvider = context.watch<UserProvider>();
    final eventsProvider = context.watch<EventsProvider>();

    final myLat = locProvider.latitude;
    final myLon = locProvider.longitude;
    final nearby = userProvider.nearbyUsers;
    final events = eventsProvider.upcomingEvents;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(myLat, myLon),
              initialZoom: 13,
            ),
            children: [
              // OpenStreetMap tiles — completely free, no key required
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.malayalifinder.app',
              ),

              // My location marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(myLat, myLon),
                    width: 48,
                    height: 48,
                    child: _MyLocationMarker(),
                  ),
                ],
              ),

              // Nearby user markers
              if (_showUsers && userProvider.isRadarActive)
                MarkerLayer(
                  markers: nearby.map((u) {
                    return Marker(
                      point: LatLng(u.latitude, u.longitude),
                      width: 44,
                      height: 44,
                      child: _UserMarker(user: u),
                    );
                  }).toList(),
                ),

              // Event markers
              if (_showEvents)
                MarkerLayer(
                  markers: events.map((e) {
                    return Marker(
                      point: LatLng(e.latitude, e.longitude),
                      width: 44,
                      height: 44,
                      child: _EventMarker(
                        icon: e.categoryIcon,
                        label: e.title,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _MapTopBar(
                    showUsers: _showUsers,
                    showEvents: _showEvents,
                    onToggleUsers: () =>
                        setState(() => _showUsers = !_showUsers),
                    onToggleEvents: () =>
                        setState(() => _showEvents = !_showEvents),
                  ),
                ],
              ),
            ),
          ),

          // Locate me button
          Positioned(
            right: 12,
            bottom: 24,
            child: _LocateMeButton(
              onTap: () {
                _mapController.move(LatLng(myLat, myLon), 14);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLocationMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 22),
    );
  }
}

class _UserMarker extends StatelessWidget {
  final UserModel user;
  const _UserMarker({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _UserBottomSheet(user: user),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: user.isVerifiedMalayali
              ? AppColors.radar
              : AppColors.accentLight,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            user.name[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _EventMarker extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EventMarker({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _MapTopBar extends StatelessWidget {
  final bool showUsers;
  final bool showEvents;
  final VoidCallback onToggleUsers;
  final VoidCallback onToggleEvents;

  const _MapTopBar({
    required this.showUsers,
    required this.showEvents,
    required this.onToggleUsers,
    required this.onToggleEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '🗺 Nearby Map',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              _FilterChip(
                label: 'Mallus',
                isActive: showUsers,
                color: AppColors.radar,
                onTap: onToggleUsers,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Events',
                isActive: showEvents,
                color: AppColors.accent,
                onTap: onToggleEvents,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? color : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? color : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LocateMeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LocateMeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}

class _UserBottomSheet extends StatelessWidget {
  final UserModel user;
  const _UserBottomSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary.withOpacity(0.3),
            child: Text(
              user.name[0],
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (user.isVerifiedMalayali) ...[
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: AppColors.radar, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'From ${user.hometown}, Kerala',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Currently in ${user.currentCity}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.message_outlined),
                  label: const Text('Connect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
