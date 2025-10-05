# print_management_mmcoe
An interface to queue and collect prints from the college printer in a more efficient way

## Under Development, not prod ready!

### File Structure for quick reference

```bash
print_manager/
├── .dart_tool/
├── .idea/
├── android/
├── build/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
├── test/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── firestore_constants.dart
│   │   ├── services/
│   │   │   └── firebase_test.dart
│   │   └── themes/
│   │       ├── app_theme.dart
│   │       └── color_palette.dart
│   ├── models/
│   │   ├── print_preferences_model.dart
│   │   ├── print_request_model.dart
│   │   └── user_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── print_provider.dart
│   │   └── theme_provider.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   └── storage_service.dart
│   └── screens/
│       ├── auth/
│       │   └── login_screen.dart
│       ├── printer/
│       │   ├── print_queue_screen.dart
│       │   ├── printer_dashboard_screen.dart
│       │   └── printer_login_screen.dart
│       └── student/
│           ├── home_screen.dart
│           └── upload_screen.dart
├── .flutter-plugins-dependencies
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── firebase.json
├── firepit-log.txt
├── print_manager.iml
├── pubspec.lock
├── pubspec.yaml
└── README.md

```
