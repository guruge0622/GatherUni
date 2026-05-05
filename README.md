# GatherUni

GatherUni is a Flutter application scaffold for university event discovery and management. It provides a starting point with common integrations (Firebase, Google Sign-In, Maps, and storage) and example screens to build from.

## Features

- Flutter cross-platform app (Android, iOS, Web, desktop)
- Firebase authentication & Firestore examples
- Google Maps integration and image picker
- Sample screens and routing

## Prerequisites

- Flutter SDK (see https://docs.flutter.dev/get-started/install)
- Android Studio / Xcode (for Android/iOS builds)
- An emulator or physical device

## Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Configure Firebase for the platforms you target (Android/iOS/Web). Place platform-specific config files in the appropriate folders (e.g. `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`).

3. (Optional) Update `local.properties` with any SDK paths or add API keys to `assets` or environment variables as needed.

## Run

- Run on a connected device or emulator:

```bash
flutter run
```

- Build a release APK for Android:

```bash
flutter build apk --release
```

## Project Layout

- `lib/` — Flutter source code, entrypoint is `main.dart`
- `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/` — platform folders
- `assets/` — images and icons

## Tests

Run the unit/widget tests with:

```bash
flutter test
```

## Contributing

Contributions are welcome. Open issues or submit PRs for bug fixes and improvements. Keep changes focused and include tests when appropriate.

## License

This project does not include a license file. Add a `LICENSE` if you want to make the project open source.

---

If you'd like, I can add a short Getting Started section tailored to how you run the app (Android, iOS, or web), or include example Firebase setup instructions. Which would you prefer?

## Firestore Security Rules

I've added a recommended rules file at `firestore.rules` that enforces owner-only writes for user profiles and events. Key points:

- `users/{userId}`: only the authenticated user may create/update/delete their own profile.
- `events/{eventId}`: create requests must set `organizerId` equal to `request.auth.uid`; update/delete allowed only when the stored `organizerId` matches `request.auth.uid`.

To deploy the rules with the Firebase CLI:

```bash
firebase deploy --only firestore:rules
```

Or specify a project:

```bash
firebase deploy --only firestore:rules --project YOUR_PROJECT_ID
```

Test rules using the Firebase Emulator Suite or the Firebase Console rules tester before deploying to production.
