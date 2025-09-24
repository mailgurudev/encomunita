import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/models/event.dart';
import '../../core/services/event_service.dart';
import '../../core/services/user_service.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();

  EventCategory _selectedCategory = EventCategory.social;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.neutralDark,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleCreateEvent,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                    ),
                  )
                : Text(
                    'Create',
                    style: TextStyle(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryTeal.withOpacity(0.05),
              AppColors.accentOrange.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 20),
                  _buildDateTimeSection(),
                  const SizedBox(height: 20),
                  _buildLocationSection(),
                  const SizedBox(height: 20),
                  _buildAdditionalInfoSection(),
                  const SizedBox(height: 32),
                  _buildCreateButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        AppIcons.iconWithBackground(
          icon: AppIcons.events,
          backgroundColor: AppColors.primaryCoral,
          size: 32,
          containerSize: 80,
        ),
        const SizedBox(height: 16),
        Text(
          'Create Community Event',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.neutralDark,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Bring your community together with an amazing event',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.neutralMedium,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Event Details'),
        const SizedBox(height: 12),

        // Event Title
        TextFormField(
          controller: _titleController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Event Title *',
            hintText: 'Community BBQ Night',
            prefixIcon: const Icon(AppIcons.events),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an event title';
            }
            if (value.trim().length < 3) {
              return 'Title must be at least 3 characters';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Category Selection
        DropdownButtonFormField<EventCategory>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category *',
            prefixIcon: Icon(_getCategoryIcon(_selectedCategory)),
          ),
          items: EventCategory.values.map((category) {
            return DropdownMenuItem<EventCategory>(
              value: category,
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 20,
                    color: _getCategoryColor(category),
                  ),
                  const SizedBox(width: 8),
                  Text(category.displayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (EventCategory? newValue) {
            setState(() {
              _selectedCategory = newValue ?? EventCategory.social;
            });
          },
        ),

        const SizedBox(height: 16),

        // Description
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          textInputAction: TextInputAction.newline,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Tell your neighbors what this event is about...',
            prefixIcon: const Icon(AppIcons.comment),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('When'),
        const SizedBox(height: 12),

        Row(
          children: [
            // Date Picker
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date *',
                    prefixIcon: const Icon(AppIcons.date),
                  ),
                  child: Text(
                    DateFormat('MMM d, y').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Time Picker
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time *',
                    prefixIcon: const Icon(AppIcons.time),
                  ),
                  child: Text(
                    _selectedTime.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Where'),
        const SizedBox(height: 12),

        // Community info card
        userProfileAsync.when(
          data: (profile) => Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.community,
                  color: AppColors.primaryTeal,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community Event',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryTeal,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        profile?.communityName ?? 'Your Community',
                        style: TextStyle(
                          color: AppColors.neutralMedium,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        TextFormField(
          controller: _locationController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Specific Location *',
            hintText: 'Community Center, Pool Area, Building A Lobby, etc.',
            prefixIcon: const Icon(AppIcons.location),
            helperText: 'Where exactly in your community will this event take place?',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the specific location within your community';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Additional Info'),
        const SizedBox(height: 12),

        TextFormField(
          controller: _maxAttendeesController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Max Attendees (Optional)',
            hintText: 'Leave empty for unlimited',
            prefixIcon: const Icon(AppIcons.residents),
          ),
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              final number = int.tryParse(value.trim());
              if (number == null || number < 1) {
                return 'Please enter a valid number';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.neutralDark,
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreateEvent,
        child: _isLoading
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.neutralWhite),
              )
            : const Text('Create Event'),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.neutralDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.neutralDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleCreateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final eventService = ref.read(eventServiceProvider);

      // Combine date and time
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Parse max attendees
      int? maxAttendees;
      if (_maxAttendeesController.text.trim().isNotEmpty) {
        maxAttendees = int.tryParse(_maxAttendeesController.text.trim());
      }

      final request = CreateEventRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        eventDate: eventDateTime,
        location: _locationController.text.trim(),
        maxAttendees: maxAttendees,
      );

      await eventService.createEvent(request);

      if (mounted) {
        // Refresh events list
        ref.invalidate(communityEventsProvider);
        ref.invalidate(myEventsProvider);

        _showSuccessSnackBar('Event created successfully!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to create event: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.social:
        return AppIcons.party;
      case EventCategory.maintenance:
        return Icons.build_rounded;
      case EventCategory.emergency:
        return AppIcons.emergency;
      case EventCategory.sports:
        return AppIcons.sports;
      case EventCategory.educational:
        return AppIcons.tutor;
      case EventCategory.community:
        return AppIcons.community;
    }
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.social:
        return AppColors.primaryCoral;
      case EventCategory.maintenance:
        return AppColors.warning;
      case EventCategory.emergency:
        return AppColors.error;
      case EventCategory.sports:
        return AppColors.success;
      case EventCategory.educational:
        return AppColors.primaryTeal;
      case EventCategory.community:
        return AppColors.info;
    }
  }
}