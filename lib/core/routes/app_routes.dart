// lib/core/routes/app_routes.dart

class AppRoutes {
  AppRoutes._();

  // Sprint 1
  static const String splash = '/';
  static const String register = '/register';
  static const String login = '/login';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String profile = '/profile';

  // Sprint 2 
  static const String eventDetailsList = '/event-details';
  static const String addEventDetails = '/event-details/add';
  static const String editEventDetails = '/event-details/edit';
  static const String uploadEventDocument = '/documents/upload';
  static const String trackEventDocumentStatus = '/documents/status';
  static const String reviewEventDocuments = '/documents/review';
  static const String createEventFeedbackForm = '/feedback/create';
}