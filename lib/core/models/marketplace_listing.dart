import 'package:uuid/uuid.dart';

enum ListingCategory {
  electronics('Electronics'),
  furniture('Furniture'),
  clothing('Clothing'),
  books('Books'),
  toys('Toys'),
  sports('Sports'),
  tools('Tools'),
  garden('Garden'),
  vehicles('Vehicles'),
  other('Other');

  const ListingCategory(this.displayName);
  final String displayName;

  static ListingCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'electronics':
        return ListingCategory.electronics;
      case 'furniture':
        return ListingCategory.furniture;
      case 'clothing':
        return ListingCategory.clothing;
      case 'books':
        return ListingCategory.books;
      case 'toys':
        return ListingCategory.toys;
      case 'sports':
        return ListingCategory.sports;
      case 'tools':
        return ListingCategory.tools;
      case 'garden':
        return ListingCategory.garden;
      case 'vehicles':
        return ListingCategory.vehicles;
      default:
        return ListingCategory.other;
    }
  }
}

enum ItemCondition {
  newItem('New'),
  likeNew('Like New'),
  good('Good'),
  fair('Fair'),
  poor('Poor');

  const ItemCondition(this.displayName);
  final String displayName;

  static ItemCondition fromString(String value) {
    switch (value.toLowerCase()) {
      case 'new':
        return ItemCondition.newItem;
      case 'like_new':
        return ItemCondition.likeNew;
      case 'good':
        return ItemCondition.good;
      case 'fair':
        return ItemCondition.fair;
      case 'poor':
        return ItemCondition.poor;
      default:
        return ItemCondition.good;
    }
  }
}

enum ListingStatus {
  active('Active'),
  sold('Sold'),
  reserved('Reserved'),
  removed('Removed');

  const ListingStatus(this.displayName);
  final String displayName;

  static ListingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return ListingStatus.active;
      case 'sold':
        return ListingStatus.sold;
      case 'reserved':
        return ListingStatus.reserved;
      case 'removed':
        return ListingStatus.removed;
      default:
        return ListingStatus.active;
    }
  }
}

enum InquiryType {
  interest('Interest'),
  question('Question'),
  offer('Offer'),
  meetingRequest('Meeting Request');

  const InquiryType(this.displayName);
  final String displayName;

  static InquiryType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'interest':
        return InquiryType.interest;
      case 'question':
        return InquiryType.question;
      case 'offer':
        return InquiryType.offer;
      case 'meeting_request':
        return InquiryType.meetingRequest;
      default:
        return InquiryType.interest;
    }
  }
}

enum InquiryStatus {
  open('Open'),
  responded('Responded'),
  closed('Closed');

  const InquiryStatus(this.displayName);
  final String displayName;

  static InquiryStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'open':
        return InquiryStatus.open;
      case 'responded':
        return InquiryStatus.responded;
      case 'closed':
        return InquiryStatus.closed;
      default:
        return InquiryStatus.open;
    }
  }
}

class MarketplaceListing {
  final String id;
  final String sellerId;
  final String communityName;
  final String title;
  final String? description;
  final ListingCategory category;
  final ItemCondition condition;
  final double price;
  final String currency;
  final bool isNegotiable;
  final ListingStatus status;
  final String? locationDetails;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  // UI-only fields
  final String? sellerName;
  final int inquiryCount;

