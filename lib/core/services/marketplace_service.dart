import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/marketplace_listing.dart';

class MarketplaceService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Get all listings for the current user's community
  Future<List<MarketplaceListing>> getCommunityListings({
    ListingCategory? category,
    String? searchQuery,
    double? maxPrice,
    ItemCondition? condition,
  }) async {
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

      // Build query with filters (simplified to avoid foreign key issues)
      var queryBuilder = _supabase
          .from('marketplace_listings')
          .select('*')
          .eq('community_name', communityName)
          .eq('status', 'active');

      // Apply filters
      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category.name);
      }

      if (maxPrice != null) {
        queryBuilder = queryBuilder.lte('price', maxPrice);
      }

      if (condition != null) {
        String conditionValue = condition.name == 'newItem' ? 'new' : condition.name;
        queryBuilder = queryBuilder.eq('condition', conditionValue);
      }

      final response = await queryBuilder.order('created_at', ascending: false);

      // Get inquiry counts for each listing
      final listingIds = response.map((listing) => listing['id'] as String).toList();
      final inquiryCounts = await _getInquiryCounts(listingIds);

      var listings = response.map((listingData) {
        final listing = MarketplaceListing.fromJson(listingData);

        return listing.copyWith(
          sellerName: 'Community Member', // For now, use generic name
          inquiryCount: inquiryCounts[listing.id] ?? 0,
        );
      }).toList();

      // Apply search filter in-memory for better performance
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        listings = listings.where((listing) {
          return listing.title.toLowerCase().contains(query) ||
              (listing.description?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      return listings;
    } catch (e) {
      rethrow;
    }
  }

  /// Get listings created by the current user
  Future<List<MarketplaceListing>> getMyListings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final response = await _supabase
          .from('marketplace_listings')
          .select('*')
          .eq('seller_id', user.id)
          .order('created_at', ascending: false);

      // Get inquiry counts for each listing
      final listingIds = response.map((listing) => listing['id'] as String).toList();
      final inquiryCounts = await _getInquiryCounts(listingIds);

      return response.map((listingData) {
        final listing = MarketplaceListing.fromJson(listingData);
        return listing.copyWith(
          inquiryCount: inquiryCounts[listing.id] ?? 0,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new marketplace listing
  Future<MarketplaceListing> createListing(CreateListingRequest request) async {
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

      final listingData = {
        ...request.toJson(),
        'seller_id': user.id,
        'community_name': communityName,
      };

      final response = await _supabase
          .from('marketplace_listings')
          .insert(listingData)
          .select()
          .single();

      return MarketplaceListing.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get detailed listing information including inquiries
  Future<MarketplaceListing> getListingDetails(String listingId) async {
    try {
      // Get listing (simplified query)
      final listingResponse = await _supabase
          .from('marketplace_listings')
          .select('*')
          .eq('id', listingId)
          .single();

      // Get inquiry count
      final inquiryCount = await _supabase
          .from('marketplace_inquiries')
          .select('id')
          .eq('listing_id', listingId)
          .count();

      return MarketplaceListing.fromJson(listingResponse).copyWith(
        sellerName: 'Community Member', // For now, use generic name
        inquiryCount: inquiryCount.count,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update a listing (only for the seller)
  Future<MarketplaceListing> updateListing(String listingId, CreateListingRequest request) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final response = await _supabase
          .from('marketplace_listings')
          .update({
            ...request.toJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', listingId)
          .eq('seller_id', user.id) // Ensure only seller can update
          .select()
          .single();

      return MarketplaceListing.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update listing status (sold, reserved, etc.)
  Future<void> updateListingStatus(String listingId, ListingStatus status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await _supabase
          .from('marketplace_listings')
          .update({
            'status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', listingId)
          .eq('seller_id', user.id); // Ensure only seller can update
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a listing (only for the seller)
  Future<void> deleteListing(String listingId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await _supabase
          .from('marketplace_listings')
          .update({'status': 'removed'})
          .eq('id', listingId)
          .eq('seller_id', user.id); // Ensure only seller can delete
    } catch (e) {
      rethrow;
    }
  }

  /// Create an inquiry about a listing
  Future<MarketplaceInquiry> createInquiry(CreateInquiryRequest request) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Get the listing to find the seller
      final listing = await _supabase
          .from('marketplace_listings')
          .select('seller_id')
          .eq('id', request.listingId)
          .single();

      final inquiryData = {
        ...request.toJson(),
        'buyer_id': user.id,
        'seller_id': listing['seller_id'],
      };

      final response = await _supabase
          .from('marketplace_inquiries')
          .insert(inquiryData)
          .select()
          .single();

      return MarketplaceInquiry.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get inquiries for a specific listing (for sellers)
  Future<List<MarketplaceInquiry>> getListingInquiries(String listingId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final response = await _supabase
          .from('marketplace_inquiries')
          .select('*')
          .eq('listing_id', listingId)
          .eq('seller_id', user.id) // Only seller can see inquiries
          .order('created_at', ascending: false);

      return response.map((inquiryData) {
        return MarketplaceInquiry.fromJson(inquiryData).copyWith(
          buyerName: 'Community Member', // Generic name for now
          listingTitle: 'Your Item', // Generic title for now
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get inquiries made by the current user (for buyers)
  Future<List<MarketplaceInquiry>> getMyInquiries() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final response = await _supabase
          .from('marketplace_inquiries')
          .select('*')
          .eq('buyer_id', user.id)
          .order('created_at', ascending: false);

      return response.map((inquiryData) {
        return MarketplaceInquiry.fromJson(inquiryData).copyWith(
          listingTitle: 'Marketplace Item', // Generic title for now
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update inquiry status
  Future<void> updateInquiryStatus(String inquiryId, InquiryStatus status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await _supabase
          .from('marketplace_inquiries')
          .update({'status': status.name})
          .eq('id', inquiryId)
          .eq('seller_id', user.id); // Only seller can update status
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to get inquiry counts for listings
  Future<Map<String, int>> _getInquiryCounts(List<String> listingIds) async {
    if (listingIds.isEmpty) return {};

    try {
      final response = await _supabase
          .from('marketplace_inquiries')
          .select('listing_id')
          .inFilter('listing_id', listingIds);

      final counts = <String, int>{};
      for (final inquiry in response) {
        final listingId = inquiry['listing_id'] as String;
        counts[listingId] = (counts[listingId] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      return {};
    }
  }

  /// Get available categories for filtering
  List<ListingCategory> getAvailableCategories() {
    return ListingCategory.values;
  }

  /// Get available conditions for filtering
  List<ItemCondition> getAvailableConditions() {
    return ItemCondition.values;
  }
}

/// Provider for MarketplaceService
final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService();
});

/// Provider for community listings
final communityListingsProvider = FutureProvider<List<MarketplaceListing>>((ref) async {
  final marketplaceService = ref.read(marketplaceServiceProvider);
  return await marketplaceService.getCommunityListings();
});

/// Provider for user's listings
final myListingsProvider = FutureProvider<List<MarketplaceListing>>((ref) async {
  final marketplaceService = ref.read(marketplaceServiceProvider);
  return await marketplaceService.getMyListings();
});

/// Provider for listing details
final listingDetailsProvider = FutureProvider.family<MarketplaceListing, String>((ref, listingId) async {
  final marketplaceService = ref.read(marketplaceServiceProvider);
  return await marketplaceService.getListingDetails(listingId);
});

/// Provider for listing inquiries
final listingInquiriesProvider = FutureProvider.family<List<MarketplaceInquiry>, String>((ref, listingId) async {
  final marketplaceService = ref.read(marketplaceServiceProvider);
  return await marketplaceService.getListingInquiries(listingId);
});

/// Provider for user's inquiries
final myInquiriesProvider = FutureProvider<List<MarketplaceInquiry>>((ref) async {
  final marketplaceService = ref.read(marketplaceServiceProvider);
  return await marketplaceService.getMyInquiries();
});

/// Provider for filtered listings with parameters
final filteredListingsProvider = FutureProvider.family<List<MarketplaceListing>, Map<String, dynamic>>((ref, filters) async {
  final marketplaceService = ref.read(marketplaceServiceProvider);
  return await marketplaceService.getCommunityListings(
    category: filters['category'] as ListingCategory?,
    searchQuery: filters['searchQuery'] as String?,
    maxPrice: filters['maxPrice'] as double?,
    condition: filters['condition'] as ItemCondition?,
  );
});