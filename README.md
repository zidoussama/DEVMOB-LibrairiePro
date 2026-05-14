# LibrairiePro

LibrairiePro is a Flutter mobile application for a modern bookstore experience.
It includes authentication, product browsing, search, favorites, cart, orders,
profile management, and Firebase integration.

## Highlights

- Clean Flutter architecture using controllers, providers, services, and views.
- Firebase Authentication with secure sign-in and registration.
- Email verification gate: unverified users cannot access the main app.
- Waiting screen after login/register for email verification.
- Password reset by email.
- Firestore-backed user and product features.
- Multi-platform Flutter project (Android, iOS, Web, Desktop).

## Tech Stack

- Flutter (Dart)
- Provider (state management)
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Shared Preferences

## Project Structure

The project follows a layered organization inside lib/:

- Config/: routing and app constants/colors.
- Models/: domain models (user, product, order, etc.).
- services/: Firebase and app service layer.
- controllers/: app business/controller logic.
- providers/: state management for UI.
- views/screens/: app screens (auth, home, profile, cart, etc.).
- views/widgets/: reusable UI widgets.

## Authentication and Verification Flow

1. User registers with email and password.
2. A verification email is sent.
3. User is redirected to a verification waiting screen.
4. If user is not verified, access to main/home is blocked.
5. Once verified, user is automatically redirected to the main app.
6. On login, unverified users are also redirected to waiting screen.

## Prerequisites

- Flutter SDK installed and configured.
- Dart SDK (bundled with Flutter).
- Firebase project configured.
- Android Studio and/or Xcode for mobile builds.

## Setup

1. Clone the repository.
2. Install dependencies:

```bash
flutter pub get
```

3. Configure Firebase:

- Android: place google-services.json in android/app/.
- iOS: place GoogleService-Info.plist in ios/Runner/.
- Ensure your Firebase project has Authentication (Email/Password) enabled.

4. Run the app:

```bash
flutter run
```

## Useful Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Build

Android APK:

```bash
flutter build apk --release
```

iOS (macOS only):

```bash
flutter build ios --release
```

Web:

```bash
flutter build web
```

## Configuration Notes

- Persistent login behavior is controlled with shared preferences keys:
	- remember_me
	- keep_logged_in
- Routing is centralized in lib/Config/routes.dart.
- Splash screen enforces auth + verification gate before entering main app.

## Troubleshooting

- Verification email not received:
	- Check spam/junk folders.
	- Confirm the email address is correct.
	- Use the "resend verification" action on the waiting screen.
	- Verify Firebase Authentication Email/Password provider is enabled.
- App cannot sign in:
	- Check internet connection.
	- Verify Firebase config files are correctly placed.
- Analyzer warnings:
	- Run flutter analyze and fix issues incrementally.

## Roadmap Ideas

- Admin dashboard for product and order management.
- Better analytics and crash reporting.
- Localization (French/English).
- Push notifications for order status.
- CI/CD for automated build and testing.

## Contributing

1. Create a feature branch.
2. Keep changes small and focused.
3. Run analysis and tests before opening a pull request.

## License

This project is currently private/internal.
Add your license of choice before public distribution.
