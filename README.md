<div align="center">

<img src="assets/images/coin.png" width="100" alt="Qirshity Logo">

# قِـرْشِـتـي — Qirshity

**A smart Arabic personal finance manager built with Flutter**

![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?style=flat&logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-lightgrey?style=flat)

</div>

---

## 📱 About

Qirshity is a fully Arabic personal finance application that helps you track daily expenses, monitor income, set savings goals, and analyze spending habits — all stored privately on your device. Designed for Arabic-speaking users, it provides a seamless RTL experience with no internet connection required.

The app works 100% offline. All data is stored locally using Hive. No accounts, no cloud sync, no data shared with third parties.

---

## ✨ Features

| Feature | Description |
|---|---|
| 📊 **Dashboard** | Animated balance card with real-time income & expense summary |
| ➕ **Transactions** | Log income or expenses with amounts, dates, and multiple tags |
| 🏷️ **Custom Tags** | Create personalised tags with custom colors & Font Awesome icons |
| 🎯 **Savings Goals** | Set financial goals, track progress with animated progress bars |
| 📈 **Reports** | Monthly pie chart & bar chart breakdowns using FL Chart |
| 🎨 **Themes** | 6 color themes + full dark mode support |
| 💱 **Currency** | Customisable currency symbol (EGP, USD, EUR, SAR, AED, KWD) |
| 💾 **Offline-First** | 100% local storage — powered by Hive, no internet required |
| 🔐 **Privacy** | All data stays on-device, no accounts or cloud services |
| 🌙 **Dark Mode** | System-aware dark mode with smooth transitions |

---

## 🏗 Architecture

The app follows a **simple layered architecture** with clear separation of concerns:

```
Views (UI)
    ↓ listens
Service (HiveService)
    ↓ reads/writes
Hive Database (local)
```

| Layer | Technology |
|---|---|
| **UI** | Flutter Widgets + Material 3 |
| **State** | `ValueListenableBuilder` + `Hive.listenable()` |
| **Service** | `HiveService` (static data access layer) |
| **Storage** | Hive (local NoSQL database) |
| **Routing** | Manual `Navigator.push` + `MaterialPageRoute` |
| **Localization** | `flutter_localizations` (Arabic only) |

No formal state management library is used; reactivity is achieved through Hive's built-in `listenable()` mechanism combined with `ValueListenableBuilder`.

---

## 📂 Project Structure

```text
lib/
├── service/
│   └── hive_service.dart          # Data access layer
├── views/
│   ├── goals/
│   │   ├── add_goal_view.dart     # Create savings goal
│   │   └── goals_view.dart        # Goals list with progress
│   ├── home/
│   │   └── home_view.dart         # Main dashboard
│   ├── main_wrapper/
│   │   └── main_wrapper.dart      # Bottom navigation shell
│   ├── reports/
│   │   └── reports_view.dart      # Charts & analytics
│   ├── settings/
│   │   ├── about_view.dart        # About screen
│   │   └── settings_view.dart     # App settings
│   ├── splash/
│   │   └── splash_view.dart       # Splash screen
│   ├── tags/
│   │   ├── add_tag_view.dart      # Create custom tag
│   │   └── tags_view.dart         # Manage tags
│   ├── setup/
│   │   └── setup_view.dart        # First-run onboarding
│   └── transactions/
│       └── add_transaction_view.dart  # New transaction
└── main.dart                      # App entry point
```

---

## 📸 Screenshots

> Coming soon

---

## 🛠 Built With

- **[Flutter](https://flutter.dev)** — Cross-platform UI framework
- **[Dart](https://dart.dev)** — Programming language
- **[Hive](https://pub.dev/packages/hive_flutter)** — Lightweight local NoSQL database
- **[FL Chart](https://pub.dev/packages/fl_chart)** — Pie & bar chart visualisations
- **[Font Awesome Flutter](https://pub.dev/packages/font_awesome_flutter)** — Icon library
- **[Intl](https://pub.dev/packages/intl)** — Date formatting & internationalisation
- **[flutter_lints](https://pub.dev/packages/flutter_lints)** — Lint rules
- **[flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)** — App icon generation

---

## 📦 Main Dependencies

| Package | Purpose |
|---|---|
| `hive` / `hive_flutter` | Local persistent storage |
| `fl_chart` | Financial chart visualisations |
| `font_awesome_flutter` | Tag & UI icons |
| `intl` | Arabic date formatting |
| `flutter_localizations` | Arabic RTL localisation |

---

## 📱 Compatibility

| Platform | Minimum Version |
|---|---|
| Android | 8.0 (API 26) |
| iOS | 13.0 |
| Web | Modern browsers |
| macOS | 10.14+ |
| Linux | GTK 3.0+ |
| Windows | Windows 7+ |

---

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/username/qirshity.git

# Navigate to project
cd qirshity

# Install dependencies
flutter pub get

# Generate launcher icons (optional)
dart run flutter_launcher_icons

# Run the app
flutter run
```

---

## ⚙ Requirements

- **Flutter SDK** — ^3.11.5
- **Dart SDK** — ^3.11.5
- **Android Studio** — with Android SDK 26+
- **Xcode** — 15+ (for iOS builds)
- **CocoaPods** — `sudo gem install cocoapods` (for iOS)
- **Git** — for version control

---

## 🔨 Build Release

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS (requires Xcode)
flutter build ios

# Web
flutter build web

# macOS
flutter build macos

# Linux
flutter build linux

# Windows
flutter build windows
```

---

## 👨‍💻 Developer

**Abdulrahman Hamed**  
Flutter Developer

---

## 📄 License

This project currently does not specify a license.

---

<div align="center">

Made with ❤️ using Flutter

</div>
