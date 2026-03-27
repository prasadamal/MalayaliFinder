import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/location_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/radar_widget.dart';
import '../models/user_model.dart';

/// Main radar screen — the centrepiece of MalayaliFinder.
class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().startTracking().then((_) {
        final loc = context.read<LocationProvider>();
        context.read<UserProvider>().updateLocation(loc.latitude, loc.longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final nearby = userProvider.nearbyUsers;
    final isActive = userProvider.isRadarActive;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              isActive: isActive,
              range: userProvider.radarRange,
              count: nearby.length,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Radar
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: RadarWidget(
                        nearbyUsers: nearby,
                        radarRange: userProvider.radarRange,
                        isActive: isActive,
                      ),
                    ),
                  ),

                  // Inactive overlay
                  if (!isActive)
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.radar,
                              size: 48, color: AppColors.textSecondary),
                          SizedBox(height: 12),
                          Text(
                            'Tap the button below\nto start scanning',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Range slider
            if (isActive) _RangeSlider(userProvider: userProvider),

            // Nearby list
            if (isActive && nearby.isNotEmpty)
              _NearbyList(users: nearby, range: userProvider.radarRange),

            // Toggle button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: _ToggleButton(
                isActive: isActive,
                onTap: () => userProvider.toggleRadar(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isActive;
  final double range;
  final int count;

  const _Header({
    required this.isActive,
    required this.range,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mallu Radar 📡',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isActive
                    ? '$count Malayalee${count == 1 ? '' : 's'} within ${range.toStringAsFixed(0)} km'
                    : 'Radar is off',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          if (isActive)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.radar.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.radar.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.radar,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: AppColors.radar,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RangeSlider extends StatelessWidget {
  final UserProvider userProvider;
  const _RangeSlider({required this.userProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text('1km',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          Expanded(
            child: Slider(
              value: userProvider.radarRange,
              min: 1,
              max: 50,
              divisions: 4,
              label: '${userProvider.radarRange.toStringAsFixed(0)} km',
              activeColor: AppColors.radar,
              inactiveColor: AppColors.surface,
              onChanged: (v) => userProvider.setRadarRange(v),
            ),
          ),
          const Text('50km',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _NearbyList extends StatelessWidget {
  final List<UserModel> users;
  final double range;
  const _NearbyList({required this.users, required this.range});

  @override
  Widget build(BuildContext context) {
    final limited = users.take(5).toList();
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: limited.length,
        itemBuilder: (_, i) {
          final user = limited[i];
          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: user.isVerifiedMalayali
                    ? AppColors.radar.withOpacity(0.5)
                    : AppColors.divider,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.3),
                      child: Text(
                        user.name[0],
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (user.isVerifiedMalayali)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.radar,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.name.split(' ').first,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [AppColors.error, const Color(0xFFB71C1C)]
                : [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppColors.error : AppColors.primary)
                  .withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.stop_circle : Icons.radar,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              isActive ? 'Stop Radar' : 'Start Radar',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
