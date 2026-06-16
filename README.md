# Usage Meter for SLT

Monitor your SLT broadband usage — available as a native iOS/macOS widget app and a cross-platform Flutter app.

## About

This project was originally created by [prabch](https://github.com/prabch/Usage-Meter-for-SLT) as a SwiftUI iOS/macOS widget. This fork extends it with a **cross-platform Flutter app** targeting Android, iOS, macOS, Windows, Linux, and Web.

---

## Apps in This Repo

### 1. Original SwiftUI App (`SLT Usage Meter/`)

A native iOS & macOS app with home screen widgets.

- **Platforms:** iOS 16+, macOS 13+
- **Language:** Swift / SwiftUI
- **Features:** Home screen widgets, Keychain credential storage, iCloud Keychain sync

To build: Open `Usage Meter for SLT.xcodeproj` in Xcode. You will need a `Secrets.swift` file — copy from `Secrets.example.swift` and fill in your IBM Client ID.

### 2. Flutter Cross-Platform App (`flutter_app/`)

A complete rewrite of the UI layer in Flutter, sharing the same MySLT API.

- **Platforms:** Android, iOS, macOS, Windows, Linux, Web
- **Language:** Dart / Flutter
- **Architecture:** Feature-first with Provider state management

---

## Flutter App Setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.22+
- Your **IBM Client ID** from the MySLT API (see below)

### 1. Get your Client ID

The `X-Ibm-Client-Id` header is required for all API calls. Obtain it by:
- Inspecting network traffic from the official MySLT app, or
- Referencing the original Swift app's `Secrets.swift`

### 2. Configure secrets

Create `flutter_app/lib/core/constants/secrets.dart`:

```dart
const String kClientId = 'YOUR_IBM_CLIENT_ID_HERE';
```

> **Note:** `secrets.dart` is gitignored. Never commit your Client ID.

Then update `flutter_app/lib/core/constants/api_constants.dart`:

```dart
import 'secrets.dart'; // replace the inline placeholder
const String kClientId = clientId; // from secrets.dart
```

Or simply replace `'YOUR_IBM_CLIENT_ID_HERE'` in `api_constants.dart` directly (do not commit).

### 3. Install dependencies

```bash
cd flutter_app
flutter pub get
```

### 4. Run

```bash
# Android / iOS / macOS / Windows / Linux
flutter run

# Web
flutter run -d chrome
```

---

## Project Structure (Flutter)

```
flutter_app/lib/
├── main.dart                        # App entry point + routing
├── core/
│   ├── constants/api_constants.dart # API base URL & endpoints
│   ├── network/api_client.dart      # HTTP client w/ auto token refresh
│   ├── storage/secure_storage.dart  # flutter_secure_storage wrapper
│   └── theme/app_theme.dart         # Material 3 light & dark themes
└── features/
    ├── auth/
    │   ├── models/auth_models.dart
    │   ├── providers/auth_provider.dart
    │   └── screens/login_screen.dart
    ├── usage/
    │   ├── models/usage_models.dart
    │   ├── providers/usage_provider.dart
    │   └── screens/
    │       ├── home_screen.dart     # Tab container + account selector
    │       └── usage_screen.dart    # Usage bars, status card, VAS bundles
    └── account/
        └── screens/account_screen.dart
```

---

## API

The app talks to the **MySLT OMNI API**:

| Endpoint | Description |
|---|---|
| `POST /Account/Login` | Authenticate, receive access + refresh tokens |
| `GET /AccountOMNI/GetAccountDetailRequest` | List registered accounts |
| `GET /AccountOMNI/GetServiceDetailRequest` | Broadband service details |
| `GET /BBVAS/UsageSummary` | Usage summary (total, bonus, extra GB) |
| `GET /BBVAS/GetDashboardVASBundles` | Add-on bundle usage |
| `POST /Account/RefreshToken` | Exchange refresh token for new access token |

All requests require `X-Ibm-Client-Id` header. Authenticated requests also require `authorization: bearer <token>`.

Credentials are exchanged for a secure token and stored locally via the platform keychain — no credentials are ever sent to any third-party server.

---

## Features

- Login with MySLT credentials (same as myslt.slt.lk)
- View broadband usage for all connections under your account
- Main bundle, bonus data, extra GB, and add-on bundle breakdown
- Connection status indicator
- Pull-to-refresh
- Automatic token refresh (silent re-auth when token expires)
- Secure credential storage (platform keychain on all platforms)
- Light & dark mode support

---

## Planned Features

- Home screen / notification widgets
- Usage history charts
- Usage alerts / threshold notifications
- Multiple account profiles
- Android quick-tile widget

---

## Disclaimer

This is an independent app and is not affiliated with or endorsed by SLT Mobitel. No personal data is collected or stored externally.

## License

GPL-3.0 — see [LICENSE](LICENSE).
