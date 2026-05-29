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
  static const String adminDocumentDashboard = '/documents/admin-dashboard';
  static const String adminPendingReviews = '/documents/admin-pending-reviews';
  static const String adminReviewedDocuments = '/documents/admin-reviewed';
  static const String adminReviewDocument = '/documents/review/detail';
  static const String createEventFeedbackForm = '/feedback/create';
 

  static const String documentDetails = '/documents/details';
  static const String editDocument = '/documents/edit';
  static const String secretaryProposedEvents = '/documents/proposed-events';
  static const String secretaryEventDetail = '/documents/proposed-events/detail';

  // Sprint 3 — Epic 1: Event Participation & Feedback Module

  // Student Event Participation
  static const String browseEvents = '/events/browse';
  static const String eventDetail = '/events/detail';
  static const String registerEvent = '/events/register';
  static const String registrationSuccess = '/events/register/success';
  static const String myRegisteredEvents = '/events/my-registered';

  // Student Feedback
  static const String submitFeedback = '/feedback/submit';

  // Organizer Feedback & Registrations
  static const String eventResponsesSelect = '/events/responses/select';
  static const String eventRegistrants = '/events/responses/registrants';
  static const String eventFeedbackResponses = '/events/responses/feedback';


  // Sprint 3 — Epic 2: Volunteer Management Module

  // Student Volunteer
  static const String volunteerPositions = '/volunteer/positions';
  static const String applyVolunteer = '/volunteer/apply';
  static const String myVolunteerApplications = '/volunteer/my-applications';

  // Organizer Volunteer Management
  static const String volunteerManagement = '/volunteer/management';
  static const String addVolunteerPosition = '/volunteer/add-position';
  static const String reviewApplications = '/volunteer/review-applications';
  static const String studentVolunteerPositions = '/student-volunteer-positions';
}