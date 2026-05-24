# RazakEvent

An event management system built specifically for Kolej Tun Razak (KTR) at Universiti Teknologi Malaysia (UTM). This Flutter mobile app centralizes event management, document workflow, event participation and feedback, volunteer management, equipment borrowing and certification for all KTR students, organizers, secretaries, and admins.

---

## Modules

### Sprint 1 — User Authentication & Profile Management Module
Handles user registration, login, logout, password reset, and profile management. Supports four user roles: Student, Organizer Head, Secretary, and Admin.

### Sprint 2 — Event Documentation & Management Module
Allows Organizer Heads to manage event details and create feedback forms. Organizer heads for excos and clubs manage event details and feedback forms. Secretaries upload and track official event documents for events. Admins review and approve or reject submitted documents.

### Sprint 3 — Event Participation Module 
Allows students to browse and register for approved events, complete payment of registration fee with stripe payment, and submit dynamic feedback forms. Organizer Heads can view registrant lists, feedback responses with AI-generated summaries using Gemini API.

### Sprint 3 — Volunteer Recruitment Module
Allows students to apply for volunteer positions and track their application status. Organizer heads can manage volunteer slots, and review volunteer applications.

### Sprint 4 — Equipment Management *(planned)*
Will allow Organizer Heads to submit equipment borrowing requests, and Admins to approve requests and issue certificates to event participants.

### Sprint 4 — Certification Management *(planned)*
Will allow Admins to issue certificates to event participants and volunteers.

---

## User Roles

| Role | Description |
|---|---|
| Student | Browse events, register, submit feedback, apply for volunteer positions |
| Organizer Head | Manage events, view registration and feedback responses, manage volunteer slots and applications |
| Secretary | Upload and track event official documents |
| Admin | Review event official documents, approve equipment requests, issue certificates |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter, Dart |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| AI Summary | Gemini API |
| Payment | Stripe |
| Localization | Flutter Intl, ARB files (EN/BM) |

---

## Project Structure

RazakEvent uses a feature-based layered Flutter folder structure separating shared resources, data, and feature modules.

```text
lib/
├── main.dart
│
├── core/
│   ├── constants/          # App colors, text styles, and constants
│   ├── localization/       # Locale controller for EN/BM switching
│   ├── routes/             # App route names (app_routes.dart)
│   ├── theme/              # App-wide Material 3 theme configuration
│   ├── utils/              # Validators and helper functions
│   └── widgets/            # Reusable UI components
│
├── data/
│   ├── models/             # Shared data models (UserModel, EventModel, etc.)
│   ├── repository/         # Shared data logic and Firestore queries
│   └── services/           # Firebase, Gemini, and Stripe service classes
│
├── l10n/                   # ARB localization files (app_en.arb, app_ms.arb)
│
└── features/
    ├── auth/               # Login, register, forgot password
        ├── logic/          # Controllers for authentication
        └── presentation/   # Screens for authentication
    ├── profile/            # Manage profile
        ├── logic/          # Controllers for profile logic
        └── presentation/   # Screens for profile
    ├── home/               # Role-based dashboard
        ├── logic/          # Controllers for home dashboard screen logic
        └── presentation/   # Screens for home
    ├── splash/             # Splash screen
        ├── logic/          # Controllers for splash logic
        └── presentation/   # Screens for splash page
    ├── documents/          # Document upload, review, and status tracking
        ├── logic/          # Controllers for document management
        └── presentation/   # Screens for document upload, review and status
    ├── events/             # Browse events, event detail, register for event
        ├── logic/          # Controllers for events management and participation
        └── presentation/   # Screens for events management and participation
    ├── feedback/           # Submit feedback form, view feedback responses
        ├── logic/          # Controllers for feedback form
        └── presentation/   # Screens for feedback form
    └── volunteer/          # Volunteer slots, applications, and review
        ├── logic/          # Controllers for volunteer recruitment
        └── presentation/   # Screens for volunteer recruitment
```

---

## Firestore Collections

| Collection | Description |
|---|---|
| `users` | User profiles and roles |
| `events` | Event details created by Organizer Heads |
| `registrations` | Student event registrations |
| `feedback` | Student feedback responses per event |
| `volunteerSlots` | Volunteer positions created per event |
| `volunteerApplications` | Student applications for volunteer positions |

---

## Environment Variables

Create a `.env` file or configure the required API keys before running Sprint 3 features.

```text
STRIPE_PUBLISHABLE_KEY=your_stripe_sandbox_key
GEMINI_API_KEY=your_gemini_api_key
```

Never commit real API keys to GitHub. Add `.env` to `.gitignore`.

---

## Localization

RazakEvent supports English (EN) and Bahasa Malaysia (BM). UI strings are stored in:

```text
lib/l10n/app_en.arb
lib/l10n/app_ms.arb
```

After adding new localization keys, run:

```bash
flutter gen-l10n
```

---

## Getting Started

To run this project locally:

```bash
git clone https://github.com/Leena17111/razakevent.git
cd razakevent
flutter pub get
flutter run
```

Make sure Flutter is installed and an emulator or physical device is running before executing the `flutter run` command.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Additional Resources

- Firebase Flutter Setup: https://firebase.google.com/docs/flutter/setup
- Gemini API Documentation: https://ai.google.dev/
- Stripe Documentation: https://docs.stripe.com/