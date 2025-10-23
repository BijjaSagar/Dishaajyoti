# DishaAjyoti

Career & Life Guidance - A Flutter application providing palmistry, Vedic Jyotish, and numerology services.

## Getting Started

This project is a Flutter application that guides users through authentication, profile setup, service selection, payment processing, and AI-powered report generation.

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

### Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
├── screens/                  # Screen widgets
├── widgets/                  # Reusable widgets
│   ├── buttons/             # Button widgets
│   ├── inputs/              # Input widgets
│   ├── cards/               # Card widgets
│   └── dialogs/             # Dialog widgets
├── theme/                    # Theme configuration
├── services/                 # API and business logic services
├── providers/                # State management providers
├── utils/                    # Utility functions
├── routes/                   # Routing configuration
└── l10n/                     # Localization files
```

### Dependencies

- **provider**: State management
- **dio**: HTTP client for API requests
- **flutter_secure_storage**: Secure token storage
- **cached_network_image**: Image caching and optimization
- **google_fonts**: Custom fonts (Poppins)
- **shared_preferences**: Local data persistence

### Color Scheme

- Primary Color: Blue (#0066CC)
- Accent Color: Orange (#FF6B35)
- Text Color: Black (#1A1A1A)

## Features

- User authentication (login/signup)
- Multi-step profile setup
- Service catalog browsing
- Secure payment processing
- AI-powered report generation
- Report viewing and downloading
- Session management
- Push notifications

## License

This project is proprietary and confidential.
