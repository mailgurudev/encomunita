import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/event.dart';

class EventService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Get all events for the current user's community
  Future<List<Event>> getCommunityEvents() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Get user's community
      final userProfile = await _supabase
          .from(SupabaseConfig.userProfilesTable)
          .select('community_name')
          .eq('user_id', user.id)
          .single();

      final communityName = userProfile['community_name'] as String;

      // Get events for the community (simplified query)
      final response = await _supabase
          .from('events')
          .select('*')
          .eq('community_name', communityName)
          .eq('is_active', true)
          .order('event_date', ascending: true);

      // Get RSVP counts for each event
      final eventIds = response.map((event) => event['id'] as String).toList();
      final rsvpCounts = await _getRsvpCounts(eventIds);

      return response.map((eventData) {
        final event = Event.fromJson(eventData);

        return event.copyWith(
          organizerName: 'Community Member', // Generic name for now
          attendeeCount: rsvpCounts[event.id] ?? 0,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get events organized by the current user
  Future<List<Event>> getMyEvents() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final response = await _supabase
          .from('events')
          .select('*')
          .eq('organizer_id', user.id)
          .order('event_date', ascending: true);

      // Get RSVP counts for each event
      final eventIds = response.map((event) => event['id'] as String).toList();
      final rsvpCounts = await _getRsvpCounts(eventIds);

      return response.map((eventData) {
        final event = Event.fromJson(eventData);
        return event.copyWith(
          attendeeCount: rsvpCounts[event.id] ?? 0,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get events the current user has RSVP'd to
  Future<List<Event>> getMyRsvpEvents() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final response = await _supabase
          .from('event_rsvps')
          .select('''
            *,
            event:event_id (
              *
            )
          ''')
          .eq('user_id', user.id)
          .eq('status', RsvpStatus.attending.name);

      return response.map((rsvpData) {
        final eventData = rsvpData['event'];

        return Event.fromJson(eventData).copyWith(
          organizerName: 'Community Member', // Generic name for now
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new event
  Future<Event> createEvent(CreateEventRequest request) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Get user's community
      final userProfile = await _supabase
          .from(SupabaseConfig.userProfilesTable)
          .select('community_name')
          .eq('user_id', user.id)
          .single();

      final communityName = userProfile['community_name'] as String;

      final eventData = {
        ...request.toJson(),
        'organizer_id': user.id,
        'community_name': communityName,
      };

      final response = await _supabase
          .from('events')
          .insert(eventData)
          .select()
          .single();

      return Event.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get detailed event information including RSVPs
  Future<Event> getEventDetails(String eventId) async {
    try {
      // Get event (simplified query)
      final eventResponse = await _supabase
          .from('events')
          .select('*')
          .eq('id', eventId)
          .single();

      // Get RSVPs (simplified query)
      final rsvpResponse = await _supabase
          .from('event_rsvps')
          .select('*')
          .eq('event_id', eventId)
          .eq('status', RsvpStatus.attending.name);

      final rsvps = rsvpResponse.map((rsvpData) {
        return EventRsvp.fromJson({
          ...rsvpData,
          'user_name': 'Community Member', // Generic name for now
          'user_community': null,
        });
      }).toList();

      return Event.fromJson(eventResponse).copyWith(
        organizerName: 'Community Member', // Generic name for now
        attendeeCount: rsvps.length,
        rsvps: rsvps,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// RSVP to an event
  Future<void> rsvpToEvent(String eventId, RsvpStatus status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await _supabase
          .from('event_rsvps')
          .upsert({
            'event_id': eventId,
            'user_id': user.id,
            'status': status.name,
          });
    } catch (e) {
      rethrow;
    }
  }

  /// Remove RSVP from an event
  Future<void> removeRsvp(String eventId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await _supabase
          .from('event_rsvps')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's RSVP status for an event
  Future<RsvpStatus?> getUserRsvpStatus(String eventId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('event_rsvps')
          .select('status')
          .eq('event_id', eventId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return RsvpStatus.fromString(response['status'] as String);
    } catch (e) {
      return null;
    }
  }

  /// Update an event (only for organizers)
  Future<Event> updateEvent(String eventId, CreateEventRequest request) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final response = await _supabase
          .from('events')
          .update({
            ...request.toJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', eventId)
          .eq('organizer_id', user.id) // Ensure only organizer can update
          .select()
          .single();

      return Event.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an event (only for organizers)
  Future<void> deleteEvent(String eventId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await _supabase
          .from('events')
          .update({'is_active': false})
          .eq('id', eventId)
          .eq('organizer_id', user.id); // Ensure only organizer can delete
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to get RSVP counts for events
  Future<Map<String, int>> _getRsvpCounts(List<String> eventIds) async {
    if (eventIds.isEmpty) return {};

    try {
      final response = await _supabase
          .from('event_rsvps')
          .select('event_id')
          .eq('status', RsvpStatus.attending.name)
          .inFilter('event_id', eventIds);

      final counts = <String, int>{};
      for (final rsvp in response) {
        final eventId = rsvp['event_id'] as String;
        counts[eventId] = (counts[eventId] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      return {};
    }
  }
}

/// Provider for EventService
final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

/// Provider for community events
final communityEventsProvider = FutureProvider<List<Event>>((ref) async {
  final eventService = ref.read(eventServiceProvider);
  return await eventService.getCommunityEvents();
});

/// Provider for user's events
final myEventsProvider = FutureProvider<List<Event>>((ref) async {
  final eventService = ref.read(eventServiceProvider);
  return await eventService.getMyEvents();
});

/// Provider for user's RSVP'd events
final myRsvpEventsProvider = FutureProvider<List<Event>>((ref) async {
  final eventService = ref.read(eventServiceProvider);
  return await eventService.getMyRsvpEvents();
});

/// Provider for event details
final eventDetailsProvider = FutureProvider.family<Event, String>((ref, eventId) async {
  final eventService = ref.read(eventServiceProvider);
  return await eventService.getEventDetails(eventId);
});

/// Provider for user's RSVP status for a specific event
final userRsvpStatusProvider = FutureProvider.family<RsvpStatus?, String>((ref, eventId) async {
  final eventService = ref.read(eventServiceProvider);
  return await eventService.getUserRsvpStatus(eventId);
});