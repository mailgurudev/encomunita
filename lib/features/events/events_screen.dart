import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/models/event.dart';
import '../../core/services/event_service.dart';
import 'create_event_screen.dart';
import 'event_details_screen.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Events'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.neutralDark,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Events'),
            Tab(text: 'My Events'),
            Tab(text: 'Attending'),
          ],
          labelColor: AppColors.primaryTeal,
          unselectedLabelColor: AppColors.neutralMedium,
          indicatorColor: AppColors.primaryTeal,
        ),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllEventsTab(),
            _buildMyEventsTab(),
            _buildAttendingEventsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primaryCoral,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAllEventsTab() {
    final eventsAsync = ref.watch(communityEventsProvider);

    return eventsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (events) => _buildEventsList(events, 'No events in your community yet.'),
    );
  }

  Widget _buildMyEventsTab() {
    final eventsAsync = ref.watch(myEventsProvider);

    return eventsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (events) => _buildEventsList(events, 'You haven\'t created any events yet.'),
    );
  }

  Widget _buildAttendingEventsTab() {
    final eventsAsync = ref.watch(myRsvpEventsProvider);

    return eventsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (events) => _buildEventsList(events, 'You haven\'t RSVP\'d to any events yet.'),
    );
  }

  Widget _buildEventsList(List<Event> events, String emptyMessage) {
    if (events.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(communityEventsProvider);
        ref.invalidate(myEventsProvider);
        ref.invalidate(myRsvpEventsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return _buildEventCard(events[index]);
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final isToday = DateFormat.yMd().format(event.eventDate) == DateFormat.yMd().format(DateTime.now());
    final isPast = event.eventDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(eventId: event.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(event.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.category.displayName,
                      style: TextStyle(
                        color: _getCategoryColor(event.category),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          color: AppColors.accentOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (isPast && !isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.neutralMedium.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Past',
                        style: TextStyle(
                          color: AppColors.neutralMedium,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralDark,
                ),
              ),
              if (event.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  event.description!,
                  style: TextStyle(
                    color: AppColors.neutralMedium,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.neutralMedium,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, y • h:mm a').format(event.eventDate),
                    style: TextStyle(
                      color: AppColors.neutralMedium,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.neutralMedium,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location,
                      style: TextStyle(
                        color: AppColors.neutralMedium,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primaryTeal,
                    child: Text(
                      (event.organizerName ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Organized by ${event.organizerName ?? 'Unknown'}',
                    style: TextStyle(
                      color: AppColors.neutralMedium,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (event.attendeeCount > 0) ...[
                    Icon(
                      Icons.people,
                      size: 16,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.attendeeCount} attending',
                      style: TextStyle(
                        color: AppColors.primaryTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.events,
              size: 64,
              color: AppColors.neutralMedium,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.neutralMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
              },
              child: const Text('Create First Event'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
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
              'Error loading events',
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
              onPressed: () {
                ref.invalidate(communityEventsProvider);
                ref.invalidate(myEventsProvider);
                ref.invalidate(myRsvpEventsProvider);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
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