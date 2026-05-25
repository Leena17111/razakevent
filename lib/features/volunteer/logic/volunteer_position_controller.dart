import 'package:flutter/material.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/volunteer_position_model.dart';
import '../../../data/repository/volunteer_repository.dart';

class VolunteerPositionController extends ChangeNotifier {
  final VolunteerRepository _repository = VolunteerRepository();

  List<EventModel> organizerEvents = [];
  bool isLoadingEvents = false;
  bool isSaving = false;
  bool isSuccess = false;
  bool hasLoadError = false;
  bool hasSaveError = false;

  Future<void> loadOrganizerEvents(String organizerId) async {
    isLoadingEvents = true;
    hasLoadError = false;
    notifyListeners();
    try {
      organizerEvents =
          await _repository.getOrganizerUpcomingEvents(organizerId);
    } catch (_) {
      hasLoadError = true;
    } finally {
      isLoadingEvents = false;
      notifyListeners();
    }
  }

  Stream<List<VolunteerPositionModel>> streamPositionsForEvent(
    String eventId,
  ) {
    return _repository.getPositionsForEvent(eventId);
  }

  Future<void> addPosition(VolunteerPositionModel position) async {
    isSaving = true;
    isSuccess = false;
    hasSaveError = false;
    notifyListeners();
    try {
      await _repository.addVolunteerPosition(position);
      isSuccess = true;
    } catch (_) {
      hasSaveError = true;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void resetSuccess() {
    isSuccess = false;
    hasSaveError = false;
    notifyListeners();
  }
}