  const MarketplaceListing({
    required this.id,
    required this.sellerId,
    required this.communityName,
    required this.title,
    this.description,
    required this.category,
    required this.condition,
    required this.price,
    this.currency = 'USD',
    this.isNegotiable = false,
    this.status = ListingStatus.active,
    this.locationDetails,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    this.sellerName,
    this.inquiryCount = 0,
  });

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    return MarketplaceListing(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      communityName: json['community_name'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: ListingCategory.fromString(json['category'] as String),
      condition: ItemCondition.fromString(json['condition'] as String),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      status: ListingStatus.fromString(json['status'] as String? ?? 'active'),
      locationDetails: json['location_details'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sellerName: json['seller_name'] as String?,
      inquiryCount: json['inquiry_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'community_name': communityName,
      'title': title,
      'description': description,
      'category': category.name,
      'condition': condition.name == 'newItem' ? 'new' : condition.name,
      'price': price,
      'currency': currency,
      'is_negotiable': isNegotiable,
      'status': status.name,
      'location_details': locationDetails,
      'images': images,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MarketplaceListing copyWith({
    String? id,
    String? sellerId,
    String? communityName,
    String? title,
    String? description,
    ListingCategory? category,
    ItemCondition? condition,
    double? price,
    String? currency,
    bool? isNegotiable,
    ListingStatus? status,
    String? locationDetails,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sellerName,
    int? inquiryCount,
  }) {
    return MarketplaceListing(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      communityName: communityName ?? this.communityName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      status: status ?? this.status,
      locationDetails: locationDetails ?? this.locationDetails,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sellerName: sellerName ?? this.sellerName,
      inquiryCount: inquiryCount ?? this.inquiryCount,
    );
  }

  String get formattedPrice {
    if (currency == 'USD') {
      return '\$${price.toStringAsFixed(2)}';
    }
    return '$currency ${price.toStringAsFixed(2)}';
  }

  String get priceWithNegotiable {
    String basePrice = formattedPrice;
    return isNegotiable ? '$basePrice (negotiable)' : basePrice;
  }
}

class MarketplaceInquiry {
  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final String message;
  final InquiryType inquiryType;
  final double? offeredPrice;
  final InquiryStatus status;
  final DateTime createdAt;

  // UI-only fields
  final String? buyerName;
  final String? listingTitle;

  const MarketplaceInquiry({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.message,
    this.inquiryType = InquiryType.interest,
    this.offeredPrice,
    this.status = InquiryStatus.open,
    required this.createdAt,
    this.buyerName,
    this.listingTitle,
  });

  factory MarketplaceInquiry.fromJson(Map<String, dynamic> json) {
    return MarketplaceInquiry(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      message: json['message'] as String,
      inquiryType: InquiryType.fromString(json['inquiry_type'] as String? ?? 'interest'),
      offeredPrice: (json['offered_price'] as num?)?.toDouble(),
      status: InquiryStatus.fromString(json['status'] as String? ?? 'open'),
      createdAt: DateTime.parse(json['created_at'] as String),
      buyerName: json['buyer_name'] as String?,
      listingTitle: json['listing_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'message': message,
      'inquiry_type': inquiryType.name == 'meetingRequest' ? 'meeting_request' : inquiryType.name,
      'offered_price': offeredPrice,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MarketplaceInquiry copyWith({
    String? id,
    String? listingId,
    String? buyerId,
    String? sellerId,
    String? message,
    InquiryType? inquiryType,
    double? offeredPrice,
    InquiryStatus? status,
    DateTime? createdAt,
    String? buyerName,
    String? listingTitle,
  }) {
    return MarketplaceInquiry(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      message: message ?? this.message,
      inquiryType: inquiryType ?? this.inquiryType,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      buyerName: buyerName ?? this.buyerName,
      listingTitle: listingTitle ?? this.listingTitle,
    );
  }
}

class CreateListingRequest {
  final String title;
  final String? description;
  final ListingCategory category;
  final ItemCondition condition;
  final double price;
  final String currency;
  final bool isNegotiable;
  final String? locationDetails;
  final List<String> images;

  const CreateListingRequest({
    required this.title,
    this.description,
    required this.category,
    required this.condition,
    required this.price,
    this.currency = 'USD',
    this.isNegotiable = false,
    this.locationDetails,
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'condition': condition.name == 'newItem' ? 'new' : condition.name,
      'price': price,
      'currency': currency,
      'is_negotiable': isNegotiable,
      'location_details': locationDetails,
      'images': images,
    };
  }
}

class CreateInquiryRequest {
  final String listingId;
  final String message;
  final InquiryType inquiryType;
  final double? offeredPrice;

  const CreateInquiryRequest({
    required this.listingId,
    required this.message,
    this.inquiryType = InquiryType.interest,
    this.offeredPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'listing_id': listingId,
      'message': message,
      'inquiry_type': inquiryType.name == 'meetingRequest' ? 'meeting_request' : inquiryType.name,
      'offered_price': offeredPrice,
    };
  }
}