import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Stripe: initialize before runApp
import 'core/constants/app_colors.dart';
import 'core/localization/locale_controller.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/documents/presentation/document_details_screen.dart';
import 'features/documents/presentation/document_status_screen.dart';
import 'features/documents/presentation/edit_document_screen.dart';
import 'features/documents/presentation/upload_document_screen.dart';
import 'features/documents/presentation/admin_document_dashboard_screen.dart';
import 'features/documents/presentation/admin_pending_reviews_screen.dart';
import 'features/documents/presentation/admin_review_document_screen.dart';
import 'features/documents/presentation/admin_reviewed_documents_screen.dart';
import 'features/events/presentation/event_details_list_screen.dart';
import 'features/events/presentation/browse_events_screen.dart';
import 'features/feedback/presentation/create_feedback_form_screen.dart';
import 'features/feedback/presentation/organizer_event_select_screen.dart';
import 'features/feedback/presentation/feedback_list_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/profile/presentation/manage_profile_screen.dart';
import 'features/documents/presentation/secretary_proposed_events_screen.dart';
import 'features/documents/presentation/secretary_event_detail_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'features/events/presentation/event_detail_screen.dart';
import 'features/volunteer/presentation/volunteer_event_select_screen.dart';
import 'features/events/presentation/event_registration_screen.dart';
import 'features/volunteer/presentation/student_volunteer_positions_screen.dart';
import 'features/equipment/presentation/manage_equipment_screen.dart';
import 'features/equipment/presentation/equipment_form_screen.dart';
import 'features/equipment/presentation/borrow_event_select_screen.dart';
import 'features/equipment/presentation/return_borrowed_equipment_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stripe: only initialize on mobile â€” flutter_stripe does not support web.
  // On web, the payment button will show a message directing users to the app.
  if (!kIsWeb) {
    Stripe.publishableKey =
        'pk_test_51Ta6LqJCG09jyIk1UrF7IMTwCppku8SkbAbE9kspuX1jCTVUZe4JviBF95E0ilZQ9heGKSmk8AQiuJZlBOaB2QoB00qJkpXxyd';
    await Stripe.instance.applySettings();
  }

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCKaudeyyJJsWkVuAAHgyaG85_Iws-RDE8',
        appId: '1:595633177345:web:b00c46d56c52df9a105100',
        messagingSenderId: '595633177345',
        projectId: 'razakevent-b4852',
        authDomain: 'razakevent-b4852.firebaseapp.com',
        storageBucket: 'razakevent-b4852.firebasestorage.app',
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const RazakEventApp());
}

