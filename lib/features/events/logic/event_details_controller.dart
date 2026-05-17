import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/event_model.dart';
import '../../../data/repository/event_repository.dart';
import '../../../data/services/file_upload_service.dart';

class OrganizerProfileInfo {
  final String uid;
  final String fullName;
  final String organizationName;
  final String organizationType;

  const OrganizerProfileInfo({
    required this.uid,
    required this.fullName,
    required this.organizationName,
    required this.organizationType,
  });
}

class EventDetailsSaveData {
  final EventModel event;
  final PickedUploadFile? pickedPosterFile;
  final String posterFileName;
  final String posterUrl;
  final String posterStoragePath;

  const EventDetailsSaveData({
    required this.event,
    required this.pickedPosterFile,
    required this.posterFileName,
    required this.posterUrl,
    required this.posterStoragePath,
  });
}

class EventDetailsController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final EventRepository _eventRepository;
  final FileUploadService _fileUploadService;

  EventDetailsController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    EventRepository? eventRepository,
    FileUploadService? fileUploadService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _eventRepository = eventRepository ?? EventRepository(),
        _fileUploadService = fileUploadService ?? FileUploadService();

  String? get currentUserId => _auth.currentUser?.uid;

  Future<OrganizerProfileInfo?> getOrganizerProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();

    if (data == null) return null;

    return OrganizerProfileInfo(
      uid: uid,
      fullName: data['fullName'] ?? '',
      organizationName: data['organizationName'] ?? '',
      organizationType: data['organizationType'] ?? '',
    );
  }

  Stream<List<EventModel>> getEventsCreatedByOrganizer(String organizerUid) {
    return _eventRepository.getEventsCreatedByOrganizer(
      organizerUid: organizerUid,
    );
  }

  Future<PickedUploadFile?> pickEventPoster() {
    return _fileUploadService.pickEventPoster();
  }

  Future<void> saveEventDetails({
    required EventDetailsSaveData data,
    required bool isEditMode,
  }) async {
    final existingEvent = data.event.eventId.isEmpty ? null : data.event;

    String posterFileName = data.posterFileName;
    String posterUrl = data.posterUrl;
    String posterStoragePath = data.posterStoragePath;
    String? oldPosterPathToDelete;

    if (data.pickedPosterFile != null) {
      final uploadResult = await _fileUploadService.uploadPickedFile(
        file: data.pickedPosterFile!,
        uploadType: UploadFileType.eventPoster,
        ownerId: data.event.createdBy,
        recordId: isEditMode ? data.event.eventId : null,
      );

      posterFileName = uploadResult.fileName;
      posterUrl = uploadResult.downloadUrl;
      posterStoragePath = uploadResult.storagePath;

      if (isEditMode &&
          existingEvent != null &&
          existingEvent.posterStoragePath.isNotEmpty &&
          existingEvent.posterStoragePath != posterStoragePath) {
        oldPosterPathToDelete = existingEvent.posterStoragePath;
      }
    }

    final eventToSave = EventModel(
      eventId: data.event.eventId,
      title: data.event.title,
      organizationName: data.event.organizationName,
      organizationType: data.event.organizationType,
      category: data.event.category,
      description: data.event.description,
      posterFileName: posterFileName,
      posterUrl: posterUrl,
      posterStoragePath: posterStoragePath,
      venue: data.event.venue,
      eventDateTime: data.event.eventDateTime,
      registrationEnabled: data.event.registrationEnabled,
      registrationDeadline: data.event.registrationDeadline,
      participantCapacity: data.event.participantCapacity,
      registrationFee: data.event.registrationFee,
      contactPerson: data.event.contactPerson,
      registeredCount: data.event.registeredCount,
      status: data.event.status,
      createdBy: data.event.createdBy,
      proposalDocumentId: data.event.proposalDocumentId,
      proposalTitle: data.event.proposalTitle,
      createdAt: data.event.createdAt,
      updatedAt: data.event.updatedAt,
    );

    if (isEditMode) {
      await _eventRepository.updateEvent(eventToSave);
    } else {
      await _eventRepository.createEvent(eventToSave);
    }

    if (oldPosterPathToDelete != null && oldPosterPathToDelete.isNotEmpty) {
      try {
        await _fileUploadService.deleteFileByPath(oldPosterPathToDelete);
      } catch (_) {
        // Do not fail the event save if old poster deletion fails.
      }
    }
  }

  Future<void> deleteEvent(String eventId) {
    return _eventRepository.deleteEvent(eventId);
  }

  Future<void> deleteEventPosterByPath(String posterStoragePath) async {
    if (posterStoragePath.trim().isEmpty) return;
    await _fileUploadService.deleteFileByPath(posterStoragePath);
  }
}