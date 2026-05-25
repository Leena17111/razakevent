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
    String posterFileName = data.posterFileName;
    String posterUrl = data.posterUrl;
    String posterStoragePath = data.posterStoragePath;
    String? oldPosterPathToDelete;

    if (isEditMode) {
      // ── EDIT: upload new poster first (we already have the event ID) ──
      if (data.pickedPosterFile != null) {
        final uploadResult = await _fileUploadService.uploadPickedFile(
          file: data.pickedPosterFile!,
          uploadType: UploadFileType.eventPoster,
          ownerId: data.event.createdBy,
          recordId: data.event.eventId,
        );

        posterFileName = uploadResult.fileName;
        posterUrl = uploadResult.downloadUrl;
        posterStoragePath = uploadResult.storagePath;

        if (data.event.posterStoragePath.isNotEmpty &&
            data.event.posterStoragePath != posterStoragePath) {
          oldPosterPathToDelete = data.event.posterStoragePath;
        }
      }

      final eventToSave = _buildEvent(
        data: data,
        posterFileName: posterFileName,
        posterUrl: posterUrl,
        posterStoragePath: posterStoragePath,
        eventId: data.event.eventId,
      );

      await _eventRepository.updateEvent(eventToSave);
    } else {
      // ── CREATE: save event first to get a real Firestore ID ──
      final tempEvent = _buildEvent(
        data: data,
        posterFileName: posterFileName,
        posterUrl: posterUrl,
        posterStoragePath: posterStoragePath,
        eventId: '',
      );

      final newEventId = await _eventRepository.createEvent(tempEvent);

      // ── Upload poster using the real event ID as its storage folder ──
      if (data.pickedPosterFile != null) {
        final uploadResult = await _fileUploadService.uploadPickedFile(
          file: data.pickedPosterFile!,
          uploadType: UploadFileType.eventPoster,
          ownerId: data.event.createdBy,
          recordId: newEventId, // ← unique per event
        );

        posterFileName = uploadResult.fileName;
        posterUrl = uploadResult.downloadUrl;
        posterStoragePath = uploadResult.storagePath;

        // ── Patch the document with the poster URL now that we have it ──
        await _firestore.collection('events').doc(newEventId).update({
          'posterFileName': posterFileName,
          'posterUrl': posterUrl,
          'posterStoragePath': posterStoragePath,
        });
      }
    }

    // ── Clean up old poster from Storage if replaced ──
    if (oldPosterPathToDelete != null && oldPosterPathToDelete.isNotEmpty) {
      try {
        await _fileUploadService.deleteFileByPath(oldPosterPathToDelete);
      } catch (_) {
        // Do not fail the save if old poster deletion fails.
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

  // ── Helper ────────────────────────────────────────────────────────────────────

  EventModel _buildEvent({
    required EventDetailsSaveData data,
    required String posterFileName,
    required String posterUrl,
    required String posterStoragePath,
    required String eventId,
  }) {
    return EventModel(
      eventId: eventId,
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
  }
}