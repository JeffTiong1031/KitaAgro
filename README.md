# kita_agro

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

------------------------------------------------

## Project Setup (for Team)

This project has been configured for easy collaboration. Configuration files are included in the repository.

### Run the App
```bash
flutter pub get
flutter run
```

### Google APIs for Garden Location Feature

1. In Google Cloud Console, enable:
	- Maps SDK for Android
	- Places API
	- Geocoding API
2. Set Android Maps key in [android/app/src/main/res/values/strings.xml](android/app/src/main/res/values/strings.xml):
	- `google_maps_key`
3. Run Flutter with Places/Geocoding key for REST calls:

```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_API_KEY
```
