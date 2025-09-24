import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/services/user_service.dart';
import '../events/events_screen.dart';
import '../marketplace/marketplace_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encomunita'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.logout),
            onPressed: () async {
              try {
                await ref.read(userServiceProvider).signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/welcome');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error signing out: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryCoral.withOpacity(0.05),
              AppColors.primaryTeal.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Welcome Header
                _buildWelcomeHeader(userProfileAsync),

                const SizedBox(height: 32),

                // Quick Actions
                _buildQuickActions(context),

                const SizedBox(height: 32),

                // Community Feed Placeholder
                _buildCommunityFeed(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(AsyncValue userProfileAsync) {
    return userProfileAsync.when(
      data: (profile) {
        final firstName = profile?.firstName ?? 'there';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.neutralMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$firstName! 👋',
              style: TextStyle(
                fontSize: 28,
                color: AppColors.neutralDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (profile?.communityName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    AppIcons.location,
                    size: 16,
                    color: AppColors.neutralMedium,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile!.communityName,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.neutralMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => Text(
        'Welcome back! 👋',
        style: TextStyle(
          fontSize: 28,
          color: AppColors.neutralDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.neutralDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.0,
          children: [
            _buildActionCard(
              context,
              icon: AppIcons.events,
              title: 'Events',
              subtitle: 'Join community events',
              color: AppColors.primaryCoral,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EventsScreen(),
                  ),
                );
              },
            ),
            _buildActionCard(
              context,
              icon: AppIcons.marketplace,
              title: 'Marketplace',
              subtitle: 'Buy & sell items',
              color: AppColors.primaryTeal,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MarketplaceScreen(),
                  ),
                );
              },
            ),
            _buildActionCard(
              context,
              icon: AppIcons.restaurant,
              title: 'Food Services',
              subtitle: 'Chefs & tiffin',
              color: AppColors.accentOrange,
              onTap: () {
                // TODO: Navigate to food services
              },
            ),
            _buildActionCard(
              context,
              icon: AppIcons.job,
              title: 'Jobs & Services',
              subtitle: 'Find opportunities',
              color: AppColors.accentPurple,
              onTap: () {
                // TODO: Navigate to jobs
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Feed',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.neutralDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.neutralWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neutralLight,
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.community,
                  size: 64,
                  color: AppColors.neutralMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Community Feed Coming Soon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay tuned for community updates,\nannouncements, and neighbor posts.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutralMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}