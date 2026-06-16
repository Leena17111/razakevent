import 'package:flutter/material.dart';
import '../../../data/models/special_equipment_request_model.dart';
import '../../../data/repository/equipment_borrow_repository.dart';

class ReviewSpecialRequestsController extends ChangeNotifier {
  final EquipmentBorrowRepository _repo = EquipmentBorrowRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  /// Live stream of all special requests — UI subscribes via StreamBuilder.
  Stream<List<SpecialEquipmentRequest>> watchAllRequests() =>
      _repo.watchAllSpecialRequests();

  Future<bool> approveRequest({
    required String requestId,
    required String location,
    String? note,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      await _repo.approveSpecialRequest(
        requestId: requestId,
        location: location,
        note: note,
      );
      _successMessage = 'requestApprovedSuccess';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectRequest({
    required String requestId,
    required String reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      await _repo.rejectSpecialRequest(
        requestId: requestId,
        reason: reason,
      );
      _successMessage = 'requestRejected';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}