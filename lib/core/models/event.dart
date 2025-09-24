enum EventCategory {
  social('Social'),
  maintenance('Maintenance'),
  emergency('Emergency'),
  sports('Sports'),
  educational('Educational'),
  community('Community');

  const EventCategory(this.displayName);
  final String displayName;

  static EventCategory fromString(String value) {
    return EventCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => EventCategory.community,
    );
  }
}

enum RsvpStatus {
  attending('Attending'),
  maybe('Maybe'),
  notAttending('Not Attending');

  const RsvpStatus(this.displayName);
  final String displayName;

  static RsvpStatus fromString(String value) {
    return RsvpStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => RsvpStatus.attending,
    );
  }
}

class Event {
  final String id;
  final String organizerId;
  final String communityName;
  final String title;
  final String? description;
  final EventCategory category;
  final DateTime eventDate;
  final String location;
  final int? maxAttendees;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for UI
  final String? organizerName;
  final int attendeeCount;
  final List<EventRsvp> rsvps;

  const Event({
    required this.id,
    required this.organizerId,
    required this.communityName,
    required this.title,
    this.description,
    required this.category,
    required this.eventDate,
    required this.location,
    this.maxAttendees,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.organizerName,
    this.attendeeCount = 0,
    this.rsvps = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? '',
      organizerId: json['organizer_id']?.toString() ?? '',
      communityName: json['community_name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      category: EventCategory.fromString(json['category']?.toString() ?? 'community'),
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'].toString())
          : DateTime.now(),
      location: json['location']?.toString() ?? '',
      maxAttendees: json['max_attendees'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      organizerName: json['organizer_name']?.toString(),
      attendeeCount: json['attendee_count'] as int? ?? 0,
      rsvps: const [], // Will be populated separately if needed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizer_id': organizerId,
      'community_name': communityName,
      'title': title,
      'description': description,
      'category': category.name,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'max_attendees': maxAttendees,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Event copyWith({
    String? id,
    String? organizerId,
    String? communityName,
    String? title,
    String? description,
    EventCategory? category,
    DateTime? eventDate,
    String? location,
    int? maxAttendees,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? organizerName,
    int? attendeeCount,
    List<EventRsvp>? rsvps,
  }) {
    return Event(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      communityName: communityName ?? this.communityName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      organizerName: organizerName ?? this.organizerName,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      rsvps: rsvps ?? this.rsvps,
    );
  }
}

class EventRsvp {
  final String id;
  final String eventId;
  final String userId;
  final RsvpStatus status;
  final DateTime rsvpDate;

  // Additional fields for UI
  final String? userName;
  final String? userCommunity;

  const EventRsvp({
    required this.id,
    required this.eventId,
    required this.userId,
    this.status = RsvpStatus.attending,
    required this.rsvpDate,
    this.userName,
    this.userCommunity,
  });

  factory EventRsvp.fromJson(Map<String, dynamic> json) {
    return EventRsvp(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      status: RsvpStatus.fromString(json['status']?.toString() ?? 'attending'),
      rsvpDate: json['rsvp_date'] != null
          ? DateTime.parse(json['rsvp_date'].toString())
          : DateTime.now(),
      userName: json['user_name']?.toString(),
      userCommunity: json['user_community']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'status': status.name,
      'rsvp_date': rsvpDate.toIso8601String(),
    };
  }

  EventRsvp copyWith({
    String? id,
    String? eventId,
    String? userId,
    RsvpStatus? status,
    DateTime? rsvpDate,
    String? userName,
    String? userCommunity,
  }) {
    return EventRsvp(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      rsvpDate: rsvpDate ?? this.rsvpDate,
      userName: userName ?? this.userName,
      userCommunity: userCommunity ?? this.userCommunity,
    );
  }
}

class CreateEventRequest {
  final String title;
  final String? description;
  final EventCategory category;
  final DateTime eventDate;
  final String location;
  final int? maxAttendees;

  const CreateEventRequest({
    required this.title,
    this.description,
    required this.category,
    required this.eventDate,
    required this.location,
    this.maxAttendees,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'max_attendees': maxAttendees,
    };
  }
}