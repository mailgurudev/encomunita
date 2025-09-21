import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryCoral.withOpacity(0.1),
              AppColors.primaryTeal.withOpacity(0.1),
              AppColors.accentOrange.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // App Logo & Branding
                _buildAppLogo(),

                const SizedBox(height: 32),

                // Welcome Message
                _buildWelcomeMessage(),

                const SizedBox(height: 24),

                // Feature Preview
                _buildFeaturePreview(),

                const SizedBox(height: 40),

                // Action Buttons
                _buildActionButtons(context),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Column(
      children: [
        // App Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryCoral,
                AppColors.primaryTeal,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCoral.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            AppIcons.community,
            size: 60,
            color: AppColors.neutralWhite,
          ),
        ),

        const SizedBox(height: 24),

        // App Name
        const Text(
          'Encomunita',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.neutralDark,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        // Tagline
        Text(
          'Building Stronger Communities Together',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.neutralMedium,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          'Connect with your neighbors',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.neutralDark,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          'Organize events, share resources, find services, and build lasting relationships in your community.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.neutralMedium,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturePreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralMedium.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'What you can do',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDark,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeatureItem(
                icon: AppIcons.events,
                label: 'Events',
                color: AppColors.primaryCoral,
              ),
              _buildFeatureItem(
                icon: AppIcons.marketplace,
                label: 'Marketplace',
                color: AppColors.primaryTeal,
              ),
              _buildFeatureItem(
                icon: AppIcons.restaurant,
                label: 'Food',
                color: AppColors.accentOrange,
              ),
              _buildFeatureItem(
                icon: AppIcons.job,
                label: 'Jobs',
                color: AppColors.accentPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.neutralDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary Action - Sign Up
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/signup');
            },
            child: const Text('Get Started'),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Action - Log In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
            child: const Text('I already have an account'),
          ),
        ),
      ],
    );
  }
}