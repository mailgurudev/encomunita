# 🏘️ Encomunita - Community Collaboration Platform

A modern Flutter application designed to strengthen neighborhood connections through local engagement, marketplace activities, events, and community services.

## 🚀 Features

### Phase 1 (MVP) - ✅ Complete
- **🔐 Authentication System**
  - Email/password signup and login
  - Enhanced email validation with domain checking
  - Session persistence and recovery
  - Secure PKCE authentication flow

- **👤 Profile Management**
  - Structured profile setup with first/last name fields
  - Complete address system (street, city, state, ZIP)
  - US states dropdown with 2-letter codes
  - International phone support (+1 US/Canada, +91 India)
  - Community selection (Canatarra Meadows, East Village)
  - Auto-generated first name extraction for personalized experience

- **🏠 Home Dashboard**
  - Personalized greetings
  - Community name display
  - Quick Actions: Events, Marketplace, Food, Jobs & Career
  - Foundation for future community features

### Planned Features (Phase 2+)
- **🎉 Community Engagement**
  - Neighborhood events and announcements
  - Community bulletin board
  - Local groups and clubs
  - Volunteer coordination

- **🛒 Local Marketplace**
  - Buy/sell items within community
  - Service offerings (tutoring, pet care, etc.)
  - Local business directory
  - Trusted neighbor ratings

- **🍽️ Food & Dining**
  - Local restaurant recommendations
  - Community potluck coordination
  - Shared garden management
  - Food sharing initiatives

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.9.2+ with Material Design 3
- **Backend**: Supabase (PostgreSQL + Real-time + Auth)
- **State Management**: Riverpod + Hooks
- **Authentication**: Supabase Auth with PKCE flow
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Platform**: iOS, Android, Web, Desktop

## 🎨 Design System

- **Color Scheme**: Coral (#FF6B6B) and Teal (#4ECDC4)
- **Typography**: Material Design 3 typography scale
- **Icons**: Material Icons with custom community-focused icons
- **Layout**: Responsive design with proper spacing and accessibility

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── config/           # Supabase configuration
│   ├── models/           # Data models
│   ├── services/         # Business logic services
│   ├── theme/            # App theme and styling
│   └── utils/            # Utility functions and validators
├── features/
│   ├── auth/             # Authentication screens
│   ├── home/             # Home dashboard
│   ├── profile_setup/    # Profile management
│   └── welcome/          # Onboarding screens
└── main.dart             # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.0.0 or higher
- iOS 12.0+ / Android API 21+ for mobile deployment

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/gurudevprasadteketi/encomunita.git
   cd encomunita
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Supabase Setup**
   - Create a new project at [supabase.com](https://supabase.com)
   - Update `lib/core/config/supabase_config.dart` with your project credentials
   - Run the database migrations (see Database Schema section)

4. **Run the app**
   ```bash
   # For iOS Simulator
   flutter run -d ios

   # For Android Emulator
   flutter run -d android

   # For Web
   flutter run -d web
   ```

### Database Schema

The app uses the following Supabase tables:

```sql
-- User profiles table
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  full_name TEXT NOT NULL,
  first_name TEXT GENERATED ALWAYS AS (split_part(full_name, ' ', 1)) STORED,
  address TEXT,
  community_name TEXT,
  phone_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Users can only see and edit their own profiles
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run widget tests
flutter test test/widget_test.dart
```

## 📱 Platform Support

| Platform | Status | Version |
|----------|---------|---------|
| iOS      | ✅ Supported | 12.0+ |
| Android  | ✅ Supported | API 21+ |
| Web      | ✅ Supported | Modern browsers |
| macOS    | 🔄 In Development | 10.14+ |
| Windows  | 🔄 In Development | Windows 10+ |
| Linux    | 🔄 In Development | Ubuntu 18.04+ |

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Material Design team for the design system
- Community contributors and testers

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/gurudevprasadteketi/encomunita/issues)
- **Discussions**: [GitHub Discussions](https://github.com/gurudevprasadteketi/encomunita/discussions)
- **Email**: mailgurudev@gmail.com

---

**Built with ❤️ for stronger communities**

🏘️ *Encomunita - Where neighbors become friends*
