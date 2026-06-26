# RazakEvent

An event management system built specifically for Kolej Tun Razak (KTR) at Universiti Teknologi Malaysia (UTM). This Flutter mobile app centralizes event management, document workflow, event participation and feedback, volunteer management, equipment borrowing and certification for all KTR students, organizers, secretaries, and admins.

---

## Modules

### Sprint 1 — User Authentication & Profile Management Module
Handles user registration, login, logout, password reset, and profile management. Supports four user roles: Student, Organizer Head, Secretary, and Admin.

### Sprint 2 — Event Documentation & Management Module
Allows Organizer Heads to manage event details and create feedback forms. Organizer heads for excos and clubs manage event details and feedback forms. Secretaries upload and track official event documents for events. Admins review and approve or reject submitted documents.

### Sprint 3 — Event Participation Module 
Allows students to browse and register for approved events, complete payment of registration fee with stripe payment, and submit dynamic feedback forms. Organizer Heads can view registrant lists, feedback responses with AI-generated summaries using Groq API.

### Sprint 3 — Volunteer Recruitment Module
Allows students to apply for volunteer positions and track their application status. Organizer heads can manage volunteer slots, and review volunteer applications.

### Sprint 4 — Equipment Borrowing Management 
Allows Admins to manage equipment inventory by adding, editing, and updating equipment availability status. Organizer Heads can borrow equipment for eligible events, submit special equipment requests form for admin review, view borrowed equipment, and upload photo evidence when returning borrowed items. Admins can review and approve or reject special equipment requests.

### Sprint 4 — Certification Module
Allows Students to view and download automatically generated certificates issued for event participation and volunteer involvement.

---

## User Roles

| Role | Description |
|---|---|
| Student | Browse events, register for events, submit feedback, apply for volunteer positions, track application status, and view certificates |
| Organizer Head | Manage event details, create feedback forms, view registration and feedback responses, manage volunteer positions and applications, borrow equipment, request special equipment, view borrowed equipment, and submit return evidence |
| Secretary | Upload and track official event documents |
| Admin | Review event documents, manage equipment inventory, review special equipment requests, and oversee the overall event management process |
---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter, Dart |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| AI Summary | Groq API |
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
│   └── services/           # Firebase, Groq, and Stripe service classes
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
    ├── equipment/          # Equipment inventory, borrowing, return, and special requests
        │   ├── logic/          # Controllers for equipment management
        │   └── presentation/   # Screens for equipment management
    └── certificates/       # Certificate generation, viewing, and download
        ├── logic/          # Controllers and trigger services for certificates
        └── presentation/   # Screens for certificate viewing and preview
```

---

## Firestore Collections

| Collection | Description |
|---|---|
| `certificates` | Generated certificates for event participants and volunteers |
| `documents` | Official event documents uploaded by Secretaries and reviewed by Admin |
| `equipment` | Equipment inventory records managed by Admin |
| `equipmentBorrowRequests` | Equipment borrowing records and return status |
| `eventRegistrations` | Student event registration records |
| `events` | Event details created by Organizer Heads |
| `feedbackForms` | Feedback forms created by Organizer Heads |
| `feedbackResponses` | Student feedback responses submitted for events |
| `registrationCodes` | Verification codes used for role-based registration |
| `specialEquipmentRequests` | Special equipment requests submitted by Organizer Heads and reviewed by Admin |
| `users` | User profiles, roles, and account information |
| `volunteerApplications` | Student applications for volunteer positions |
| `volunteerPositions` | Volunteer positions created for events |

---

## Environment Variables

Create a `.env` file or configure the required API keys before running Sprint 3 features.

```text
STRIPE_PUBLISHABLE_KEY=your_stripe_sandbox_key
GROQ_API_KEY=your_groq_api_key
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
- Groq API Documentation: https://console.groq.com/docs
- Stripe Documentation: https://docs.stripe.com/
