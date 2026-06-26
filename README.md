<!-- kodi-badges -->
[![Lizenz: EUPL-1.2](https://img.shields.io/badge/Lizenz-EUPL%201.2-blue.svg)](LICENSE) ![Open Source](https://img.shields.io/badge/Open%20Source-Ja-brightgreen.svg) ![Smart City](https://img.shields.io/badge/Smart%20City-Kommunal-orange.svg) ![Sprache](https://img.shields.io/badge/Sprache-Dart-informational.svg) ![KODI](https://img.shields.io/badge/KODI-Entwicklergemeinschaft-blueviolet.svg)
<!-- /kodi-badges -->

<div align="center">

# 📱 Your App Name

**A community-first mobile platform — keeping your city connected, informed, and engaged.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-enabled-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-EUPL%201.2-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=flat-square)](#)

_Template B reference application — open-sourced from **KODI-Kommunen-Digital**. Licensed under the [EUPL-1.2](LICENSE)._

<br/>

[🇬🇧 English](#-english) &nbsp;·&nbsp; [🇩🇪 Deutsch](#-deutsch)

</div>

---

## 🇬🇧 English

### What is Your App Name?

**Your App Name** is a free, Flutter-based mobile application built to help residents of your city stay informed, connected, and active in community life. From real-time chats and local news to event calendars and civic services — everything in one place.

---

### ✨ Features

| Feature | Description |
|---|---|
| 💬 **Real-Time Chats** | Connect with neighbours, share information, strengthen local bonds |
| 📅 **Event Calendar** | Never miss a local event — cultural gatherings, markets, and more |
| 🔍 **Search & Offer Services** | Find or advertise local services and products |
| 📰 **Local News & Updates** | City news delivered straight to your phone |
| 🏛️ **Association Directory** | Discover local clubs, sports, and social groups |
| 🗺️ **Location Filters** | Personalise your feed by neighbourhood or district |
| 🗳️ **Community Engagement** | Give feedback, join discussions, and shape your city |
| 🌐 **Citizen Services** | Quick access to municipal services and portals |

---

### 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | BLoC / Cubit |
| Backend / Auth | Firebase (Firestore, Cloud Messaging, Remote Config, Crashlytics) |
| Analytics | Matomo |
| Error Tracking | Sentry |
| Deep Links | Android Intent Scheme |

---

### 🚀 Getting Started

> **Note:** Several configuration files are **not included** in this repository for security reasons.  
> Follow every step below before running the app.

---

#### Step 1 — Clone the Repository

```bash
git clone https://github.com/your-org/your-app-repo.git
cd your-app-repo
```

---

#### Step 2 — Prerequisites

| Requirement | Notes |
|---|---|
| [Flutter SDK](https://flutter.dev/docs/get-started/install) | Latest stable version |
| Dart SDK | Bundled with Flutter |
| [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) | With Flutter & Dart plugins |
| Xcode *(iOS/macOS only)* | Required for iOS builds |

---

#### Step 3 — Firebase Setup

The app uses **two separate Firebase projects** — one for **staging** and one for **production**.

Create both in the [Firebase Console](https://console.firebase.google.com), then:

<details>
<summary><strong>Android — <code>google-services.json</code></strong></summary>

Download the config file for each project and place it at:

| Flavor | Path |
|---|---|
| Staging | `android/app/src/main/dev/google-services.json` |
| Production | `android/app/src/main/prod/google-services.json` |

Use `android/app/google-services.json.example` as a structure reference.

</details>

<details>
<summary><strong>iOS — <code>GoogleService-Info.plist</code></strong></summary>

Download the plist for each project and place it at:

| Flavor | Path |
|---|---|
| Staging | `ios/Runner/config/dev/GoogleService-Info.plist` |
| Production | `ios/Runner/config/prod/GoogleService-Info.plist` |

Use `ios/Runner/GoogleService-Info.plist.example` as a structure reference.

</details>

<details>
<summary><strong>Dart Firebase Options</strong></summary>

Open both files and replace every placeholder with your real Firebase values  
(Firebase Console → Project Settings → Your apps):

- `lib/src/firebase_options_staging/firebase_options_staging.dart`
- `lib/src/firebase_options_production/firebase_options_production.dart`

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_FIREBASE_API_KEY',
  appId: 'YOUR_ANDROID_FIREBASE_APP_ID',
  messagingSenderId: 'YOUR_FIREBASE_PROJECT_NUMBER',
  projectId: 'your-firebase-project-id',
  storageBucket: 'your-firebase-project-id.firebasestorage.app',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_FIREBASE_API_KEY',
  appId: 'YOUR_IOS_FIREBASE_APP_ID',
  messagingSenderId: 'YOUR_FIREBASE_PROJECT_NUMBER',
  projectId: 'your-firebase-project-id',
  storageBucket: 'your-firebase-project-id.firebasestorage.app',
  iosBundleId: 'com.your.bundleid',
);
```

</details>

<details>
<summary><strong>Firebase Remote Config</strong></summary>

The app fetches its API base URLs, WebSocket URL, and image storage URLs from Remote Config at runtime.

In each Firebase project go to **Remote Config → Add parameter** and set:

- **Key:** `remote_urls`
- **Value:**

```json
{
  "baseUrls": {
    "default": "https://your-api-base-url/api/v2/",
    "forum":   "https://your-forum-api-url/api/v2/"
  },
  "wsUrl":            "wss://your-websocket-url",
  "picturesURL":      "https://your-image-storage-url/",
  "defaultPicturesURL": "https://your-default-image-url/"
}
```

Click **Publish changes**.

</details>

---

#### Step 4 — Android Signing

1. Generate a keystore (skip if you already have one):

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias your_key_alias
```

2. Copy the template:

```bash
cp android/key.properties.example android/key.properties
```

3. Fill in `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=../app/upload-keystore.jks
```

> `android/key.properties` and `android/app/upload-keystore.jks` are gitignored — they will never be committed.

---

#### Step 5 — Sentry (Error Tracking)

1. Create a project at [sentry.io](https://sentry.io).
2. Copy the **DSN** from **Settings → Client Keys (DSN)**.
3. Paste it into `lib/main_dev.dart` and `lib/main_prod.dart`:

```dart
options.dsn = 'https://YOUR_SENTRY_KEY@YOUR_SENTRY_ORG.ingest.de.sentry.io/YOUR_SENTRY_PROJECT_ID';
```

---

#### Step 6 — Matomo Analytics *(staging only)*

1. Set up a [Matomo](https://matomo.org) instance (cloud or self-hosted).
2. Update `lib/main_dev.dart`:

```dart
MatomoApi.initialize(
  "YOUR_MATOMO_SITE_ID",
  'https://your-matomo-instance.matomo.cloud/matomo.php',
);
```

---

#### Step 7 — Package / Bundle Identifier

Replace `com.your.packagename` / `com.your.bundleid` with your actual identifier in:

| File | Field |
|---|---|
| `android/app/build.gradle` | `namespace`, `applicationId` |
| `android/app/src/main/kotlin/.../MainActivity.kt` | `package` declaration |
| `ios/Runner.xcodeproj/project.pbxproj` | `PRODUCT_BUNDLE_IDENTIFIER` (× 3) |
| `ios/Runner.xcodeproj/project.pbxproj` | `DEVELOPMENT_TEAM` |
| Both Firebase options Dart files | `iosBundleId` |

---

#### Step 8 — Install Dependencies

```bash
flutter pub get
```

---

### ▶️ Running the App

The app has two flavors:

| Flavor | Entry Point | Command |
|---|---|---|
| Staging | `lib/main_dev.dart` | `flutter run -t lib/main_dev.dart` |
| Production | `lib/main_prod.dart` | `flutter run -t lib/main_prod.dart` |

Target a specific device:

```bash
flutter devices
flutter run -t lib/main_dev.dart -d <device-id>
```

---

### 📦 Release Builds

```bash
# Android APK
flutter build apk -t lib/main_prod.dart --release

# Android App Bundle (Play Store)
flutter build appbundle -t lib/main_prod.dart --release

# iOS (archive via Xcode after this step)
flutter build ios -t lib/main_prod.dart --release
```

---

### 📁 Files You Must Provide

These files are gitignored and must be created manually:

| File | Description |
|---|---|
| `android/app/src/main/dev/google-services.json` | Firebase — Android staging |
| `android/app/src/main/prod/google-services.json` | Firebase — Android production |
| `ios/Runner/config/dev/GoogleService-Info.plist` | Firebase — iOS staging |
| `ios/Runner/config/prod/GoogleService-Info.plist` | Firebase — iOS production |
| `android/key.properties` | Keystore credentials (copy from `.example`) |
| `android/app/upload-keystore.jks` | Android signing keystore |

---

### ♻️ Code Generation

Run this whenever you modify annotated models or Hive boxes:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

### 🤝 Contributing

Contributions are welcome! Feel free to:

- 🍴 Fork this repository
- 🐛 Open an issue to report a bug
- 💡 Submit a pull request with improvements

Please follow the existing code style and BLoC patterns used throughout the project.

---

### 📄 License

This project is licensed under the **European Union Public Licence v1.2 (EUPL-1.2)**.  
See the [LICENSE](LICENSE) file for details.

---

<br/>

## 🇩🇪 Deutsch

### Was ist Your App Name?

**Your App Name** ist eine kostenlose, Flutter-basierte mobile Anwendung, die Einwohner:innen dabei hilft, in ihrer Stadt informiert, vernetzt und engagiert zu bleiben — von Echtzeit-Chats und lokalen Nachrichten bis hin zu Veranstaltungskalendern und Bürgerdiensten.

---

### ✨ Funktionen

| Funktion | Beschreibung |
|---|---|
| 💬 **Echtzeitchats** | Mit Nachbarn in Kontakt treten, Informationen teilen, Gemeinschaft stärken |
| 📅 **Veranstaltungskalender** | Keine lokale Veranstaltung mehr verpassen |
| 🔍 **Suche-Biete-Funktion** | Lokale Dienstleistungen und Produkte finden oder anbieten |
| 📰 **Lokale Nachrichten** | Stadtnachrichten direkt auf dem Smartphone |
| 🏛️ **Vereinsverzeichnis** | Lokale Vereine, Sport und soziale Gruppen entdecken |
| 🗺️ **Standortfilter** | Feed nach Ortschaft oder Stadtteil personalisieren |
| 🗳️ **Bürgerbeteiligung** | Feedback geben, Diskussionen beitreten, Stadt mitgestalten |
| 🌐 **Bürgerdienste** | Schneller Zugang zu kommunalen Diensten und Portalen |

---

### 🚀 Erste Schritte

> **Hinweis:** Mehrere Konfigurationsdateien sind aus Sicherheitsgründen **nicht im Repository enthalten**.  
> Folgen Sie allen nachstehenden Schritten, bevor Sie die App starten.

---

#### Schritt 1 — Repository klonen

```bash
git clone https://github.com/your-org/your-app-repo.git
cd your-app-repo
```

---

#### Schritt 2 — Voraussetzungen

| Anforderung | Hinweis |
|---|---|
| [Flutter SDK](https://flutter.dev/docs/get-started/install) | Neueste stabile Version |
| Dart SDK | Im Flutter-Paket enthalten |
| [Android Studio](https://developer.android.com/studio) oder [VS Code](https://code.visualstudio.com/) | Mit Flutter- & Dart-Plugins |
| Xcode *(nur iOS/macOS)* | Für iOS-Builds erforderlich |

---

#### Schritt 3 — Firebase einrichten

Die App verwendet **zwei separate Firebase-Projekte** — eines für **Staging** und eines für **Produktion**.

Erstellen Sie beide in der [Firebase Console](https://console.firebase.google.com) und folgen Sie dann den Anweisungen in den aufklappbaren Abschnitten unter [Step 3](#step-3--firebase-setup) der englischen Sektion (Dateinamen und Struktur sind identisch).

---

#### Schritt 4 — Abhängigkeiten installieren

```bash
flutter pub get
```

---

#### Schritt 5 — App starten

```bash
# Staging
flutter run -t lib/main_dev.dart

# Produktion
flutter run -t lib/main_prod.dart
```

---

### ♻️ Code-Generierung

Immer wenn annotierte Modelle oder Hive-Boxen geändert werden:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

### 🤝 Beitragen

Wir freuen uns über Beiträge aus der Community! Gerne:

- 🍴 Repository forken
- 🐛 Issues melden
- 💡 Pull Requests einreichen

Bitte den bestehenden Code-Stil und die im Projekt verwendeten BLoC-Muster beachten.

---

### 📄 Lizenz

Dieses Projekt ist unter der **European Union Public Licence v1.2 (EUPL-1.2)** lizenziert.  
Details finden Sie in der [LICENSE](LICENSE)-Datei.

---

<div align="center">

Made with ❤️ using [Flutter](https://flutter.dev)

</div>
