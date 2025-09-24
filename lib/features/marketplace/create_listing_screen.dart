import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/models/marketplace_listing.dart';
import '../../core/services/marketplace_service.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  ListingCategory _selectedCategory = ListingCategory.other;
  ItemCondition _selectedCondition = ItemCondition.good;
  bool _isNegotiable = false;
  bool _isLoading = false;
  List<String> _images = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Item'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.neutralDark,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleCreateListing,
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
                    'Post',
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
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildPhotoSection(),
                  const SizedBox(height: 20),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 20),
                  _buildPricingSection(),
                  const SizedBox(height: 20),
                  _buildDetailsSection(),
                  const SizedBox(height: 32),
                  _buildPostButton(),
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
          icon: AppIcons.marketplace,
          backgroundColor: AppColors.primaryCoral,
          size: 32,
          containerSize: 80,
        ),
        const SizedBox(height: 16),
        Text(
          'Post an Item',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.neutralDark,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Share items with your community',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.neutralMedium,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Photos'),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.neutralLight,
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _images.isEmpty
              ? _buildPhotoPlaceholder()
              : _buildPhotoGrid(),
        ),
        const SizedBox(height: 8),
        Text(
          'Add up to 5 photos to showcase your item',
          style: TextStyle(
            color: AppColors.neutralMedium,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder() {
    return InkWell(
      onTap: _addPhoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.neutralLight.withOpacity(0.3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 48,
              color: AppColors.neutralMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Photos',
              style: TextStyle(
                color: AppColors.neutralMedium,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to add photos of your item',
              style: TextStyle(
                color: AppColors.neutralMedium,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _images.length + (_images.length < 5 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _images.length) {
          return _buildAddPhotoButton();
        }
        return _buildPhotoItem(_images[index], index);
      },
    );
  }

  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: _addPhoto,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutralLight),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.add,
          color: AppColors.neutralMedium,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildPhotoItem(String imagePath, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.neutralLight,
          ),
          child: const Center(
            child: Icon(Icons.image, color: Colors.grey),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _removePhoto(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Item Details'),
        const SizedBox(height: 12),

        // Item Title
        TextFormField(
          controller: _titleController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Item Title *',
            hintText: 'What are you selling?',
            prefixIcon: const Icon(AppIcons.marketplace),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an item title';
            }
            if (value.trim().length < 3) {
              return 'Title must be at least 3 characters';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Category Selection
        DropdownButtonFormField<ListingCategory>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category *',
            prefixIcon: Icon(_getCategoryIcon(_selectedCategory)),
          ),
          items: ListingCategory.values.map((category) {
            return DropdownMenuItem<ListingCategory>(
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
          onChanged: (ListingCategory? newValue) {
            setState(() {
              _selectedCategory = newValue ?? ListingCategory.other;
            });
          },
        ),

        const SizedBox(height: 16),

        // Condition Selection
        DropdownButtonFormField<ItemCondition>(
          value: _selectedCondition,
          decoration: InputDecoration(
            labelText: 'Condition *',
            prefixIcon: Icon(_getConditionIcon(_selectedCondition)),
          ),
          items: ItemCondition.values.map((condition) {
            return DropdownMenuItem<ItemCondition>(
              value: condition,
              child: Row(
                children: [
                  Icon(
                    _getConditionIcon(condition),
                    size: 20,
                    color: _getConditionColor(condition),
                  ),
                  const SizedBox(width: 8),
                  Text(condition.displayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (ItemCondition? newValue) {
            setState(() {
              _selectedCondition = newValue ?? ItemCondition.good;
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
            hintText: 'Describe your item, its features, and condition...',
            prefixIcon: const Icon(AppIcons.comment),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Pricing'),
        const SizedBox(height: 12),

        // Price
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: 'Price *',
            hintText: '0.00',
            prefixText: '\$ ',
            prefixIcon: const Icon(Icons.attach_money),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a price';
            }
            final price = double.tryParse(value.trim());
            if (price == null || price <= 0) {
              return 'Please enter a valid price';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Negotiable checkbox
        CheckboxListTile(
          value: _isNegotiable,
          onChanged: (value) {
            setState(() {
              _isNegotiable = value ?? false;
            });
          },
          title: const Text('Price is negotiable'),
          subtitle: const Text('Allow buyers to make offers'),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primaryTeal,
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Location & Pickup'),
        const SizedBox(height: 12),

        TextFormField(
          controller: _locationController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Pickup Details (Optional)',
            hintText: 'Building A, Apt 101, or "flexible"',
            prefixIcon: const Icon(AppIcons.location),
          ),
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

  Widget _buildPostButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreateListing,
        child: _isLoading
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.neutralWhite),
              )
            : const Text('Post Item'),
      ),
    );
  }

  void _addPhoto() {
    if (_images.length < 5) {
      setState(() {
        _images.add('dummy_image_${_images.length + 1}');
      });
      _showSuccessSnackBar('Photo added! (Image upload will be implemented)');
    } else {
      _showErrorSnackBar('Maximum 5 photos allowed');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _handleCreateListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final marketplaceService = ref.read(marketplaceServiceProvider);

      final price = double.parse(_priceController.text.trim());

      final request = CreateListingRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        condition: _selectedCondition,
        price: price,
        isNegotiable: _isNegotiable,
        locationDetails: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        images: _images,
      );

      await marketplaceService.createListing(request);

      if (mounted) {
        // Refresh listings
        ref.invalidate(communityListingsProvider);
        ref.invalidate(myListingsProvider);

        _showSuccessSnackBar('Item posted successfully!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to post item: ${e.toString()}');
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

  IconData _getCategoryIcon(ListingCategory category) {
    switch (category) {
      case ListingCategory.electronics:
        return Icons.devices;
      case ListingCategory.furniture:
        return Icons.chair;
      case ListingCategory.clothing:
        return Icons.checkroom;
      case ListingCategory.books:
        return Icons.menu_book;
      case ListingCategory.toys:
        return Icons.toys;
      case ListingCategory.sports:
        return AppIcons.sports;
      case ListingCategory.tools:
        return Icons.build;
      case ListingCategory.garden:
        return Icons.grass;
      case ListingCategory.vehicles:
        return Icons.directions_car;
      case ListingCategory.other:
        return Icons.category;
    }
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

  IconData _getConditionIcon(ItemCondition condition) {
    switch (condition) {
      case ItemCondition.newItem:
        return Icons.new_releases;
      case ItemCondition.likeNew:
        return Icons.star;
      case ItemCondition.good:
        return Icons.thumb_up;
      case ItemCondition.fair:
        return Icons.remove_circle_outline;
      case ItemCondition.poor:
        return Icons.thumb_down;
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
}