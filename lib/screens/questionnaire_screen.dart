import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/questionnaire_model.dart';
import '../providers/user_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

/// Questionnaire screen to verify Malayalee identity.
///
/// Shows [AppConstants.questionsRequired] questions; user must answer
/// [AppConstants.minimumCorrectAnswers] correctly to be verified.
class QuestionnaireScreen extends StatefulWidget {
  /// When [isOnboarding] is true, passing navigates to [HomeScreen].
  final bool isOnboarding;

  const QuestionnaireScreen({super.key, this.isOnboarding = false});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _questions = List.of(malayaliQuestions)..shuffle();
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _finished = false;
  bool _passed = false;

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _correctCount++;
      }
    });
  }

  void _next() {
    if (_currentIndex + 1 >= AppConstants.questionsRequired) {
      _finish();
    } else {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    }
  }

  Future<void> _finish() async {
    final passed =
        _correctCount >= AppConstants.minimumCorrectAnswers;
    if (passed) {
      await context.read<UserProvider>().verifyUser();
    }
    setState(() {
      _finished = true;
      _passed = passed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _ResultScreen(
        passed: _passed,
        correct: _correctCount,
        total: AppConstants.questionsRequired,
        isOnboarding: widget.isOnboarding,
      );
    }

    final question = _questions[_currentIndex];
    final progress =
        (_currentIndex + 1) / AppConstants.questionsRequired;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Malayalee Verification',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress
              Row(
                children: [
                  Text(
                    '${_currentIndex + 1} / ${AppConstants.questionsRequired}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.surface,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.primaryLight),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Score tracker
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '✓ $_correctCount correct  |  Need ${AppConstants.minimumCorrectAnswers}',
                  style: const TextStyle(
                    color: AppColors.textAccent,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Question
              Text(
                question.question,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Options
              ...List.generate(question.options.length, (i) {
                return _OptionTile(
                  label: question.options[i],
                  index: i,
                  selectedIndex: _selectedOption,
                  correctIndex: question.correctIndex,
                  answered: _answered,
                  onTap: () => _selectOption(i),
                );
              }),

              const Spacer(),

              // Next button
              if (_answered)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentIndex + 1 >= AppConstants.questionsRequired
                          ? 'See Results'
                          : 'Next Question →',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final bool answered;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.answered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.divider;
    Color bgColor = AppColors.surface;
    Widget? trailing;

    if (answered && index == correctIndex) {
      borderColor = AppColors.success;
      bgColor = AppColors.success.withOpacity(0.1);
      trailing = const Icon(Icons.check_circle, color: AppColors.success, size: 20);
    } else if (answered && index == selectedIndex && index != correctIndex) {
      borderColor = AppColors.error;
      bgColor = AppColors.error.withOpacity(0.1);
      trailing = const Icon(Icons.cancel, color: AppColors.error, size: 20);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Letter badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

/// Shown after questionnaire is completed.
class _ResultScreen extends StatelessWidget {
  final bool passed;
  final int correct;
  final int total;
  final bool isOnboarding;

  const _ResultScreen({
    required this.passed,
    required this.correct,
    required this.total,
    required this.isOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  passed ? '🎉' : '😔',
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 24),
                Text(
                  passed ? 'Namaskaram! You\'re a Malayali! 🌴' : 'Not quite there...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You scored $correct / $total',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  passed
                      ? 'Your Malayalee badge is now active. Welcome to the community!'
                      : 'You need at least ${AppConstants.minimumCorrectAnswers} correct answers. Try again!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (passed || isOnboarding) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                          (_) => false,
                        );
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const QuestionnaireScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      passed || isOnboarding ? 'Enter MalayaliFinder →' : 'Try Again',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
