import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import 'questionnaire_screen.dart';

/// Onboarding flow: collect name, hometown, and current city, then verify.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Form fields
  final _nameController = TextEditingController();
  String? _selectedHometown;
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (p) => setState(() => _currentPage = p),
          children: [
            _WelcomePage(onNext: _nextPage),
            _NamePage(
              controller: _nameController,
              onNext: () {
                if (_nameController.text.trim().isNotEmpty) {
                  _nextPage();
                } else {
                  _showError(context, 'Please enter your name');
                }
              },
            ),
            _HometownPage(
              selected: _selectedHometown,
              onSelected: (v) => setState(() => _selectedHometown = v),
              onNext: () {
                if (_selectedHometown != null) {
                  _nextPage();
                } else {
                  _showError(context, 'Please select your hometown district');
                }
              },
            ),
            _CityPage(
              controller: _cityController,
              onNext: () async {
                if (_cityController.text.trim().isNotEmpty) {
                  await context.read<UserProvider>().createUser(
                        name: _nameController.text.trim(),
                        hometown: _selectedHometown!,
                        currentCity: _cityController.text.trim(),
                      );
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const QuestionnaireScreen(
                          isOnboarding: true,
                        ),
                      ),
                    );
                  }
                } else {
                  _showError(context, 'Please enter your current city');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌴', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            AppConstants.appTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Discover Malayalees around you using our radar, plan events, and celebrate Kerala culture wherever you are!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 64),
          _PrimaryButton(label: 'Get Started', onTap: onNext),
        ],
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onNext;
  const _NamePage({required this.controller, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👋 What\'s your name?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This is how other Malayalees will see you.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          _StyledTextField(
            controller: controller,
            hint: 'e.g. Arjun Nair',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 48),
          _PrimaryButton(label: 'Continue', onTap: onNext),
        ],
      ),
    );
  }
}

class _HometownPage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onNext;
  const _HometownPage({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏡 Which district are you from?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select your home district in Kerala.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3,
              ),
              itemCount: AppConstants.keralaDistricts.length,
              itemBuilder: (_, i) {
                final district = AppConstants.keralaDistricts[i];
                final isSelected = selected == district;
                return GestureDetector(
                  onTap: () => onSelected(district),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.divider,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        district,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _PrimaryButton(label: 'Continue', onTap: onNext),
        ],
      ),
    );
  }
}

class _CityPage extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onNext;
  const _CityPage({required this.controller, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏙 Where are you now?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the city you are currently living in.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          _StyledTextField(
            controller: controller,
            hint: 'e.g. Mumbai',
            icon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 48),
          _PrimaryButton(label: 'Continue →', onTap: onNext),
        ],
      ),
    );
  }
}

// ───── Shared helpers ─────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight),
        ),
      ),
    );
  }
}
