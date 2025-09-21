import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String id;
  final String userId;
  final String fullName;
  final String firstName;
  final String address;
  final String communityName;
  final String? phoneNumber;
  final bool isVerified;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.firstName,
    required this.address,
    required this.communityName,
    this.phoneNumber,
    this.isVerified = false,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserProfile from JSON (Supabase response)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      firstName: json['first_name'] as String,
      address: json['address'] as String,
      communityName: json['community_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'first_name': firstName,
      'address': address,
      'community_name': communityName,
      'phone_number': phoneNumber,
      'is_verified': isVerified,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? firstName,
    String? address,
    String? communityName,
    String? phoneNumber,
    bool? isVerified,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      address: address ?? this.address,
      communityName: communityName ?? this.communityName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.id == id &&
        other.userId == userId &&
        other.fullName == fullName &&
        other.firstName == firstName &&
        other.address == address &&
        other.communityName == communityName &&
        other.phoneNumber == phoneNumber &&
        other.isVerified == isVerified &&
        other.profileImageUrl == profileImageUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      fullName,
      firstName,
      address,
      communityName,
      phoneNumber,
      isVerified,
      profileImageUrl,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, fullName: $fullName, firstName: $firstName, communityName: $communityName, isVerified: $isVerified)';
  }
}