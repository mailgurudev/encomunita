import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/models/event.dart';
import '../../core/services/event_service.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool _isRsvpLoading = false;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));
    final rsvpStatusAsync = ref.watch(userRsvpStatusProvider(widget.eventId));

    return Scaffold(
      body: eventAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
        error: (error, stack) => _buildErrorState(error.toString()),
        data: (event) => _buildEventDetails(event, rsvpStatusAsync),
      ),
    );
  }

  Widget _buildEventDetails(Event event, AsyncValue<RsvpStatus?> rsvpStatusAsync) {
    final isPast = event.eventDate.isBefore(DateTime.now());
    final isToday = DateFormat.yMd().format(event.eventDate) == DateFormat.yMd().format(DateTime.now());

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(event),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildEventHeader(event, isToday, isPast),
              const SizedBox(height: 24),
              _buildEventInfo(event),
              const SizedBox(height: 24),
              if (event.description != null) ...[
                _buildDescription(event.description!),
                const SizedBox(height: 24),
              ],
              _buildOrganizerInfo(event),
              const SizedBox(height: 24),
              _buildAttendeesList(event),
              const SizedBox(height: 32),
              if (!isPast) _buildRsvpSection(event, rsvpStatusAsync),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(Event event) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryTeal,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryTeal,
                AppColors.primaryTeal.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: AppIcons.iconWithBackground(
              icon: _getCategoryIcon(event.category),
              backgroundColor: Colors.white.withOpacity(0.2),
              iconColor: Colors.white,
              size: 32,
              containerSize: 80,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventHeader(Event event, bool isToday, bool isPast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getCategoryColor(event.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                event.category.displayName,
                style: TextStyle(
                  color: _getCategoryColor(event.category),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: AppColors.accentOrange,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (isPast && !isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neutralMedium.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Past Event',
                  style: TextStyle(
                    color: AppColors.neutralMedium,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          event.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutralDark,
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(Event event) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              icon: AppIcons.date,
              title: 'Date & Time',
              content: DateFormat('EEEE, MMMM d, y').format(event.eventDate),
              subtitle: DateFormat('h:mm a').format(event.eventDate),
            ),
            const Divider(height: 32),
            _buildInfoRow(
              icon: AppIcons.location,
              title: 'Location',
              content: event.location,
            ),
            if (event.maxAttendees != null) ...[
              const Divider(height: 32),
              _buildInfoRow(
                icon: AppIcons.residents,
                title: 'Capacity',
                content: '${event.attendeeCount}/${event.maxAttendees} attending',
                subtitle: event.attendeeCount >= event.maxAttendees! ? 'Event is full' : null,
              ),
            ] else if (event.attendeeCount > 0) ...[
              const Divider(height: 32),
              _buildInfoRow(
                icon: AppIcons.residents,
                title: 'Attendance',
                content: '${event.attendeeCount} ${event.attendeeCount == 1 ? 'person' : 'people'} attending',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryTeal,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralMedium,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutralDark,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutralMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this Event',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.neutralDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.neutralMedium,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizerInfo(Event event) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryCoral,
              child: Text(
                (event.organizerName ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Organized by',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.neutralMedium,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.organizerName ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutralDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeesList(Event event) {
    if (event.rsvps.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendees',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.neutralDark,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No one has RSVP\'d yet',
                  style: TextStyle(
                    color: AppColors.neutralMedium,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendees (${event.rsvps.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.neutralDark,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: event.rsvps.map((rsvp) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryTeal,
                        child: Text(
                          (rsvp.userName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        rsvp.userName ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.neutralDark,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRsvpSection(Event event, AsyncValue<RsvpStatus?> rsvpStatusAsync) {
    return rsvpStatusAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (currentStatus) {
        final isAttending = currentStatus == RsvpStatus.attending;
        final isFull = event.maxAttendees != null && event.attendeeCount >= event.maxAttendees!;

        return Column(
          children: [
            if (isAttending) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isRsvpLoading ? null : () => _handleRsvp(RsvpStatus.notAttending),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  icon: _isRsvpLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.close, color: Colors.white),
                  label: Text(
                    _isRsvpLoading ? 'Updating...' : 'Cancel RSVP',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: (_isRsvpLoading || isFull) ? null : () => _handleRsvp(RsvpStatus.attending),
                  icon: _isRsvpLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check, color: Colors.white),
                  label: Text(
                    _isRsvpLoading
                        ? 'Updating...'
                        : isFull
                            ? 'Event Full'
                            : 'RSVP to Attend',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
            if (isFull && !isAttending) ...[
              const SizedBox(height: 8),
              Text(
                'This event has reached maximum capacity',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.neutralDark,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading event',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(
                  color: AppColors.neutralMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRsvp(RsvpStatus status) async {
    setState(() => _isRsvpLoading = true);

    try {
      final eventService = ref.read(eventServiceProvider);

      if (status == RsvpStatus.notAttending) {
        await eventService.removeRsvp(widget.eventId);
      } else {
        await eventService.rsvpToEvent(widget.eventId, status);
      }

      if (mounted) {
        // Refresh all event-related providers
        ref.invalidate(eventDetailsProvider(widget.eventId));
        ref.invalidate(userRsvpStatusProvider(widget.eventId));
        ref.invalidate(communityEventsProvider);
        ref.invalidate(myRsvpEventsProvider);

        _showSuccessSnackBar(
          status == RsvpStatus.attending
            ? 'Successfully RSVP\'d to event!'
            : 'RSVP cancelled successfully'
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to update RSVP: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isRsvpLoading = false);
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