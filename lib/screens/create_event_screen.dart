import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Screen to create a new Malayalee event.
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  EventCategory _category = EventCategory.food;
  DateTime _eventDate = DateTime.now().add(const Duration(days: 1));
  int _maxParticipants = 10;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryLight,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDate),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryLight,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedTime != null) {
      setState(() {
        _eventDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;

    context.read<EventsProvider>().createEvent(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          creatorId: user.id,
          creatorName: user.name,
          category: _category,
          location: _locationController.text.trim(),
          latitude: context.read<UserProvider>().currentUser!.latitude,
          longitude: context.read<UserProvider>().currentUser!.longitude,
          eventDate: _eventDate,
          maxParticipants: _maxParticipants,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Event created! Share it with fellow Malayalees.'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Create Event',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionLabel('Event Title'),
            _StyledField(
              controller: _titleController,
              hint: 'e.g. Biriyani Friday in Bandra',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),

            _SectionLabel('Description'),
            _StyledField(
              controller: _descController,
              hint: 'Tell fellow Malayalees what this is about…',
              maxLines: 3,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Description is required'
                  : null,
            ),

            _SectionLabel('Category'),
            _CategoryPicker(
              selected: _category,
              onSelected: (c) => setState(() => _category = c),
            ),

            _SectionLabel('Location'),
            _StyledField(
              controller: _locationController,
              hint: 'e.g. Hotel Deluxe, Bandra West, Mumbai',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Location is required' : null,
            ),

            _SectionLabel('Date & Time'),
            _DateTimePicker(
              dateTime: _eventDate,
              onTap: _pickDate,
            ),

            _SectionLabel(
              'Max Participants (min ${AppConstants.eventMinParticipants})',
            ),
            _ParticipantStepper(
              value: _maxParticipants,
              onChanged: (v) => setState(() => _maxParticipants = v),
            ),

            const SizedBox(height: 8),

            // Minimum reminder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Events with fewer than ${AppConstants.eventMinParticipants} participants '
                      'will be automatically cancelled.',
                      style: TextStyle(
                          color: AppColors.warning, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Create Event 🎉',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;

  const _StyledField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final EventCategory selected;
  final ValueChanged<EventCategory> onSelected;

  const _CategoryPicker({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: EventCategory.values.map((c) {
        final isSelected = selected == c;
        // Build a temporary model to reuse the label/icon logic
        final tmp = _tmpEvent(c);
        return GestureDetector(
          onTap: () => onSelected(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryLight : AppColors.divider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tmp.categoryIcon,
                    size: 16,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  tmp.categoryLabel,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  EventModel _tmpEvent(EventCategory c) => EventModel(
        id: '',
        title: '',
        description: '',
        creatorId: '',
        creatorName: '',
        category: c,
        location: '',
        latitude: 0,
        longitude: 0,
        eventDate: DateTime.now(),
        createdAt: DateTime.now(),
        maxParticipants: 0,
        participantIds: const [],
        status: EventStatus.upcoming,
      );
}

class _DateTimePicker extends StatelessWidget {
  final DateTime dateTime;
  final VoidCallback onTap;

  const _DateTimePicker({required this.dateTime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 12),
            Text(
              '${_weekday(dateTime.weekday)}, '
              '${_month(dateTime.month)} ${dateTime.day} '
              'at ${_time(dateTime)}',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _weekday(int w) => const [
        '', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
      ][w];

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m];

  String _time(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }
}


class _ParticipantStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _ParticipantStepper({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: AppColors.textPrimary),
            onPressed: value > AppConstants.eventMinParticipants
                ? () => onChanged(value - 1)
                : null,
          ),
          Expanded(
            child: Text(
              '$value participants',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: value < AppConstants.eventMaxParticipants
                ? () => onChanged(value + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
