# Family Connect

Flutter + Firebase family app: chat, tasks, parent admin, and (later) location sharing.

Follow **[plan.md](plan.md)** for phases. Agents should update checklists there.

## Stack

- **Flutter** (Android APK on Windows; iOS later via Mac CI)
- **Firebase** Auth, Firestore, FCM, Storage — no self-hosted server for Phase 0–2

## Prerequisites (Windows)

1. Flutter SDK (this machine uses `C:\src\flutter` — add `C:\src\flutter\bin` to your PATH).
2. Android Studio / Android SDK + an emulator or USB device.
3. A Firebase project — see **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)**.

```powershell
$env:PATH = "C:\src\flutter\bin;$env:PATH"
flutter doctor
```

## Run

```powershell
flutter pub get
flutter run
```

Until Firebase is configured, the app shows the setup screen.

After `flutterfire configure` and `isConfigured = true`:

```powershell
flutter run
flutter build apk
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

## Phase 0 status

Scaffold, auth UI, roles, create/join family, profile, and routing are implemented.  
Wire Firebase (see FIREBASE_SETUP.md) to use the app on devices.
"# szabist_student_app" 
