# Firebase setup (Windows)

Family Connect uses Firebase so you can install APKs without hosting a server.

## 1. Create project

1. Open [Firebase Console](https://console.firebase.google.com).
2. Create a project (Spark / free is fine).
3. Disable Google Analytics if you prefer (optional).

## 2. Enable products

1. **Authentication** → Sign-in method → enable **Email/Password**.
2. **Firestore Database** → Create database → start in **test mode** for local family use, then tighten with `firestore.rules`.
3. (Phase 1+) **Cloud Messaging** for push notifications.
4. (Phase 2+) **Storage** for chat images.

## 3. Register Android app

1. Add Android app with package name: `com.familyconnect.family_connect`
2. Download `google-services.json` → place at `android/app/google-services.json`
3. The Google Services Gradle plugin is already wired in this repo.

## 4. Generate Flutter options

From the project root (Flutter must be on PATH):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This updates `lib/firebase_options.dart` with real `apiKey`, `appId`, `projectId`, etc.

Then set:

```dart
static const bool isConfigured = true;
```

in `lib/firebase_options.dart`.

## 5. iOS later

When you have a Mac / Codemagic:

1. Register iOS app in Firebase.
2. Add `GoogleService-Info.plist`.
3. Re-run `flutterfire configure`.

## 6. Security rules

Deploy rules from `firestore.rules` when ready:

```bash
firebase deploy --only firestore:rules
```

For a private family APK, start with the rules file in this repo and adjust as you go.