class RazakEventApp extends StatelessWidget {
  const RazakEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'RazakEvent',
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
            ),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.register: (context) => const RegisterScreen(),
            AppRoutes.resetPassword: (context) => const ForgotPasswordScreen(),
            AppRoutes.home: (context) => const HomeScreen(),
            AppRoutes.profile: (context) => const ManageProfileScreen(),
            AppRoutes.uploadEventDocument: (_) => const UploadDocumentScreen(),
            AppRoutes.trackEventDocumentStatus: (_) =>
                const DocumentStatusScreen(),
            AppRoutes.documentDetails: (_) => const DocumentDetailsScreen(),
            AppRoutes.editDocument: (_) => const EditDocumentScreen(),
            AppRoutes.reviewEventDocuments: (_) =>
                const AdminDocumentDashboardScreen(),
            AppRoutes.adminDocumentDashboard: (_) =>
                const AdminDocumentDashboardScreen(),
            AppRoutes.adminPendingReviews: (_) =>
                const AdminPendingReviewsScreen(),
            AppRoutes.adminReviewedDocuments: (_) =>
                const AdminReviewedDocumentsScreen(),
            AppRoutes.adminReviewDocument: (_) =>
                const AdminReviewDocumentScreen(),
            AppRoutes.eventDetailsList: (_) => const EventDetailsListScreen(),
            AppRoutes.createEventFeedbackForm: (_) =>
                const CreateFeedbackFormScreen(),
            AppRoutes.secretaryProposedEvents: (_) =>
                const SecretaryProposedEventsScreen(),
            AppRoutes.secretaryEventDetail: (_) =>
                const SecretaryEventDetailScreen(),

            // Sprint 3 â€” Epic 1: Event Participation & Feedback Module

            // Student Event Participation
            AppRoutes.browseEvents: (_) => const BrowseEventsScreen(),
            AppRoutes.eventDetail: (_) => const EventDetailScreen(),
            AppRoutes.registerEvent: (_) => const EventRegistrationScreen(),
            AppRoutes.registrationSuccess: (_) => const Scaffold(
              body: Center(child: Text('Registration Success')),
            ),
            AppRoutes.myRegisteredEvents: (_) => const Scaffold(
              body: Center(child: Text('My Registered Events')),
            ),

            // Student Feedback
            AppRoutes.submitFeedback: (_) => const FeedbackListScreen(),

            // Organizer Feedback & Registrations
            AppRoutes.eventResponsesSelect: (_) =>
                const OrganizerEventSelectScreen(),
            AppRoutes.eventRegistrants: (_) =>
                const Scaffold(body: Center(child: Text('Event Registrants'))),
            AppRoutes.eventFeedbackResponses: (_) => const Scaffold(
              body: Center(child: Text('Event Feedback Responses')),
            ),

            // Sprint 3 â€” Epic 2: Volunteer Recruitment Module

            // Student Volunteer
            AppRoutes.volunteerPositions: (_) =>
                const StudentVolunteerPositionsScreen(),
            AppRoutes.applyVolunteer: (_) =>
                const Scaffold(body: Center(child: Text('Apply Volunteer'))),
            AppRoutes.myVolunteerApplications: (_) => const Scaffold(
              body: Center(child: Text('My Volunteer Applications')),
            ),

            // Organizer Volunteer Recruitment
            // Organizer Volunteer Recruitment
            AppRoutes.volunteerManagement: (_) =>
                const VolunteerEventSelectScreen(mode: 'add'),

            AppRoutes.addVolunteerPosition: (_) =>
                const VolunteerEventSelectScreen(mode: 'add'),

            AppRoutes.reviewApplications: (_) =>
                const VolunteerEventSelectScreen(mode: 'review'),
            AppRoutes.studentVolunteerPositions: (_) =>
                const StudentVolunteerPositionsScreen(),

            // Sprint 4 â€” Epic 1: Equipment Borrowing Management

            // Admin Equipment
            AppRoutes.equipmentInventory: (_) => const ManageEquipmentScreen(),

            AppRoutes.addEquipment: (_) => const EquipmentFormScreen(),

            AppRoutes.editEquipment: (_) => const EquipmentFormScreen(),

            AppRoutes.reviewSpecialEquipmentRequests: (_) => const Scaffold(
              body: Center(child: Text('Review Special Equipment Requests')),
            ),

            // Organizer Equipment
            AppRoutes.selectEquipmentEvent: (_) =>
                const BorrowEventSelectScreen(),

            AppRoutes.availableEquipment: (_) =>
                const BorrowEventSelectScreen(),

            AppRoutes.viewBorrowedEquipment: (_) =>
                const BorrowEventSelectScreen(),

            AppRoutes.requestSpecialEquipment: (_) =>
                const BorrowEventSelectScreen(),

            AppRoutes.returnBorrowedEquipment: (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as ReturnBorrowedEquipmentArguments;
              return ReturnBorrowedEquipmentScreen(
                request: args.request,
                eventDate: args.eventDate,
              );
            },

            AppRoutes.cancelBorrowedEquipment: (_) => const Scaffold(
              body: Center(child: Text('Cancel Borrowed Equipment')),
            ),

            // Sprint 4 â€” Epic 2: Certification Management
            AppRoutes.certificates: (_) =>
                const Scaffold(body: Center(child: Text('Certificates'))),

            AppRoutes.certificatePreview: (_) => const Scaffold(
              body: Center(child: Text('Certificate Preview')),
            ),
          },
        );
      },
    );
  }
}
