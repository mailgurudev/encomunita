/// Input validation utilities for form fields
class Validators {
  // Common email domains for validation
  static const List<String> _validEmailDomains = [
    'gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'icloud.com',
    'aol.com', 'protonmail.com', 'zoho.com', 'mail.com', 'yandex.com',
    'live.com', 'msn.com', 'me.com', 'mac.com', 'comcast.net',
    'verizon.net', 'att.net', 'cox.net', 'sbcglobal.net', 'charter.net',
  ];

  /// Validate email address with domain checking
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }

    final email = value.trim().toLowerCase();

    // Basic email regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Extract domain
    final domain = email.split('@').last;

    // Check if domain is in our whitelist or looks legitimate
    if (!_validEmailDomains.contains(domain) && !_isValidDomain(domain)) {
      return 'Please use a valid email provider (Gmail, Yahoo, Outlook, etc.)';
    }

    return null;
  }

  /// Check if domain looks legitimate
  static bool _isValidDomain(String domain) {
    // Must have at least one dot
    if (!domain.contains('.')) return false;

    // Must end with valid TLD
    final validTlds = ['com', 'org', 'net', 'edu', 'gov', 'mil', 'co', 'io', 'ai'];
    final tld = domain.split('.').last;
    if (!validTlds.contains(tld)) return false;

    // Domain should have reasonable length
    if (domain.length < 4 || domain.length > 50) return false;

    return true;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate first name
  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your first name';
    }

    final name = value.trim();
    if (name.length < 2) {
      return 'First name must be at least 2 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'First name can only contain letters';
    }

    return null;
  }

  /// Validate last name
  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your last name';
    }

    final name = value.trim();
    if (name.length < 2) {
      return 'Last name must be at least 2 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Last name can only contain letters';
    }

    return null;
  }

  /// Validate phone number (US format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove all non-digit characters
    final cleanPhone = value.replaceAll(RegExp(r'\D'), '');

    // Must be exactly 10 digits (US format without country code)
    if (cleanPhone.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }

    // First digit of area code cannot be 0 or 1
    if (cleanPhone[0] == '0' || cleanPhone[0] == '1') {
      return 'Area code cannot start with 0 or 1';
    }

    return null;
  }

  /// Validate address line
  static String? validateAddressLine(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }

    if (value.trim().length < 3) {
      return '$fieldName must be at least 3 characters';
    }

    return null;
  }

  /// Validate city
  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your city';
    }

    final city = value.trim();
    if (city.length < 2) {
      return 'City name must be at least 2 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s\-\.]+$').hasMatch(city)) {
      return 'City name can only contain letters, spaces, hyphens, and periods';
    }

    return null;
  }

  /// Validate state
  static String? validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your state';
    }

    final state = value.trim();
    if (state.length < 2) {
      return 'State must be at least 2 characters';
    }

    return null;
  }

  /// Validate ZIP code
  static String? validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your ZIP code';
    }

    final zip = value.trim();

    // US ZIP code format: 12345 or 12345-6789
    if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(zip)) {
      return 'Please enter a valid ZIP code (12345 or 12345-6789)';
    }

    return null;
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 3)}) ${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
    }
    return phone;
  }
}