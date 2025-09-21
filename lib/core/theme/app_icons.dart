import 'package:flutter/material.dart';

/// App Icons - Community-focused icon system for Encomunita
/// Uses Material Icons with semantic naming for easy maintenance
class AppIcons {
  // Navigation Icons
  static const IconData home = Icons.home_rounded;
  static const IconData community = Icons.people_rounded;
  static const IconData marketplace = Icons.storefront_rounded;
  static const IconData events = Icons.celebration_rounded;
  static const IconData profile = Icons.person_rounded;
  static const IconData menu = Icons.menu_rounded;
  static const IconData back = Icons.arrow_back_ios_rounded;
  static const IconData close = Icons.close_rounded;

  // Authentication Icons
  static const IconData login = Icons.login_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData signup = Icons.person_add_rounded;
  static const IconData email = Icons.email_rounded;
  static const IconData password = Icons.lock_rounded;
  static const IconData visibility = Icons.visibility_rounded;
  static const IconData visibilityOff = Icons.visibility_off_rounded;

  // Community Features
  static const IconData neighborhood = Icons.location_city_rounded;
  static const IconData apartment = Icons.apartment_rounded;
  static const IconData family = Icons.family_restroom_rounded;
  static const IconData residents = Icons.groups_rounded;
  static const IconData announcement = Icons.campaign_rounded;
  static const IconData bulletin = Icons.article_rounded;

  // Events & Social
  static const IconData calendar = Icons.calendar_month_rounded;
  static const IconData party = Icons.cake_rounded;
  static const IconData festival = Icons.festival_rounded;
  static const IconData playdate = Icons.child_friendly_rounded;
  static const IconData sports = Icons.sports_soccer_rounded;
  static const IconData music = Icons.music_note_rounded;
  static const IconData art = Icons.palette_rounded;

  // Marketplace & Services
  static const IconData sell = Icons.sell_rounded;
  static const IconData buy = Icons.shopping_cart_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData book = Icons.menu_book_rounded;
  static const IconData delivery = Icons.delivery_dining_rounded;
  static const IconData deals = Icons.local_offer_rounded;

  // Food Services
  static const IconData restaurant = Icons.restaurant_rounded;
  static const IconData chef = Icons.restaurant_menu_rounded;
  static const IconData bakery = Icons.bakery_dining_rounded;
  static const IconData tiffin = Icons.lunch_dining_rounded;
  static const IconData rating = Icons.star_rounded;
  static const IconData review = Icons.rate_review_rounded;

  // Jobs & Services
  static const IconData job = Icons.work_rounded;
  static const IconData referral = Icons.person_search_rounded;
  static const IconData babysitter = Icons.child_care_rounded;
  static const IconData tutor = Icons.school_rounded;
  static const IconData houseHelp = Icons.cleaning_services_rounded;
  static const IconData nanny = Icons.escalator_warning_rounded;

  // Transportation
  static const IconData carpool = Icons.directions_car_rounded;
  static const IconData rideshare = Icons.groups_2_rounded;
  static const IconData location = Icons.location_on_rounded;
  static const IconData map = Icons.map_rounded;

  // Communication
  static const IconData chat = Icons.chat_rounded;
  static const IconData message = Icons.message_rounded;
  static const IconData notification = Icons.notifications_rounded;
  static const IconData comment = Icons.comment_rounded;
  static const IconData like = Icons.favorite_rounded;
  static const IconData reply = Icons.reply_rounded;

  // Safety & Security
  static const IconData security = Icons.security_rounded;
  static const IconData emergency = Icons.emergency_rounded;
  static const IconData report = Icons.report_rounded;
  static const IconData verified = Icons.verified_rounded;
  static const IconData shield = Icons.shield_rounded;

  // Settings & Admin
  static const IconData settings = Icons.settings_rounded;
  static const IconData admin = Icons.admin_panel_settings_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData add = Icons.add_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData search = Icons.search_rounded;

  // Status Icons
  static const IconData success = Icons.check_circle_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData warning = Icons.warning_rounded;
  static const IconData info = Icons.info_rounded;
  static const IconData loading = Icons.hourglass_empty_rounded;

  // Media & Content
  static const IconData photo = Icons.photo_rounded;
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData video = Icons.videocam_rounded;
  static const IconData file = Icons.attach_file_rounded;
  static const IconData download = Icons.download_rounded;

  // Time & Date
  static const IconData time = Icons.access_time_rounded;
  static const IconData date = Icons.date_range_rounded;
  static const IconData schedule = Icons.schedule_rounded;

  // Utility Functions
  static Widget iconWithBackground({
    required IconData icon,
    required Color backgroundColor,
    Color iconColor = Colors.white,
    double size = 24,
    double containerSize = 48,
  }) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(containerSize / 4),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: size,
      ),
    );
  }

  static Widget categoryIcon({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWithBackground(
            icon: icon,
            backgroundColor: color.withOpacity(0.1),
            iconColor: color,
            size: 28,
            containerSize: 56,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Feature Category Icons with Colors
class FeatureIcons {
  static const Map<String, Map<String, dynamic>> categories = {
    'events': {
      'icon': AppIcons.events,
      'color': Color(0xFFFF6B6B), // Coral
      'label': 'Events',
    },
    'marketplace': {
      'icon': AppIcons.marketplace,
      'color': Color(0xFF4ECDC4), // Teal
      'label': 'Marketplace',
    },
    'food': {
      'icon': AppIcons.restaurant,
      'color': Color(0xFFFFE66D), // Yellow
      'label': 'Food',
    },
    'jobs': {
      'icon': AppIcons.job,
      'color': Color(0xFF9B72CF), // Purple
      'label': 'Jobs',
    },
    'transport': {
      'icon': AppIcons.carpool,
      'color': Color(0xFF74A9E6), // Blue
      'label': 'Transport',
    },
    'community': {
      'icon': AppIcons.community,
      'color': Color(0xFF68D391), // Green
      'label': 'Community',
    },
  };

  static Widget getCategoryIcon(String category, {double size = 24}) {
    final categoryData = categories[category];
    if (categoryData == null) return const SizedBox.shrink();

    return AppIcons.iconWithBackground(
      icon: categoryData['icon'] as IconData,
      backgroundColor: categoryData['color'] as Color,
      size: size,
      containerSize: size * 2,
    );
  }
}