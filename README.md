# MMCOE Print Manager

A Flutter & Firebase-powered app to manage printing requests in a college environment. Students can upload documents, set printing preferences, and track their requests, while the printer account can manage all requests and update their status.

---

## Table of Contents
- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Firebase Setup](#firebase-setup)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## Features

### For Students
- Upload PDF documents to print.
- Specify print preferences:
  - Black & White (Color coming soon)
  - Single/Double Sided
  - Number of copies
- Track print request status (Pending, Ready, Collected).
- Automatic calculation of total cost based on pages and preferences.
- Persistent login across app restarts.

### For Printer
- View all print requests.
- Update request status (Ready, Collected).
- Manage multiple requests efficiently.

---

## Screenshots

*(nantr add karu)*

---

## Overview of files
```bash
lib/
├── core/
│   ├── constants/       # App constants like colors, styles
│   └── themes/          # Light & dark theme definitions
├── models/              # Data models (User, PrintRequest, Preferences)
├── providers/           # State management with Provider
├── screens/
│   ├── auth/            # Login & signup screens
│   ├── student/         # Student dashboard & upload screen
│   └── printer/         # Printer dashboard
├── services/            # Firebase services (Auth, Firestore, Storage)
└── main.dart
```

### Detailed file structure:
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

---

### Firebase Setup
```bash
users (collection)
 └─ {uid} (document)
      ├─ uid
      ├─ name
      ├─ email
      ├─ phone
      ├─ studentId
      └─ userType (student/printer)

print_requests (collection)
 └─ {requestId} (document)
      ├─ studentId
      ├─ fileName
      ├─ fileUrl
      ├─ preferences
      ├─ status
      └─ totalCost

counters (collection)  # For generating incremental print IDs
```
    
### Firestore Security Rules
```bash
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /print_requests/{requestId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null &&
                  (resource.data.studentId == request.auth.uid || isPrinterUser());
      allow update: if request.auth != null && isPrinterUser();
      allow delete: if false;
    }

    match /counters/{document} {
      allow read, write: if request.auth != null;
    }

    function isPrinterUser() {
      return request.auth.token.email == 'printer@mmcoe.edu.in';
    }
  }
}
```

---

## Usage

1. Student Flow

  -  Login or signup using a college email ending with @mmcoe.edu.in.

  - Upload PDFs with your printing preferences.

  - Track the status of your print requests.

2. Printer Flow

  - Login using the printer credentials (stored in printers collection).

  - View all student print requests.

  - Update the status of each request (Ready / Collected).

### Contributing

Contributions are welcome! (& needed xd)
