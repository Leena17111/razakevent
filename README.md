# razakevent

An event management system built specifically for Kolej Tun Razak (KTR) at Universiti Teknologi Malaysia (UTM). This cross-platform app aims to help centralize the process of managing events, managing paper workflow, events participation, as well as equipment and certification management.

# Modules

User authentication and profile management: allows registration by users, authenticating users, managing their profiles, and logging out securely.

Event management: Helps admins and organizers (club and community) manage upcoming events and paper workflow at KTR.

Event participation: helps students browse upcoming events, apply for events, volunteer and submit feedback.

Equipment and certification management: helps admins and organizers coordinate the process of equipment borrowing, and receiving ceritificates after the events.


# Tech stack

- **Frontend / Mobile App:** Flutter, Dart
- **Backend / Cloud Services:** Firebase Authentication and Cloud Firestore
- **Database:** Cloud Firestore

## Project Structure

RazakEvent uses a feature-based layered Flutter folder structure. The project is organized to separate shared resources, shared data files, and feature modules so that the codebase can grow across future sprints without becoming messy.

```text
lib/
├── main.dart
│
├── core/
│   ├── constants/      # Shared app colors, text styles, and constants
│   ├── theme/          # App-wide theme configuration
│   ├── utils/          # Validators and helper functions
│   └── widgets/        # Reusable UI components
│
├── data/               # Common/shared data layer used by multiple features
│   ├── models/         # Shared models, e.g. UserModel
│   ├── repositories/   # Shared app-level data logic
│   └── services/       # Shared Firebase/Auth/Firestore service functions
│
└── features/           # App modules organized by feature
    └── <feature_name>/
        ├── presentation/   # Screens and UI
        ├── logic/          # Controllers and screen behavior
        └── data/           # Optional Feature-specific models, repositories, and services if needed

## Getting Started

To run this project locally:

```bash
git clone https://github.com/Leena17111/razakevent.git
cd razakevent
flutter pub get
flutter run
```

Make sure Flutter is installed and an emulator or physical device is running before executing flutter run command

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
