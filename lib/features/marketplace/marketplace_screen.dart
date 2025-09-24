import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/models/marketplace_listing.dart';
import '../../core/services/marketplace_service.dart';
import 'create_listing_screen.dart';
import 'listing_details_screen.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Marketplace'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.neutralDark,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'My Listings'),
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
            _buildBrowseTab(),
            _buildMyListingsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateListingScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primaryCoral,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBrowseTab() {
    final listingsAsync = ref.watch(communityListingsProvider);

    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: listingsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal),
            ),
            error: (error, stack) => _buildErrorState(error.toString()),
            data: (listings) => _buildListingsView(listings),
          ),
        ),
      ],
    );
  }

  Widget _buildMyListingsTab() {
    final listingsAsync = ref.watch(myListingsProvider);

    return listingsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTeal),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (listings) => _buildMyListingsView(listings),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.neutralLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.neutralLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryTeal),
              ),
            ),
            onChanged: (value) {
              // TODO: Implement search functionality
            },
          ),
          const SizedBox(height: 12),
          // Category filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All', true),
                ...ListingCategory.values.map((category) =>
                    _buildCategoryChip(category.displayName, false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // TODO: Implement category filtering
        },
        selectedColor: AppColors.primaryTeal.withOpacity(0.2),
        checkmarkColor: AppColors.primaryTeal,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryTeal : AppColors.neutralMedium,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildListingsView(List<MarketplaceListing> listings) {
    if (listings.isEmpty) {
      return _buildEmptyState('No items for sale in your community yet.');
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(communityListingsProvider);
      },
      child: _isGridView ? _buildGridView(listings) : _buildListView(listings),
    );
  }

  Widget _buildGridView(List<MarketplaceListing> listings) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        return _buildListingCard(listings[index]);
      },
    );
  }

  Widget _buildListView(List<MarketplaceListing> listings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        return _buildListingListTile(listings[index]);
      },
    );
  }

  Widget _buildListingCard(MarketplaceListing listing) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ListingDetailsScreen(listingId: listing.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: AppColors.neutralLight,
                child: listing.images.isNotEmpty
                    ? Image.network(
                        listing.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        listing.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.formattedPrice,
                      style: TextStyle(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getConditionColor(listing.condition).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              listing.condition.displayName,
                              style: TextStyle(
                                color: _getConditionColor(listing.condition),
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        if (listing.inquiryCount > 0) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.message,
                            size: 10,
                            color: AppColors.neutralMedium,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${listing.inquiryCount}',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.neutralMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingListTile(MarketplaceListing listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ListingDetailsScreen(listingId: listing.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.neutralLight,
                ),
                child: listing.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          listing.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : _buildImagePlaceholder(),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (listing.description != null)
                      Text(
                        listing.description!,
                        style: TextStyle(
                          color: AppColors.neutralMedium,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          listing.formattedPrice,
                          style: TextStyle(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (listing.isNegotiable) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Negotiable',
                              style: TextStyle(
                                color: AppColors.accentOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getConditionColor(listing.condition).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            listing.condition.displayName,
                            style: TextStyle(
                              color: _getConditionColor(listing.condition),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyListingsView(List<MarketplaceListing> listings) {
    if (listings.isEmpty) {
      return _buildEmptyState('You haven\'t posted any items yet.');
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myListingsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          return _buildMyListingCard(listings[index]);
        },
      ),
    );
  }

  Widget _buildMyListingCard(MarketplaceListing listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    listing.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(listing.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    listing.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(listing.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              listing.formattedPrice,
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.visibility,
                  size: 16,
                  color: AppColors.neutralMedium,
                ),
                const SizedBox(width: 4),
                Text(
                  '${listing.inquiryCount} inquiries',
                  style: TextStyle(
                    color: AppColors.neutralMedium,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  'Posted ${_getTimeAgo(listing.createdAt)}',
                  style: TextStyle(
                    color: AppColors.neutralMedium,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.neutralLight,
      child: Icon(
        AppIcons.marketplace,
        color: AppColors.neutralMedium,
        size: 40,
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
              AppIcons.marketplace,
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
                    builder: (context) => const CreateListingScreen(),
                  ),
                );
              },
              child: const Text('Post First Item'),
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
              'Error loading items',
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
                ref.invalidate(communityListingsProvider);
                ref.invalidate(myListingsProvider);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
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

  Color _getStatusColor(ListingStatus status) {
    switch (status) {
      case ListingStatus.active:
        return AppColors.success;
      case ListingStatus.sold:
        return AppColors.neutralMedium;
      case ListingStatus.reserved:
        return AppColors.warning;
      case ListingStatus.removed:
        return AppColors.error;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}