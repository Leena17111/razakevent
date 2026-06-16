import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
  ];

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get languageEnglish;

  /// No description provided for @languageMalay.
  ///
  /// In en, this message translates to:
  /// **'BM'**
  String get languageMalay;

  /// No description provided for @uploadEventDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload Event Document'**
  String get uploadEventDocument;

  /// No description provided for @submitDocumentationForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit documentation for review'**
  String get submitDocumentationForReview;

  /// No description provided for @organizationType.
  ///
  /// In en, this message translates to:
  /// **'Organization Type'**
  String get organizationType;

  /// No description provided for @exco.
  ///
  /// In en, this message translates to:
  /// **'Exco'**
  String get exco;

  /// No description provided for @club.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get club;

  /// No description provided for @eventDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Event/Document Title'**
  String get eventDocumentTitle;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get documentType;

  /// No description provided for @selectDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Select document type'**
  String get selectDocumentType;

  /// No description provided for @preEventPaperwork.
  ///
  /// In en, this message translates to:
  /// **'Pre-event Paperwork'**
  String get preEventPaperwork;

  /// No description provided for @programReport.
  ///
  /// In en, this message translates to:
  /// **'Program Report'**
  String get programReport;

  /// No description provided for @financialReport.
  ///
  /// In en, this message translates to:
  /// **'Financial Report'**
  String get financialReport;

  /// No description provided for @uploadPdfDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF Document'**
  String get uploadPdfDocument;

  /// No description provided for @choosePdfFile.
  ///
  /// In en, this message translates to:
  /// **'Choose PDF file'**
  String get choosePdfFile;

  /// No description provided for @pdfOnlyMax10mb.
  ///
  /// In en, this message translates to:
  /// **'PDF only, max 10MB'**
  String get pdfOnlyMax10mb;

  /// No description provided for @remarksOptional.
  ///
  /// In en, this message translates to:
  /// **'Remarks (Optional)'**
  String get remarksOptional;

  /// No description provided for @additionalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add any additional notes or comments...'**
  String get additionalNotesHint;

  /// No description provided for @submitDocument.
  ///
  /// In en, this message translates to:
  /// **'Submit Document'**
  String get submitDocument;

  /// No description provided for @reviewDocument.
  ///
  /// In en, this message translates to:
  /// **'Review Document'**
  String get reviewDocument;

  /// No description provided for @pdfPreview.
  ///
  /// In en, this message translates to:
  /// **'PDF Preview'**
  String get pdfPreview;

  /// No description provided for @documentInformation.
  ///
  /// In en, this message translates to:
  /// **'Document Information'**
  String get documentInformation;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get eventTitle;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @submittedBy.
  ///
  /// In en, this message translates to:
  /// **'Submitted By'**
  String get submittedBy;

  /// No description provided for @submittedDate.
  ///
  /// In en, this message translates to:
  /// **'Submitted Date'**
  String get submittedDate;

  /// No description provided for @reviewActions.
  ///
  /// In en, this message translates to:
  /// **'Review Actions'**
  String get reviewActions;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @requestCorrection.
  ///
  /// In en, this message translates to:
  /// **'Request Correction'**
  String get requestCorrection;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @reviewList.
  ///
  /// In en, this message translates to:
  /// **'Review List'**
  String get reviewList;

  /// No description provided for @reviewDetail.
  ///
  /// In en, this message translates to:
  /// **'Review Detail'**
  String get reviewDetail;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @manageYourEventInformation.
  ///
  /// In en, this message translates to:
  /// **'Manage your event information'**
  String get manageYourEventInformation;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @eventList.
  ///
  /// In en, this message translates to:
  /// **'Event List'**
  String get eventList;

  /// No description provided for @addEventDetails.
  ///
  /// In en, this message translates to:
  /// **'Add Event Details'**
  String get addEventDetails;

  /// No description provided for @editEventDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Event Details'**
  String get editEventDetails;

  /// No description provided for @completeYourEventInformation.
  ///
  /// In en, this message translates to:
  /// **'Complete your event information'**
  String get completeYourEventInformation;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @eventDescription.
  ///
  /// In en, this message translates to:
  /// **'Event Description'**
  String get eventDescription;

  /// No description provided for @describeYourEvent.
  ///
  /// In en, this message translates to:
  /// **'Describe your event...'**
  String get describeYourEvent;

  /// No description provided for @eventPoster.
  ///
  /// In en, this message translates to:
  /// **'Event Poster'**
  String get eventPoster;

  /// No description provided for @uploadPosterImage.
  ///
  /// In en, this message translates to:
  /// **'Upload poster image'**
  String get uploadPosterImage;

  /// No description provided for @pngJpgUpTo5mb.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPG up to 5MB'**
  String get pngJpgUpTo5mb;

  /// No description provided for @eventDateTime.
  ///
  /// In en, this message translates to:
  /// **'Event Date & Time'**
  String get eventDateTime;

  /// No description provided for @venue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venue;

  /// No description provided for @registrationSettings.
  ///
  /// In en, this message translates to:
  /// **'Registration Settings'**
  String get registrationSettings;

  /// No description provided for @enableRegistration.
  ///
  /// In en, this message translates to:
  /// **'Enable Registration'**
  String get enableRegistration;

  /// No description provided for @eventStatus.
  ///
  /// In en, this message translates to:
  /// **'Event Status'**
  String get eventStatus;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @academic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get academic;

  /// No description provided for @spiritual.
  ///
  /// In en, this message translates to:
  /// **'Spiritual'**
  String get spiritual;

  /// No description provided for @welfare.
  ///
  /// In en, this message translates to:
  /// **'Welfare'**
  String get welfare;

  /// No description provided for @entrepreneurship.
  ///
  /// In en, this message translates to:
  /// **'Entrepreneurship'**
  String get entrepreneurship;

  /// No description provided for @culture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get culture;

  /// No description provided for @artsAndMedia.
  ///
  /// In en, this message translates to:
  /// **'Arts & Media'**
  String get artsAndMedia;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @saveEvent.
  ///
  /// In en, this message translates to:
  /// **'Save Event'**
  String get saveEvent;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @eventDetailsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Event details saved successfully.'**
  String get eventDetailsSavedSuccessfully;

  /// No description provided for @eventDetailsUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Event details updated successfully.'**
  String get eventDetailsUpdatedSuccessfully;

  /// No description provided for @addFeedbackForm.
  ///
  /// In en, this message translates to:
  /// **'Add Feedback Form'**
  String get addFeedbackForm;

  /// No description provided for @setUpEventFeedbackCollection.
  ///
  /// In en, this message translates to:
  /// **'Set up event feedback collection'**
  String get setUpEventFeedbackCollection;

  /// No description provided for @selectEvent.
  ///
  /// In en, this message translates to:
  /// **'Select Event'**
  String get selectEvent;

  /// No description provided for @chooseEvent.
  ///
  /// In en, this message translates to:
  /// **'Choose event'**
  String get chooseEvent;

  /// No description provided for @noEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No events found. Create an event first.'**
  String get noEventsFound;

  /// No description provided for @builtInQuestions.
  ///
  /// In en, this message translates to:
  /// **'Built-in Questions'**
  String get builtInQuestions;

  /// No description provided for @satisfactionQuestion.
  ///
  /// In en, this message translates to:
  /// **'How satisfied are you with this event?'**
  String get satisfactionQuestion;

  /// No description provided for @organizedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Was the event well-organized?'**
  String get organizedQuestion;

  /// No description provided for @recommendQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you recommend this event to others?'**
  String get recommendQuestion;

  /// No description provided for @additionalFeedbackQuestion.
  ///
  /// In en, this message translates to:
  /// **'Any additional feedback or suggestions?'**
  String get additionalFeedbackQuestion;

  /// No description provided for @customQuestionsOptional.
  ///
  /// In en, this message translates to:
  /// **'Custom Questions (Optional)'**
  String get customQuestionsOptional;

  /// No description provided for @enterCustomQuestion.
  ///
  /// In en, this message translates to:
  /// **'Enter your custom question'**
  String get enterCustomQuestion;

  /// No description provided for @utmSmartMerit.
  ///
  /// In en, this message translates to:
  /// **'UTM Smart Merit'**
  String get utmSmartMerit;

  /// No description provided for @utmSmartMeritNote.
  ///
  /// In en, this message translates to:
  /// **'RazakEvent displays the QR/link only. UTM Smart handles merit scanning.'**
  String get utmSmartMeritNote;

  /// No description provided for @uploadQrCode.
  ///
  /// In en, this message translates to:
  /// **'Upload QR Code'**
  String get uploadQrCode;

  /// No description provided for @pasteMeritLink.
  ///
  /// In en, this message translates to:
  /// **'Paste Merit Link'**
  String get pasteMeritLink;

  /// No description provided for @uploadUtmSmartQrCode.
  ///
  /// In en, this message translates to:
  /// **'Upload UTM Smart QR Code'**
  String get uploadUtmSmartQrCode;

  /// No description provided for @pngJpgUpTo2mb.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPG up to 2MB'**
  String get pngJpgUpTo2mb;

  /// No description provided for @previewForm.
  ///
  /// In en, this message translates to:
  /// **'Preview Form'**
  String get previewForm;

  /// No description provided for @saveFeedbackForm.
  ///
  /// In en, this message translates to:
  /// **'Save Feedback Form'**
  String get saveFeedbackForm;

  /// No description provided for @documentStatus.
  ///
  /// In en, this message translates to:
  /// **'Document Status'**
  String get documentStatus;

  /// No description provided for @searchDocuments.
  ///
  /// In en, this message translates to:
  /// **'Search documents or organizations...'**
  String get searchDocuments;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get filterApproved;

  /// No description provided for @filterRevision.
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get filterRevision;

  /// No description provided for @filterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get filterRejected;

  /// No description provided for @totalDocuments.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalDocuments;

  /// No description provided for @noDocumentsYet.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocumentsYet;

  /// No description provided for @uploadFirstDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload your first document to get started.'**
  String get uploadFirstDocument;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @statusPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get statusPendingReview;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusNeedsCorrection.
  ///
  /// In en, this message translates to:
  /// **'Needs Correction'**
  String get statusNeedsCorrection;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @documentDetails.
  ///
  /// In en, this message translates to:
  /// **'Document Details'**
  String get documentDetails;

  /// No description provided for @documentPdf.
  ///
  /// In en, this message translates to:
  /// **'Document PDF'**
  String get documentPdf;

  /// No description provided for @submissionDetails.
  ///
  /// In en, this message translates to:
  /// **'Submission Details'**
  String get submissionDetails;

  /// No description provided for @reviewedDate.
  ///
  /// In en, this message translates to:
  /// **'Reviewed Date'**
  String get reviewedDate;

  /// No description provided for @reviewedBy.
  ///
  /// In en, this message translates to:
  /// **'Reviewed By'**
  String get reviewedBy;

  /// No description provided for @correctionRequired.
  ///
  /// In en, this message translates to:
  /// **'Correction Required'**
  String get correctionRequired;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectionReason;

  /// No description provided for @documentSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Document Submitted!'**
  String get documentSubmitted;

  /// No description provided for @documentSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your document has been submitted for review. You can track its status in the Document Status screen.'**
  String get documentSubmittedMessage;

  /// No description provided for @uploadAnother.
  ///
  /// In en, this message translates to:
  /// **'Upload Another'**
  String get uploadAnother;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @registrationDeadline.
  ///
  /// In en, this message translates to:
  /// **'Registration Deadline'**
  String get registrationDeadline;

  /// No description provided for @participantCapacity.
  ///
  /// In en, this message translates to:
  /// **'Participant Capacity'**
  String get participantCapacity;

  /// No description provided for @registrationFeeRm.
  ///
  /// In en, this message translates to:
  /// **'Registration Fee (RM)'**
  String get registrationFeeRm;

  /// No description provided for @contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get contactPerson;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'registered'**
  String get registered;

  /// No description provided for @registrationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Registration disabled'**
  String get registrationDisabled;

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events added yet.'**
  String get noEventsYet;

  /// No description provided for @addFirstEvent.
  ///
  /// In en, this message translates to:
  /// **'Try adding your first event.'**
  String get addFirstEvent;

  /// No description provided for @organizerProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load organizer profile.'**
  String get organizerProfileLoadError;

  /// No description provided for @organizationDetailsMissing.
  ///
  /// In en, this message translates to:
  /// **'Please make sure the account has organization details.'**
  String get organizationDetailsMissing;

  /// No description provided for @unableToLoadEvents.
  ///
  /// In en, this message translates to:
  /// **'Unable to load events.'**
  String get unableToLoadEvents;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get tryAgainLater;

  /// No description provided for @eventPosterRequired.
  ///
  /// In en, this message translates to:
  /// **'Event poster is required.'**
  String get eventPosterRequired;

  /// No description provided for @invalidPosterFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid poster file. Please upload PNG, JPG, or JPEG up to 5MB.'**
  String get invalidPosterFile;

  /// No description provided for @registrationDeadlineRequired.
  ///
  /// In en, this message translates to:
  /// **'Registration deadline is required.'**
  String get registrationDeadlineRequired;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'The field is required.'**
  String get fieldRequired;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number.'**
  String get enterValidNumber;

  /// No description provided for @enterValidFee.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid fee.'**
  String get enterValidFee;

  /// No description provided for @unableToSaveEventDetails.
  ///
  /// In en, this message translates to:
  /// **'Unable to save event details. Please try again.'**
  String get unableToSaveEventDetails;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteEventQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete event?'**
  String get deleteEventQuestion;

  /// No description provided for @deleteEventConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this event? This action cannot be undone.'**
  String get deleteEventConfirmation;

  /// No description provided for @eventDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Event deleted successfully.'**
  String get eventDeletedSuccessfully;

  /// No description provided for @unableToDeleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete event. Please try again.'**
  String get unableToDeleteEvent;

  /// No description provided for @secretaryProposedEvents.
  ///
  /// In en, this message translates to:
  /// **'Proposed Events'**
  String get secretaryProposedEvents;

  /// No description provided for @filterNeedsPaperwork.
  ///
  /// In en, this message translates to:
  /// **'Needs Paperwork'**
  String get filterNeedsPaperwork;

  /// No description provided for @filterSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get filterSubmitted;

  /// No description provided for @allEvents.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allEvents;

  /// No description provided for @secretaryProposedEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage event paperwork'**
  String get secretaryProposedEventsSubtitle;

  /// No description provided for @secretaryEventDetail.
  ///
  /// In en, this message translates to:
  /// **'Event Detail'**
  String get secretaryEventDetail;

  /// No description provided for @noPaperworkYet.
  ///
  /// In en, this message translates to:
  /// **'No paperwork submitted yet.'**
  String get noPaperworkYet;

  /// No description provided for @createPaperwork.
  ///
  /// In en, this message translates to:
  /// **'Create Paperwork'**
  String get createPaperwork;

  /// No description provided for @paperworkStatus.
  ///
  /// In en, this message translates to:
  /// **'Paperwork Status'**
  String get paperworkStatus;

  /// No description provided for @noProposedEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No proposed events yet.'**
  String get noProposedEventsYet;

  /// No description provided for @noProposedEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Events added by organizers will appear here.'**
  String get noProposedEventsSubtitle;

  /// No description provided for @paperworkSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Paperwork Submitted'**
  String get paperworkSubmitted;

  /// No description provided for @paperworkSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your paperwork has been submitted for admin review.'**
  String get paperworkSubmittedMessage;

  /// No description provided for @eventInfo.
  ///
  /// In en, this message translates to:
  /// **'Event Info'**
  String get eventInfo;

  /// No description provided for @registrationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Registration Enabled'**
  String get registrationEnabled;

  /// No description provided for @registrationDisabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration Disabled'**
  String get registrationDisabledLabel;

  /// No description provided for @allEventsPaperworkDone.
  ///
  /// In en, this message translates to:
  /// **'All events have paperwork submitted.'**
  String get allEventsPaperworkDone;

  /// No description provided for @noSubmittedPaperworkYet.
  ///
  /// In en, this message translates to:
  /// **'No submitted paperwork yet.'**
  String get noSubmittedPaperworkYet;

  /// No description provided for @editDocument.
  ///
  /// In en, this message translates to:
  /// **'Edit Document'**
  String get editDocument;

  /// No description provided for @deleteDocument.
  ///
  /// In en, this message translates to:
  /// **'Delete Document'**
  String get deleteDocument;

  /// No description provided for @deleteDocumentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this document? This action cannot be undone.'**
  String get deleteDocumentConfirmation;

  /// No description provided for @documentUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Document updated successfully.'**
  String get documentUpdatedSuccessfully;

  /// No description provided for @documentDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Document deleted successfully.'**
  String get documentDeletedSuccessfully;

  /// No description provided for @failedToDeleteDocument.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete document.'**
  String get failedToDeleteDocument;

  /// No description provided for @replacePdf.
  ///
  /// In en, this message translates to:
  /// **'Replace PDF'**
  String get replacePdf;

  /// No description provided for @cancelReplacement.
  ///
  /// In en, this message translates to:
  /// **'Cancel replacement'**
  String get cancelReplacement;

  /// No description provided for @newFileSelected.
  ///
  /// In en, this message translates to:
  /// **'New file selected'**
  String get newFileSelected;

  /// No description provided for @adminComment.
  ///
  /// In en, this message translates to:
  /// **'Admin Comment'**
  String get adminComment;

  /// No description provided for @adminCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add your review comments here...'**
  String get adminCommentHint;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @uploadSignedDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload Signed Document'**
  String get uploadSignedDocument;

  /// No description provided for @signedPdfWithDigitalSignature.
  ///
  /// In en, this message translates to:
  /// **'PDF with digital signature'**
  String get signedPdfWithDigitalSignature;

  /// No description provided for @reviewSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully.'**
  String get reviewSubmittedSuccessfully;

  /// No description provided for @documentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Document not found.'**
  String get documentNotFound;

  /// No description provided for @selectReviewActionError.
  ///
  /// In en, this message translates to:
  /// **'Please select a review action.'**
  String get selectReviewActionError;

  /// No description provided for @correctionCommentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please provide an admin comment when requesting correction.'**
  String get correctionCommentRequired;

  /// No description provided for @rejectionReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason is required'**
  String get rejectionReasonRequired;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User is not authenticated.'**
  String get userNotAuthenticated;

  /// No description provided for @unableToReadSelectedPdf.
  ///
  /// In en, this message translates to:
  /// **'Unable to read selected PDF file.'**
  String get unableToReadSelectedPdf;

  /// No description provided for @submissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed. Please try again.'**
  String get submissionFailed;

  /// No description provided for @invalidSignedDocumentFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid file. Please upload a PDF document up to 10MB.'**
  String get invalidSignedDocumentFile;

  /// No description provided for @fileSizeMustNotExceed10mb.
  ///
  /// In en, this message translates to:
  /// **'File size must not exceed 10MB. Your file is {sizeMB}MB.'**
  String fileSizeMustNotExceed10mb(String sizeMB);

  /// No description provided for @signedDocumentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload a signed document before approving.'**
  String get signedDocumentRequired;

  /// No description provided for @documentAlreadyReviewed.
  ///
  /// In en, this message translates to:
  /// **'This document has already been reviewed and cannot be submitted again.'**
  String get documentAlreadyReviewed;

  /// No description provided for @browseEvents.
  ///
  /// In en, this message translates to:
  /// **'Browse Events'**
  String get browseEvents;

  /// No description provided for @browseEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover events at KTR'**
  String get browseEventsSubtitle;

  /// No description provided for @studentLabel.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get studentLabel;

  /// No description provided for @welcomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeLabel;

  /// No description provided for @browseTab.
  ///
  /// In en, this message translates to:
  /// **'Browse Events'**
  String get browseTab;

  /// No description provided for @myRegisteredTab.
  ///
  /// In en, this message translates to:
  /// **'My Registered'**
  String get myRegisteredTab;

  /// No description provided for @searchEvents.
  ///
  /// In en, this message translates to:
  /// **'Search events...'**
  String get searchEvents;

  /// No description provided for @noEventsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get noEventsAvailable;

  /// No description provided for @noEventsDesc.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or category'**
  String get noEventsDesc;

  /// No description provided for @noRegisteredEvents.
  ///
  /// In en, this message translates to:
  /// **'No Registered Events'**
  String get noRegisteredEvents;

  /// No description provided for @noRegisteredEventsDesc.
  ///
  /// In en, this message translates to:
  /// **'You have not registered for any events yet'**
  String get noRegisteredEventsDesc;

  /// No description provided for @slotsLeft.
  ///
  /// In en, this message translates to:
  /// **'slots left'**
  String get slotsLeft;

  /// No description provided for @eventFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get eventFull;

  /// No description provided for @freeEvent.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeEvent;

  /// No description provided for @registeredCount.
  ///
  /// In en, this message translates to:
  /// **'registered'**
  String get registeredCount;

  /// No description provided for @deadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadlineLabel;

  /// No description provided for @detailsButton.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsButton;

  /// No description provided for @errorLoadingEvents.
  ///
  /// In en, this message translates to:
  /// **'Failed to load events'**
  String get errorLoadingEvents;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @navEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// No description provided for @navVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer'**
  String get navVolunteer;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get categorySports;

  /// No description provided for @categoryAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get categoryAcademic;

  /// No description provided for @categorySpiritual.
  ///
  /// In en, this message translates to:
  /// **'Spiritual'**
  String get categorySpiritual;

  /// No description provided for @categoryWelfare.
  ///
  /// In en, this message translates to:
  /// **'Welfare'**
  String get categoryWelfare;

  /// No description provided for @categoryEntrepreneurship.
  ///
  /// In en, this message translates to:
  /// **'Entrepreneurship'**
  String get categoryEntrepreneurship;

  /// No description provided for @categoryCulture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get categoryCulture;

  /// No description provided for @categoryArtsMedia.
  ///
  /// In en, this message translates to:
  /// **'Arts & Media'**
  String get categoryArtsMedia;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categorySafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get categorySafety;

  /// No description provided for @categoryOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get categoryOthers;

  /// No description provided for @organizerLabel.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizerLabel;

  /// No description provided for @dateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTimeLabel;

  /// No description provided for @venueLabel.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venueLabel;

  /// No description provided for @capacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacityLabel;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get contactLabel;

  /// No description provided for @aboutEvent.
  ///
  /// In en, this message translates to:
  /// **'ABOUT THIS EVENT'**
  String get aboutEvent;

  /// No description provided for @registrationFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'REGISTRATION FEE'**
  String get registrationFeeLabel;

  /// No description provided for @registrationDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'REGISTRATION DEADLINE'**
  String get registrationDeadlineLabel;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNow;

  /// No description provided for @eventFullMessage.
  ///
  /// In en, this message translates to:
  /// **'Event Full'**
  String get eventFullMessage;

  /// No description provided for @registrationClosed.
  ///
  /// In en, this message translates to:
  /// **'Registration Closed'**
  String get registrationClosed;

  /// No description provided for @volunteerManagement.
  ///
  /// In en, this message translates to:
  /// **'Volunteer Recruitment'**
  String get volunteerManagement;

  /// No description provided for @addVolunteerPositionsForYourEvent.
  ///
  /// In en, this message translates to:
  /// **'Add volunteer positions for your event'**
  String get addVolunteerPositionsForYourEvent;

  /// No description provided for @reviewVolunteerApplications.
  ///
  /// In en, this message translates to:
  /// **'Review volunteer applications'**
  String get reviewVolunteerApplications;

  /// No description provided for @organizerHead.
  ///
  /// In en, this message translates to:
  /// **'Organizer Head'**
  String get organizerHead;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events'**
  String get noUpcomingEvents;

  /// No description provided for @addEventsFirstBeforePositions.
  ///
  /// In en, this message translates to:
  /// **'Only open, upcoming, approved events can be used for volunteer positions.'**
  String get addEventsFirstBeforePositions;

  /// No description provided for @volunteerPositions.
  ///
  /// In en, this message translates to:
  /// **'Volunteer Positions'**
  String get volunteerPositions;

  /// No description provided for @addVolunteerPosition.
  ///
  /// In en, this message translates to:
  /// **'Add Volunteer Position'**
  String get addVolunteerPosition;

  /// No description provided for @addNewPosition.
  ///
  /// In en, this message translates to:
  /// **'Add New Position'**
  String get addNewPosition;

  /// No description provided for @noPositionsYet.
  ///
  /// In en, this message translates to:
  /// **'No positions yet'**
  String get noPositionsYet;

  /// No description provided for @tapBelowToAddPosition.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to add your first volunteer position.'**
  String get tapBelowToAddPosition;

  /// No description provided for @roleName.
  ///
  /// In en, this message translates to:
  /// **'Role Name'**
  String get roleName;

  /// No description provided for @roleNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Event Marshal'**
  String get roleNameHint;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @describeVolunteerDuties.
  ///
  /// In en, this message translates to:
  /// **'Describe the volunteer duties and responsibilities...'**
  String get describeVolunteerDuties;

  /// No description provided for @requirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get requirements;

  /// No description provided for @listSkillsAvailability.
  ///
  /// In en, this message translates to:
  /// **'List skills, availability, or qualifications needed...'**
  String get listSkillsAvailability;

  /// No description provided for @numberOfVolunteersNeeded.
  ///
  /// In en, this message translates to:
  /// **'Number of Volunteers Needed'**
  String get numberOfVolunteersNeeded;

  /// No description provided for @applicationDeadline.
  ///
  /// In en, this message translates to:
  /// **'Application Deadline'**
  String get applicationDeadline;

  /// No description provided for @savePosition.
  ///
  /// In en, this message translates to:
  /// **'Save Position'**
  String get savePosition;

  /// No description provided for @positionAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Position added successfully!'**
  String get positionAddedSuccessfully;

  /// No description provided for @enterValidVolunteerNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number greater than 0.'**
  String get enterValidVolunteerNumber;

  /// No description provided for @deadlineRequired.
  ///
  /// In en, this message translates to:
  /// **'Application deadline is required.'**
  String get deadlineRequired;

  /// No description provided for @deadlineMustBeBeforeEvent.
  ///
  /// In en, this message translates to:
  /// **'Application deadline must be before the event date.'**
  String get deadlineMustBeBeforeEvent;

  /// No description provided for @failedToSavePosition.
  ///
  /// In en, this message translates to:
  /// **'Failed to save position. Please try again.'**
  String get failedToSavePosition;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @registeredLabel.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registeredLabel;

  /// No description provided for @registeredOn.
  ///
  /// In en, this message translates to:
  /// **'Registered on'**
  String get registeredOn;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @openPositions.
  ///
  /// In en, this message translates to:
  /// **'Open Positions'**
  String get openPositions;

  /// No description provided for @myApplications.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get myApplications;

  /// No description provided for @applyForPosition.
  ///
  /// In en, this message translates to:
  /// **'Apply for Position'**
  String get applyForPosition;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @faculty.
  ///
  /// In en, this message translates to:
  /// **'Faculty'**
  String get faculty;

  /// No description provided for @selectFaculty.
  ///
  /// In en, this message translates to:
  /// **'Select faculty'**
  String get selectFaculty;

  /// No description provided for @previousExperience.
  ///
  /// In en, this message translates to:
  /// **'Previous Experience'**
  String get previousExperience;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitApplication;

  /// No description provided for @confirmAvailability.
  ///
  /// In en, this message translates to:
  /// **'I confirm my availability for this volunteer position'**
  String get confirmAvailability;

  /// No description provided for @noOpenPositions.
  ///
  /// In en, this message translates to:
  /// **'No open positions'**
  String get noOpenPositions;

  /// No description provided for @noApplicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get noApplicationsYet;

  /// No description provided for @applicationSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Application submitted successfully.'**
  String get applicationSubmittedSuccessfully;

  /// No description provided for @eventFeedback.
  ///
  /// In en, this message translates to:
  /// **'Event Feedback'**
  String get eventFeedback;

  /// No description provided for @shareYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Share your experience'**
  String get shareYourExperience;

  /// No description provided for @pendingFeedback.
  ///
  /// In en, this message translates to:
  /// **'PENDING FEEDBACK'**
  String get pendingFeedback;

  /// No description provided for @noFeedbackPending.
  ///
  /// In en, this message translates to:
  /// **'No pending feedback'**
  String get noFeedbackPending;

  /// No description provided for @noFeedbackPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'You have no events awaiting feedback.'**
  String get noFeedbackPendingDesc;

  /// No description provided for @feedbackFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Feedback'**
  String get feedbackFormTitle;

  /// No description provided for @builtInQuestionsSection.
  ///
  /// In en, this message translates to:
  /// **'BUILT-IN QUESTIONS'**
  String get builtInQuestionsSection;

  /// No description provided for @additionalQuestionsSection.
  ///
  /// In en, this message translates to:
  /// **'ADDITIONAL QUESTIONS'**
  String get additionalQuestionsSection;

  /// No description provided for @commentsHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us more about your experience...'**
  String get commentsHint;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @feedbackSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Feedback Submitted!'**
  String get feedbackSubmitted;

  /// No description provided for @feedbackSubmittedDesc.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback. Your response helps us improve future events.'**
  String get feedbackSubmittedDesc;

  /// No description provided for @backToList.
  ///
  /// In en, this message translates to:
  /// **'Back to List'**
  String get backToList;

  /// No description provided for @overallSatisfaction.
  ///
  /// In en, this message translates to:
  /// **'Overall Satisfaction'**
  String get overallSatisfaction;

  /// No description provided for @eventOrganization.
  ///
  /// In en, this message translates to:
  /// **'Event Organization'**
  String get eventOrganization;

  /// No description provided for @likelihoodToRecommend.
  ///
  /// In en, this message translates to:
  /// **'Likelihood to Recommend'**
  String get likelihoodToRecommend;

  /// No description provided for @overallExperience.
  ///
  /// In en, this message translates to:
  /// **'Overall Experience'**
  String get overallExperience;

  /// No description provided for @feedbackAlreadySubmitted.
  ///
  /// In en, this message translates to:
  /// **'You have already submitted feedback for this event.'**
  String get feedbackAlreadySubmitted;

  /// No description provided for @feedbackSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit feedback. Please try again.'**
  String get feedbackSubmitError;

  /// No description provided for @ratingRequired.
  ///
  /// In en, this message translates to:
  /// **'Please rate all questions before submitting.'**
  String get ratingRequired;

  /// No description provided for @openFor.
  ///
  /// In en, this message translates to:
  /// **'Open for'**
  String get openFor;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @filter3DaysLeft.
  ///
  /// In en, this message translates to:
  /// **'3 days left'**
  String get filter3DaysLeft;

  /// No description provided for @filter2DaysLeft.
  ///
  /// In en, this message translates to:
  /// **'2 days left'**
  String get filter2DaysLeft;

  /// No description provided for @filterLessThanDay.
  ///
  /// In en, this message translates to:
  /// **'Less than a day'**
  String get filterLessThanDay;

  /// No description provided for @filterDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'days remaining'**
  String get filterDaysRemaining;

  /// No description provided for @filterDayRemaining.
  ///
  /// In en, this message translates to:
  /// **'day remaining'**
  String get filterDayRemaining;

  /// No description provided for @filterHoursRemaining.
  ///
  /// In en, this message translates to:
  /// **'hours remaining'**
  String get filterHoursRemaining;

  /// No description provided for @registrationsAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Registrations & Feedback'**
  String get registrationsAndFeedback;

  /// No description provided for @selectEventToView.
  ///
  /// In en, this message translates to:
  /// **'Select an event to view'**
  String get selectEventToView;

  /// No description provided for @noRegistrantsYet.
  ///
  /// In en, this message translates to:
  /// **'No registrants yet'**
  String get noRegistrantsYet;

  /// No description provided for @noFeedbackYet.
  ///
  /// In en, this message translates to:
  /// **'No feedback yet'**
  String get noFeedbackYet;

  /// No description provided for @totalRegistrants.
  ///
  /// In en, this message translates to:
  /// **'Total Registrants'**
  String get totalRegistrants;

  /// No description provided for @totalResponses.
  ///
  /// In en, this message translates to:
  /// **'Total\nResponses'**
  String get totalResponses;

  /// No description provided for @avgRating.
  ///
  /// In en, this message translates to:
  /// **'Avg Rating'**
  String get avgRating;

  /// No description provided for @responseRate.
  ///
  /// In en, this message translates to:
  /// **'Response\nRate'**
  String get responseRate;

  /// No description provided for @groqAiSummary.
  ///
  /// In en, this message translates to:
  /// **'Groq AI Summary'**
  String get groqAiSummary;

  /// No description provided for @groqRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get groqRefresh;

  /// No description provided for @groqTapToGenerate.
  ///
  /// In en, this message translates to:
  /// **'Tap Refresh to generate an AI summary of the feedback.'**
  String get groqTapToGenerate;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @noEventsFoundOrganizer.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get noEventsFoundOrganizer;

  /// No description provided for @positions.
  ///
  /// In en, this message translates to:
  /// **'positions'**
  String get positions;

  /// No description provided for @applications.
  ///
  /// In en, this message translates to:
  /// **'applications'**
  String get applications;

  /// No description provided for @approvedLower.
  ///
  /// In en, this message translates to:
  /// **'approved'**
  String get approvedLower;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @rejectApplication.
  ///
  /// In en, this message translates to:
  /// **'Reject Application'**
  String get rejectApplication;

  /// No description provided for @volunteerRejectionReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. All slots have been filled. Thank you for your interest.'**
  String get volunteerRejectionReasonHint;

  /// No description provided for @confirmRejectVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reject'**
  String get confirmRejectVolunteer;

  /// No description provided for @applicationApprovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Application approved successfully.'**
  String get applicationApprovedSuccessfully;

  /// No description provided for @applicationRejectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Application rejected successfully.'**
  String get applicationRejectedSuccessfully;

  /// No description provided for @failedToApproveApplication.
  ///
  /// In en, this message translates to:
  /// **'Failed to approve application.'**
  String get failedToApproveApplication;

  /// No description provided for @failedToRejectApplication.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject application.'**
  String get failedToRejectApplication;

  /// No description provided for @noVolunteerPositionsForReview.
  ///
  /// In en, this message translates to:
  /// **'No volunteer positions available for review.'**
  String get noVolunteerPositionsForReview;

  /// No description provided for @unableToLoadOrganizerAccount.
  ///
  /// In en, this message translates to:
  /// **'Unable to load organizer account.'**
  String get unableToLoadOrganizerAccount;

  /// No description provided for @volunteerSlotsFull.
  ///
  /// In en, this message translates to:
  /// **'Volunteer slots are already full.'**
  String get volunteerSlotsFull;

  /// No description provided for @applicationAlreadyReviewed.
  ///
  /// In en, this message translates to:
  /// **'This application has already been reviewed.'**
  String get applicationAlreadyReviewed;

  /// No description provided for @applicationOrPositionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Application or position not found.'**
  String get applicationOrPositionNotFound;

  /// No description provided for @confirmApproveVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Confirm Approve'**
  String get confirmApproveVolunteer;

  /// No description provided for @approveApplicationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this application? If this approval fills all volunteer slots, all remaining pending applications for this position will be automatically rejected.'**
  String get approveApplicationQuestion;

  /// No description provided for @noExperienceProvided.
  ///
  /// In en, this message translates to:
  /// **'No experience provided'**
  String get noExperienceProvided;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @reviewEventApplications.
  ///
  /// In en, this message translates to:
  /// **'Review Event Applications'**
  String get reviewEventApplications;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @confirmCreatePosition.
  ///
  /// In en, this message translates to:
  /// **'Confirm Position Creation'**
  String get confirmCreatePosition;

  /// No description provided for @createPositionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Please make sure all volunteer position information is correct before submitting. Volunteer positions cannot be edited or deleted after creation.'**
  String get createPositionConfirmation;

  /// No description provided for @manageEquipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Equipment'**
  String get manageEquipmentTitle;

  /// No description provided for @inventoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Inventory Management'**
  String get inventoryManagement;

  /// No description provided for @searchEquipmentHint.
  ///
  /// In en, this message translates to:
  /// **'Search equipment...'**
  String get searchEquipmentHint;

  /// No description provided for @addEquipment.
  ///
  /// In en, this message translates to:
  /// **'Add Equipment'**
  String get addEquipment;

  /// No description provided for @editEquipment.
  ///
  /// In en, this message translates to:
  /// **'Edit Equipment'**
  String get editEquipment;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @totalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Total Quantity'**
  String get totalQuantity;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @storageLocation.
  ///
  /// In en, this message translates to:
  /// **'Storage Location'**
  String get storageLocation;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @categoryAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get categoryAudio;

  /// No description provided for @categoryPresentation.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get categoryPresentation;

  /// No description provided for @categoryFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get categoryFurniture;

  /// No description provided for @categoryDecoration.
  ///
  /// In en, this message translates to:
  /// **'Decoration'**
  String get categoryDecoration;

  /// No description provided for @categoryElectrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get categoryElectrical;

  /// No description provided for @quantityTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get quantityTotal;

  /// No description provided for @quantityBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get quantityBorrowed;

  /// No description provided for @quantityAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get quantityAvailable;

  /// No description provided for @noEquipmentFound.
  ///
  /// In en, this message translates to:
  /// **'No equipment found.'**
  String get noEquipmentFound;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @equipmentAdded.
  ///
  /// In en, this message translates to:
  /// **'Equipment added successfully.'**
  String get equipmentAdded;

  /// No description provided for @equipmentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Equipment updated successfully.'**
  String get equipmentUpdated;

  /// No description provided for @itemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Item name is required.'**
  String get itemNameRequired;

  /// No description provided for @totalQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Total quantity is required.'**
  String get totalQuantityRequired;

  /// No description provided for @quantityCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be greater than 0.'**
  String get quantityCannotBeNegative;

  /// No description provided for @storageLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage location is required.'**
  String get storageLocationRequired;

  /// No description provided for @quantityCannotBeLessThanBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Total quantity cannot be less than borrowed quantity.'**
  String get quantityCannotBeLessThanBorrowed;

  /// No description provided for @equipmentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Equipment not found.'**
  String get equipmentNotFound;

  /// No description provided for @equipmentIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Equipment ID is missing.'**
  String get equipmentIdMissing;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @itemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Wireless Microphone'**
  String get itemNameHint;

  /// No description provided for @totalQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10'**
  String get totalQuantityHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Brief description of the item...'**
  String get descriptionHint;

  /// No description provided for @storageLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Store Room A, Level 1'**
  String get storageLocationHint;

  /// No description provided for @markUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Mark Unavailable'**
  String get markUnavailable;

  /// No description provided for @markAvailable.
  ///
  /// In en, this message translates to:
  /// **'Mark Available'**
  String get markAvailable;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @equipmentMarkedUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Equipment marked as unavailable.'**
  String get equipmentMarkedUnavailable;

  /// No description provided for @equipmentMarkedAvailable.
  ///
  /// In en, this message translates to:
  /// **'Equipment marked as available.'**
  String get equipmentMarkedAvailable;

  /// No description provided for @markUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark equipment unavailable?'**
  String get markUnavailableTitle;

  /// No description provided for @markAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark equipment available?'**
  String get markAvailableTitle;

  /// No description provided for @markUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'This item will be hidden from new borrow requests. Existing borrowed items are not affected.'**
  String get markUnavailableMessage;

  /// No description provided for @markAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'This item will appear again for new borrow requests.'**
  String get markAvailableMessage;

  /// No description provided for @borrowedItemsWarning.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) are currently borrowed and must still be returned.'**
  String borrowedItemsWarning(Object count);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @appFooter.
  ///
  /// In en, this message translates to:
  /// **'Kolej Tun Razak · UTM'**
  String get appFooter;

  /// No description provided for @borrowEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrow Equipment'**
  String get borrowEventTitle;

  /// No description provided for @borrowEventSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select an event to borrow equipment for.'**
  String get borrowEventSubtitle;

  /// No description provided for @borrowEventEligibilityNote.
  ///
  /// In en, this message translates to:
  /// **'Only events within the next 3 days are eligible for equipment borrowing.'**
  String get borrowEventEligibilityNote;

  /// No description provided for @borrowEventBadgeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get borrowEventBadgeToday;

  /// No description provided for @borrowEventBadgeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get borrowEventBadgeTomorrow;

  /// No description provided for @borrowEventBadgeInDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String borrowEventBadgeInDays(Object days);

  /// No description provided for @borrowEventItemsBorrowed.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) borrowed'**
  String borrowEventItemsBorrowed(Object count);

  /// No description provided for @borrowEventNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No eligible events found.\nOnly events within the next 3 days will appear here.'**
  String get borrowEventNoEvents;

  /// No description provided for @borrowEventLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load events. Please try again.'**
  String get borrowEventLoadError;

  /// No description provided for @borrowEquipTitle.
  ///
  /// In en, this message translates to:
  /// **'Borrow Equipment'**
  String get borrowEquipTitle;

  /// No description provided for @borrowTabAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get borrowTabAvailable;

  /// No description provided for @borrowTabBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get borrowTabBorrowed;

  /// No description provided for @borrowTabBorrowedPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Borrowed items will appear here.'**
  String get borrowTabBorrowedPlaceholder;

  /// No description provided for @borrowedReturnPolicyNote.
  ///
  /// In en, this message translates to:
  /// **'All borrowed equipment must be returned within 24 hours after the event.'**
  String get borrowedReturnPolicyNote;

  /// No description provided for @borrowSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search equipment...'**
  String get borrowSearchHint;

  /// No description provided for @borrowCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get borrowCategoryAll;

  /// No description provided for @borrowCategoryAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get borrowCategoryAudio;

  /// No description provided for @borrowCategoryPresentation.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get borrowCategoryPresentation;

  /// No description provided for @borrowCategoryFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get borrowCategoryFurniture;

  /// No description provided for @borrowCategoryDecoration.
  ///
  /// In en, this message translates to:
  /// **'Decoration'**
  String get borrowCategoryDecoration;

  /// No description provided for @borrowCategorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get borrowCategorySports;

  /// No description provided for @borrowCategoryElectrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get borrowCategoryElectrical;

  /// No description provided for @borrowCategoryOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get borrowCategoryOthers;

  /// No description provided for @borrowAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} available'**
  String borrowAvailableCount(Object count);

  /// No description provided for @borrowAdded.
  ///
  /// In en, this message translates to:
  /// **'Added ({count})'**
  String borrowAdded(Object count);

  /// No description provided for @borrowNoEquipmentFound.
  ///
  /// In en, this message translates to:
  /// **'No equipment found'**
  String get borrowNoEquipmentFound;

  /// No description provided for @borrowLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load equipment. Please try again.'**
  String get borrowLoadError;

  /// No description provided for @borrowItemsButton.
  ///
  /// In en, this message translates to:
  /// **'Borrow Items ({count} selected)'**
  String borrowItemsButton(Object count);

  /// No description provided for @borrowRequestSpecial.
  ///
  /// In en, this message translates to:
  /// **'+ Request Special Equipment'**
  String get borrowRequestSpecial;

  /// No description provided for @borrowConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Borrow'**
  String get borrowConfirmTitle;

  /// No description provided for @borrowConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Borrowed equipment must be returned within 24 hours after the event.'**
  String get borrowConfirmSubtitle;

  /// No description provided for @borrowConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get borrowConfirmCancel;

  /// No description provided for @borrowConfirmSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Borrow'**
  String get borrowConfirmSubmit;

  /// No description provided for @borrowSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Borrow request submitted successfully!'**
  String get borrowSubmitSuccess;

  /// No description provided for @borrowSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit borrow request. Please try again.'**
  String get borrowSubmitError;

  /// No description provided for @specialRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Special Equipment Request'**
  String get specialRequestTitle;

  /// No description provided for @specialRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Request equipment not in inventory'**
  String get specialRequestSubtitle;

  /// No description provided for @specialRequestEventLabel.
  ///
  /// In en, this message translates to:
  /// **'EVENT'**
  String get specialRequestEventLabel;

  /// No description provided for @specialRequestPendingNote.
  ///
  /// In en, this message translates to:
  /// **'New requests are automatically assigned Pending status and will be reviewed by the Admin.'**
  String get specialRequestPendingNote;

  /// No description provided for @specialRequestItemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item Name *'**
  String get specialRequestItemNameLabel;

  /// No description provided for @specialRequestItemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Projector Screen'**
  String get specialRequestItemNameHint;

  /// No description provided for @specialRequestItemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an item name.'**
  String get specialRequestItemNameRequired;

  /// No description provided for @specialRequestQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity Required *'**
  String get specialRequestQuantityLabel;

  /// No description provided for @specialRequestQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quantity.'**
  String get specialRequestQuantityRequired;

  /// No description provided for @specialRequestQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity (minimum 1).'**
  String get specialRequestQuantityInvalid;

  /// No description provided for @specialRequestReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason / Description *'**
  String get specialRequestReasonLabel;

  /// No description provided for @specialRequestReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Describe why you need this item and any relevant details...'**
  String get specialRequestReasonHint;

  /// No description provided for @specialRequestReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason.'**
  String get specialRequestReasonRequired;

  /// No description provided for @specialRequestReasonTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason (min. 10 characters).'**
  String get specialRequestReasonTooShort;

  /// No description provided for @specialRequestCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get specialRequestCancel;

  /// No description provided for @specialRequestSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get specialRequestSubmit;

  /// No description provided for @specialRequestSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Special request submitted successfully!'**
  String get specialRequestSubmitSuccess;

  /// No description provided for @specialRequestSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit request. Please try again.'**
  String get specialRequestSubmitError;

  /// No description provided for @certificatesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Certificates'**
  String get certificatesTitle;

  /// No description provided for @certificatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your earned certificates'**
  String get certificatesSubtitle;

  /// No description provided for @certificatesNote.
  ///
  /// In en, this message translates to:
  /// **'Certificates are auto-generated after the event ends and feedback is submitted.'**
  String get certificatesNote;

  /// No description provided for @certificatesParticipation.
  ///
  /// In en, this message translates to:
  /// **'Participation'**
  String get certificatesParticipation;

  /// No description provided for @certificatesVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer'**
  String get certificatesVolunteer;

  /// No description provided for @certificatesIssued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get certificatesIssued;

  /// No description provided for @certificatesView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get certificatesView;

  /// No description provided for @certificatesDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get certificatesDownload;

  /// No description provided for @certificatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Certificates Yet'**
  String get certificatesEmpty;

  /// No description provided for @certificatesEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete feedback for eligible events, or be approved as a volunteer, to receive certificates.'**
  String get certificatesEmptyDesc;

  /// No description provided for @certificatesDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading certificate...'**
  String get certificatesDownloading;

  /// No description provided for @certificatesPdfNotReady.
  ///
  /// In en, this message translates to:
  /// **'Certificate PDF is not ready yet. Please try again later.'**
  String get certificatesPdfNotReady;

  /// No description provided for @borrowTabSpecialRequests.
  ///
  /// In en, this message translates to:
  /// **'Special Requests'**
  String get borrowTabSpecialRequests;

  /// No description provided for @borrowFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get borrowFilterAll;

  /// No description provided for @borrowFilterBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get borrowFilterBorrowed;

  /// No description provided for @borrowFilterReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get borrowFilterReturned;

  /// No description provided for @specialFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get specialFilterPending;

  /// No description provided for @specialFilterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get specialFilterApproved;

  /// No description provided for @specialFilterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get specialFilterRejected;

  /// No description provided for @statusBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get statusBorrowed;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get statusReturned;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusPendingEquipment.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPendingEquipment;

  /// No description provided for @statusApprovedEquipment.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApprovedEquipment;

  /// No description provided for @statusRejectedEquipment.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejectedEquipment;

  /// No description provided for @borrowQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get borrowQuantity;

  /// No description provided for @borrowDate.
  ///
  /// In en, this message translates to:
  /// **'Borrow date'**
  String get borrowDate;

  /// No description provided for @borrowEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get borrowEvent;

  /// No description provided for @returnDeadline.
  ///
  /// In en, this message translates to:
  /// **'Return deadline'**
  String get returnDeadline;

  /// No description provided for @returnInstruction.
  ///
  /// In en, this message translates to:
  /// **'Return within 24 hours after the event'**
  String get returnInstruction;

  /// No description provided for @returnBy.
  ///
  /// In en, this message translates to:
  /// **'Return by: {deadline}'**
  String returnBy(Object deadline);

  /// No description provided for @returnReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Return reminder: please return this equipment.'**
  String get returnReminderMessage;

  /// No description provided for @returnRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Overdue: Please return this equipment as soon as possible.'**
  String get returnRequiredMessage;

  /// No description provided for @returnEquipmentAction.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnEquipmentAction;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @borrowedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No borrowed equipment found.'**
  String get borrowedEmpty;

  /// No description provided for @borrowedLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load borrowed equipment.'**
  String get borrowedLoadError;

  /// No description provided for @borrowCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Borrow request cancelled.'**
  String get borrowCancelSuccess;

  /// No description provided for @borrowCancelError.
  ///
  /// In en, this message translates to:
  /// **'Unable to cancel this borrow request.'**
  String get borrowCancelError;

  /// No description provided for @specialRequestReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get specialRequestReason;

  /// No description provided for @specialCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Requested on'**
  String get specialCreatedAt;

  /// No description provided for @specialRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No special requests found.'**
  String get specialRequestsEmpty;

  /// No description provided for @specialRequestsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load special requests.'**
  String get specialRequestsLoadError;

  /// No description provided for @specialCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Special request cancelled.'**
  String get specialCancelSuccess;

  /// No description provided for @specialCancelError.
  ///
  /// In en, this message translates to:
  /// **'Unable to cancel this special request.'**
  String get specialCancelError;

  /// No description provided for @returnEquipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Return Equipment'**
  String get returnEquipmentTitle;

  /// No description provided for @returnPhotoEvidence.
  ///
  /// In en, this message translates to:
  /// **'Photo Evidence'**
  String get returnPhotoEvidence;

  /// No description provided for @returnPhotoEvidenceHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a clear photo showing the equipment being returned.'**
  String get returnPhotoEvidenceHint;

  /// No description provided for @returnUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get returnUploadPhoto;

  /// No description provided for @returnPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Photo evidence is required before submitting.'**
  String get returnPhotoRequired;

  /// No description provided for @returnSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Return'**
  String get returnSubmit;

  /// No description provided for @returnSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Equipment returned successfully.'**
  String get returnSubmitSuccess;

  /// No description provided for @returnSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to return equipment. Please try again.'**
  String get returnSubmitError;

  /// No description provided for @specialRequestBadge.
  ///
  /// In en, this message translates to:
  /// **'Special Request'**
  String get specialRequestBadge;

  /// No description provided for @borrowQuantityShort.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get borrowQuantityShort;

  /// No description provided for @returnEquipmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit return evidence'**
  String get returnEquipmentSubtitle;

  /// No description provided for @returnEquipmentDetails.
  ///
  /// In en, this message translates to:
  /// **'EQUIPMENT DETAILS'**
  String get returnEquipmentDetails;

  /// No description provided for @returnUploadPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'PNG or JPG · Tap to choose a photo'**
  String get returnUploadPhotoHint;

  /// No description provided for @returnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get returnCancel;

  /// No description provided for @borrowTabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get borrowTabUpcoming;

  /// No description provided for @borrowTabPastEvents.
  ///
  /// In en, this message translates to:
  /// **'Past Events'**
  String get borrowTabPastEvents;

  /// No description provided for @borrowEventNoPastEvents.
  ///
  /// In en, this message translates to:
  /// **'No past events with borrowed equipment found.'**
  String get borrowEventNoPastEvents;

  /// No description provided for @borrowEventPastBadge.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get borrowEventPastBadge;

  /// No description provided for @borrowEventAvailableTabLocked.
  ///
  /// In en, this message translates to:
  /// **'This event has ended. You can no longer borrow equipment.'**
  String get borrowEventAvailableTabLocked;

  /// No description provided for @specialRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Special Equipment Requests'**
  String get specialRequestsTitle;

  /// No description provided for @specialRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and action requests'**
  String get specialRequestsSubtitle;

  /// No description provided for @approveRequest.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveRequest;

  /// No description provided for @rejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectRequest;

  /// No description provided for @confirmApproveSpecial.
  ///
  /// In en, this message translates to:
  /// **'Confirm Approval'**
  String get confirmApproveSpecial;

  /// No description provided for @confirmRejectSpecial.
  ///
  /// In en, this message translates to:
  /// **'Confirm Rejection'**
  String get confirmRejectSpecial;

  /// No description provided for @itemLocation.
  ///
  /// In en, this message translates to:
  /// **'Item Location'**
  String get itemLocation;

  /// No description provided for @itemLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Store Room B, Level 2'**
  String get itemLocationHint;

  /// No description provided for @itemLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get itemLocationRequired;

  /// No description provided for @additionalNote.
  ///
  /// In en, this message translates to:
  /// **'Additional Note'**
  String get additionalNote;

  /// No description provided for @additionalNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Any instructions for the requester...'**
  String get additionalNoteHint;

  /// No description provided for @specialRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get specialRejectionReason;

  /// No description provided for @specialRejectionReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why this request is being rejected...'**
  String get specialRejectionReasonHint;

  /// No description provided for @specialRejectionReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason is required'**
  String get specialRejectionReasonRequired;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No Requests'**
  String get noRequests;

  /// No description provided for @noRequestsDesc.
  ///
  /// In en, this message translates to:
  /// **'No {filter} requests found.'**
  String noRequestsDesc(String filter);

  /// No description provided for @requestApprovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request approved successfully!'**
  String get requestApprovedSuccess;

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected.'**
  String get requestRejected;

  /// No description provided for @collectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Collection Location'**
  String get collectionLocation;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
