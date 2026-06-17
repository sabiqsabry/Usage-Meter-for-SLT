# SLT Usage Meter

A cross-platform app to monitor your SLT-Mobitel broadband data usage — built with Flutter for iOS, Android, macOS, Windows, Linux, and Web.

Supports both standard username/password login and **Google Sign-In** for accounts registered via Google on [myslt.slt.lk](https://myslt.slt.lk).

---

## Features

- **Usage dashboard** — main package bars, bonus data, extra GB, and all VAS/add-on bundles with colour-coded progress bars
- **Multiple accounts** — switch between all accounts linked to your SLT login
- **Google Sign-In** — native OAuth flow (no embedded browser)
- **Dark mode** — follows system theme via Material 3
- **Home-screen widgets** — iOS WidgetKit widget and Android AppWidget showing live usage at a glance
- **Secure storage** — tokens stored in iOS Keychain / Android EncryptedSharedPreferences
- **Platform-aware** — About section shows whether you're on iPhone, Android, macOS, etc.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later)
- Xcode (for iOS / macOS builds)
- Android Studio (for Android builds)
- An SLT-Mobitel account

### Setup

1. Clone the repo and move into the Flutter project:

   ```bash
   git clone https://github.com/sabiqsabry/Usage-Meter-for-SLT.git
   cd Usage-Meter-for-SLT/flutter_app
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Create `lib/core/constants/secrets.dart` with your IBM API client ID (get it from the MySLT app traffic or the original repo's instructions):

   ```dart
   // lib/core/constants/secrets.dart  — do NOT commit this file
   const String kClientId = 'YOUR_IBM_CLIENT_ID_HERE';
   ```

4. Run on your device:

   ```bash
   flutter run
   ```

### Google Sign-In (optional)

If you want Google Sign-In to work on your own build:

1. Create OAuth 2.0 client IDs in [Google Cloud Console](https://console.cloud.google.com/) for iOS and Android
2. Fill in `kGoogleIosClientId` and `kGoogleAndroidClientId` in `lib/core/constants/api_constants.dart`
3. Add the reversed iOS client ID as a URL scheme in `ios/Runner/Info.plist`

---

## Project Structure

```
flutter_app/
├── lib/
│   ├── core/
│   │   ├── constants/        # API endpoints, client IDs
│   │   ├── network/          # HTTP client, token refresh, error handling
│   │   ├── services/         # WidgetService (home-screen widget data bridge)
│   │   ├── storage/          # Secure token storage wrapper
│   │   └── theme/            # Material 3 light/dark themes
│   ├── features/
│   │   ├── auth/             # Login screen, Google Sign-In, auth provider
│   │   └── usage/            # Usage screen, account screen, data models, providers
│   └── shared/
│       └── widgets/          # UsageProgressBar and other shared UI components
├── ios/
│   ├── Runner/               # Main iOS app
│   └── SLTUsageMeterWidget/  # iOS WidgetKit extension (Swift)
└── android/
    └── app/src/main/
        ├── kotlin/           # SLTUsageWidget.kt (Android AppWidgetProvider)
        └── res/              # Widget layouts, drawables, XML provider info
```

---

## API

All data is fetched from the MySLT API:

| Endpoint | Purpose |
|---|---|
| `POST /Account/Login` | Username/password login |
| `POST /Account/LoginExternal` | Social (Google) login |
| `POST /Account/RefreshToken` | Refresh expired access token |
| `GET /Account/GetAccountDetails` | Fetch linked accounts |
| `GET /SLTDetails/GetServiceDetails` | Get broadband service IDs |
| `GET /BBVAS/UsageSummary` | Main usage summary + package info |
| `GET /BBVAS/GetVASBundles` | VAS / add-on bundle usage |

All requests require `X-Ibm-Client-Id` in the header. Authenticated requests also send `Authorization: Bearer <token>`.

---

## iOS Widget Setup

The widget reads from a shared App Group (`group.com.sabiqsabry.sltUsageMeter`). To activate it on your own build:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to **File → New Target → Widget Extension**, name it `SLTUsageMeterWidget`
3. Delete the generated `.swift` file — the real code is already at `ios/SLTUsageMeterWidget/SLTUsageMeterWidget.swift`
4. Add the App Group `group.com.sabiqsabry.sltUsageMeter` to **both** targets under **Signing & Capabilities**
5. Build and run, then long-press the home screen to add the widget

---

## License

This project is licensed under the **GNU General Public License v3.0** — see the [LICENSE](LICENSE) file for details.

In short: you are free to use, modify, and distribute this project, but any distributed version must remain open-source under the same license.

---

## Credits

This app is based on the original **Usage Meter for SLT** iOS/macOS app by [Prabhashwara (prabch)](https://github.com/prabch/Usage-Meter-for-SLT), which provided the initial Swift/SwiftUI implementation, API integration, and widget design that this Flutter port builds upon.

---

*This app is an unofficial, community-built tool. It is not affiliated with or endorsed by SLT-Mobitel.*
