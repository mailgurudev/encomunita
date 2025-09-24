import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/models/marketplace_listing.dart';
import '../../core/services/marketplace_service.dart';
import '../../core/config/supabase_config.dart';

class ListingDetailsScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailsScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends ConsumerState<ListingDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isContactLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailsProvider(widget.listingId));

    return Scaffold(
      body: listingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
        error: (error, stack) => _buildErrorState(error.toString()),
        data: (listing) => _buildListingDetails(listing),
      ),
    );
  }

  Widget _buildListingDetails(MarketplaceListing listing) {
    final currentUser = SupabaseConfig.currentUser;
    final isOwnListing = listing.sellerId == currentUser?.id;

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(listing),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildListingHeader(listing),
              const SizedBox(height: 24),
              _buildPriceSection(listing),
              const SizedBox(height: 24),
              _buildDetailsSection(listing),
              const SizedBox(height: 24),
              if (listing.description != null) ...[
                _buildDescription(listing.description!),
                const SizedBox(height: 24),
              ],
              _buildSellerInfo(listing),
              const SizedBox(height: 24),
              if (listing.locationDetails != null) ...[
                _buildLocationInfo(listing.locationDetails!),
                const SizedBox(height: 24),
              ],
              if (!isOwnListing) _buildContactSection(listing),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(MarketplaceListing listing) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.neutralWhite,
      foregroundColor: AppColors.neutralDark,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildImageCarousel(listing.images),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            _showSuccessSnackBar('Share functionality will be implemented');
          },
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Container(
        color: AppColors.neutralLight,
        child: Center(
          child: Icon(
            AppIcons.marketplace,
            size: 80,
            color: AppColors.neutralMedium,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Container(
              color: AppColors.neutralLight,
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 80,
                  color: AppColors.neutralMedium,
                ),
              ),
            );
          },
        ),
        if (images.length > 1) ...[
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentImageIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildListingHeader(MarketplaceListing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getCategoryColor(listing.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                listing.category.displayName,
                style: TextStyle(
                  color: _getCategoryColor(listing.category),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getConditionColor(listing.condition).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                listing.condition.displayName,
                style: TextStyle(
                  color: _getConditionColor(listing.condition),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          listing.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutralDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(MarketplaceListing listing) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(
              listing.formattedPrice,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTeal,
              ),
            ),
            if (listing.isNegotiable) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Negotiable',
                  style: TextStyle(
                    color: AppColors.accentOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(MarketplaceListing listing) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.neutralDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.category,
              title: 'Category',
              content: listing.category.displayName,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.star_border,
              title: 'Condition',
              content: listing.condition.displayName,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.schedule,
              title: 'Posted',
              content: _getTimeAgo(listing.createdAt),
            ),
            if (listing.inquiryCount > 0) ...[
              const Divider(height: 24),
              _buildDetailRow(
                icon: Icons.message,
                title: 'Interest',
                content: '${listing.inquiryCount} inquiries',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
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
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutralMedium,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
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
    );
  }

  Widget _buildDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
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

  Widget _buildSellerInfo(MarketplaceListing listing) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryCoral,
              child: Text(
                (listing.sellerName ?? 'U')[0].toUpperCase(),
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
                    'Seller',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.neutralMedium,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    listing.sellerName ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutralDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.verified_user,
              color: AppColors.success,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String locationDetails) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppIcons.location,
                color: AppColors.info,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pickup Location',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.neutralMedium,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locationDetails,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildContactSection(MarketplaceListing listing) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isContactLoading ? null : () => _handleContactSeller(listing),
            icon: _isContactLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.message, color: Colors.white),
            label: Text(
              _isContactLoading ? 'Sending...' : 'Contact Seller',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (listing.isNegotiable)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _handleMakeOffer(listing),
              icon: const Icon(Icons.local_offer),
              label: const Text('Make Offer'),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
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
                'Error loading item',
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

  Future<void> _handleContactSeller(MarketplaceListing listing) async {
    setState(() => _isContactLoading = true);

    try {
      final marketplaceService = ref.read(marketplaceServiceProvider);

      final inquiry = CreateInquiryRequest(
        listingId: listing.id,
        message: 'Hi! I\'m interested in your ${listing.title}. Is it still available?',
        inquiryType: InquiryType.interest,
      );

      await marketplaceService.createInquiry(inquiry);

      if (mounted) {
        _showSuccessSnackBar('Message sent to seller!');
        ref.invalidate(listingDetailsProvider(widget.listingId));
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to contact seller: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isContactLoading = false);
      }
    }
  }

  void _handleMakeOffer(MarketplaceListing listing) {
    showDialog(
      context: context,
      builder: (context) => _buildOfferDialog(listing),
    );
  }

  Widget _buildOfferDialog(MarketplaceListing listing) {
    final offerController = TextEditingController();
    final messageController = TextEditingController();

    return AlertDialog(
      title: const Text('Make an Offer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current price: ${listing.formattedPrice}'),
          const SizedBox(height: 16),
          TextFormField(
            controller: offerController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Your Offer',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Message (Optional)',
              hintText: 'Add a message with your offer...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final offer = double.tryParse(offerController.text);
            if (offer != null && offer > 0) {
              Navigator.of(context).pop();
              await _sendOffer(listing, offer, messageController.text);
            }
          },
          child: const Text('Send Offer'),
        ),
      ],
    );
  }

  Future<void> _sendOffer(MarketplaceListing listing, double offer, String message) async {
    try {
      final marketplaceService = ref.read(marketplaceServiceProvider);

      final inquiry = CreateInquiryRequest(
        listingId: listing.id,
        message: message.isNotEmpty
            ? message
            : 'I\'d like to offer \$${offer.toStringAsFixed(2)} for your ${listing.title}.',
        inquiryType: InquiryType.offer,
        offeredPrice: offer,
      );

      await marketplaceService.createInquiry(inquiry);

      if (mounted) {
        _showSuccessSnackBar('Offer sent to seller!');
        ref.invalidate(listingDetailsProvider(widget.listingId));
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to send offer: ${e.toString()}');
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

  Color _getCategoryColor(ListingCategory category) {
    switch (category) {
      case ListingCategory.electronics:
        return AppColors.info;
      case ListingCategory.furniture:
        return AppColors.primaryCoral;
      case ListingCategory.clothing:
        return AppColors.accentPurple;
      case ListingCategory.books:
        return AppColors.primaryTeal;
      case ListingCategory.toys:
        return AppColors.accentOrange;
      case ListingCategory.sports:
        return AppColors.success;
      case ListingCategory.tools:
        return AppColors.warning;
      case ListingCategory.garden:
        return Colors.green;
      case ListingCategory.vehicles:
        return Colors.blue;
      case ListingCategory.other:
        return AppColors.neutralMedium;
    }
  }

  Color _getConditionColor(ItemCondition condition) {
    switch (condition) {
      case ItemCondition.newItem:
        return AppColors.success;
      case ItemCondition.likeNew:
        return AppColors.primaryTeal;
      case ItemCondition.good:
        return AppColors.info;
      case ItemCondition.fair:
        return AppColors.warning;
      case ItemCondition.poor:
        return AppColors.error;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}