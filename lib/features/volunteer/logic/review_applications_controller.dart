import 'package:flutter/material.dart';
import '../../../data/models/volunteer_application_model.dart';
import '../../../data/models/volunteer_position_model.dart';
import '../../../data/repository/volunteer_repository.dart';
import '../../certificates/logic/certificate_trigger_service.dart';

class ReviewApplicationsController extends ChangeNotifier {
  final VolunteerRepository _repository = VolunteerRepository();

  bool isUpdating = false;
  String? errorKey;

  Stream<List<VolunteerPositionModel>> streamOrganizerVolunteerPositions(
    String organizerId,
  ) {
    return _repository.getOrganizerVolunteerPositions(organizerId);
  }

  Stream<VolunteerPositionModel?> streamPositionById(String positionId) {
    return _repository.getPositionById(positionId);
  }

  Stream<List<VolunteerApplicationModel>> streamApplicationsForPosition(
    String positionId,
  ) {
    return _repository.getApplicationsForPosition(positionId);
  }

  Future<bool> approveApplication({
    required String applicationId,
    required String positionId,
    required String reviewerUid,
    required String applicantUserId,
    required String eventId,
  }) async {
    isUpdating = true;
    errorKey = null;
    notifyListeners();

    try {
      await _repository.approveVolunteerApplication(
        applicationId: applicationId,
        positionId: positionId,
        reviewerUid: reviewerUid,
      );

      // AD-191 — auto-issue volunteer certificate if event has ended
      await CertificateTriggerService().onVolunteerApproved(
        userId: applicantUserId,
        eventId: eventId,
      );

      return true;
    } catch (e) {
      errorKey = _cleanErrorKey(e);
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> rejectApplication({
    required String applicationId,
    required String reviewerUid,
    required String rejectionReason,
  }) async {
    if (rejectionReason.trim().isEmpty) {
      errorKey = 'rejectionReasonRequired';
      notifyListeners();
      return false;
    }

    isUpdating = true;
    errorKey = null;
    notifyListeners();

    try {
      await _repository.rejectVolunteerApplication(
        applicationId: applicationId,
        reviewerUid: reviewerUid,
        rejectionReason: rejectionReason,
      );
      return true;
    } catch (e) {
      errorKey = _cleanErrorKey(e);
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  String _cleanErrorKey(Object error) {
    return error.toString().replaceAll('Exception: ', '').trim();
  }
}