import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import '../../core/services/user_service.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/us_states.dart';
import '../../core/config/supabase_config.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Name Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check authentication status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthenticationStatus();
    });
  }

  // Address Controllers
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();

  // Contact & Community Controllers
  final _phoneController = TextEditingController();

  String? _selectedCommunity;
  String? _selectedState;
  String _selectedCountryCode = '+1'; // Default to US
  bool _isLoading = false;

  // Community options
  final List<String> _communities = [
    'Canatarra Meadows',
    'East Village',
  ];

  // Country code options
  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'name': 'US/Canada'},
    {'code': '+91', 'name': 'India'},
  ];

  void _checkAuthenticationStatus() async {
    final currentUser = SupabaseConfig.currentUser;

    if (currentUser == null) {
      // Wait a bit for auth state to settle
      await Future.delayed(const Duration(milliseconds: 1000));

      final userAfterDelay = SupabaseConfig.currentUser;
      if (userAfterDelay == null && mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCommunity == null) {
      _showErrorSnackBar('Please select your community');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userService = ref.read(userServiceProvider);


      // Combine first and last name
      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

      // Combine address
      final addressParts = [
        _addressLine1Controller.text.trim(),
        if (_addressLine2Controller.text.trim().isNotEmpty) _addressLine2Controller.text.trim(),
        _cityController.text.trim(),
        _selectedState ?? '',
        _zipCodeController.text.trim(),
      ];
      final fullAddress = addressParts.join(', ');

      // Format phone number with country code
      final formattedPhone = '$_selectedCountryCode ${Validators.formatPhoneNumber(_phoneController.text)}';

      // Create user profile
      await userService.upsertProfile(
        fullName: fullName,
        address: fullAddress,
        communityName: _selectedCommunity!,
        phoneNumber: formattedPhone,
      );

      if (mounted) {
        // Profile created successfully, go to home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to save profile: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.neutralDark,
        automaticallyImplyLeading: false, // Prevent going back
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
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Welcome Header
                  _buildWelcomeHeader(),

                  const SizedBox(height: 24),

                  // Personal Information Section
                  _buildSectionHeader('Personal Information'),
                  const SizedBox(height: 12),
                  _buildPersonalInfoFields(),

                  const SizedBox(height: 20),

                  // Address Section
                  _buildSectionHeader('Address Information'),
                  const SizedBox(height: 12),
                  _buildAddressFields(),

                  const SizedBox(height: 20),

                  // Community & Contact Section
                  _buildSectionHeader('Community & Contact'),
                  const SizedBox(height: 12),
                  _buildCommunityAndContactFields(),

                  const SizedBox(height: 16),

                  // Privacy Notice
                  _buildPrivacyNotice(),

                  const SizedBox(height: 32),

                  // Save Profile Button
                  _buildSaveButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        AppIcons.iconWithBackground(
          icon: AppIcons.profile,
          backgroundColor: AppColors.primaryTeal,
          size: 32,
          containerSize: 80,
        ),
        const SizedBox(height: 24),
        Text(
          'Complete Your Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.neutralDark,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Please provide your details so your neighbors can find and connect with you safely.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.neutralMedium,
          ),
          textAlign: TextAlign.center,
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

  Widget _buildPersonalInfoFields() {
    return Column(
      children: [
        // First Name & Last Name Row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'First Name *',
                  hintText: 'John',
                  prefixIcon: const Icon(AppIcons.profile),
                ),
                validator: Validators.validateFirstName,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Last Name *',
                  hintText: 'Doe',
                  prefixIcon: const Icon(AppIcons.profile),
                ),
                validator: Validators.validateLastName,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressFields() {
    return Column(
      children: [
        // Address Line 1
        TextFormField(
          controller: _addressLine1Controller,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Address Line 1 *',
            hintText: '123 Main Street',
            prefixIcon: const Icon(AppIcons.location),
          ),
          validator: (value) => Validators.validateAddressLine(value, 'Address Line 1'),
        ),

        const SizedBox(height: 12),

        // Address Line 2 (Optional)
        TextFormField(
          controller: _addressLine2Controller,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Address Line 2 (Optional)',
            hintText: 'Apt 4B, Building 2',
            prefixIcon: const Icon(AppIcons.location),
          ),
        ),

        const SizedBox(height: 12),

        // City
        TextFormField(
          controller: _cityController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'City *',
            hintText: 'Austin',
            prefixIcon: const Icon(Icons.location_city_rounded),
          ),
          validator: Validators.validateCity,
        ),

        const SizedBox(height: 12),

        // State and ZIP Row
        Row(
          children: [
            // State
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: InputDecoration(
                  labelText: 'State *',
                  hintText: 'TX',
                  prefixIcon: const Icon(Icons.map_rounded),
                ),
                items: USStates.stateCodes.map((String stateCode) {
                  return DropdownMenuItem<String>(
                    value: stateCode,
                    child: Text(stateCode),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedState = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your state';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),

            // ZIP Code
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _zipCodeController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ZIP Code *',
                  hintText: '12345',
                  prefixIcon: const Icon(Icons.local_post_office_rounded),
                ),
                validator: Validators.validateZipCode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommunityAndContactFields() {
    return Column(
      children: [
        // Community Dropdown
        DropdownButtonFormField<String>(
          value: _selectedCommunity,
          decoration: InputDecoration(
            labelText: 'Community *',
            hintText: 'Select your community',
            prefixIcon: const Icon(AppIcons.apartment),
          ),
          items: _communities.map((String community) {
            return DropdownMenuItem<String>(
              value: community,
              child: Text(community),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCommunity = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your community';
            }
            return null;
          },
        ),

        const SizedBox(height: 12),

        // Phone Number with Country Code
        Row(
          children: [
            // Country Code Dropdown
            Container(
              width: 100,
              child: DropdownButtonFormField<String>(
                value: _selectedCountryCode,
                decoration: InputDecoration(
                  labelText: 'Code',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _countryCodes.map((country) {
                  return DropdownMenuItem<String>(
                    value: country['code'],
                    child: Text(country['code']!),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCountryCode = newValue ?? '+1';
                  });
                },
              ),
            ),
            const SizedBox(width: 12),

            // Phone Number Field
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleSaveProfile(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: '1234567890',
                  prefixIcon: const Icon(Icons.phone_rounded),
                  helperText: '10-digit phone number',
                ),
                validator: Validators.validatePhoneNumber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AppIcons.shield,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your information is secure and protected. Only verified community members can view your contact details. You can update your privacy settings anytime.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.neutralDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSaveProfile,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.neutralWhite),
                ),
              )
            : const Text('Complete Setup'),
      ),
    );
  }
}