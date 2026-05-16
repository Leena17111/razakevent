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
