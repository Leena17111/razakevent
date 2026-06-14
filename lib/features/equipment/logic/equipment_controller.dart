import 'package:flutter/material.dart';

import '../../../data/models/equipment_model.dart';
import '../../../data/repository/equipment_repository.dart';

class EquipmentController extends ChangeNotifier {
  final EquipmentRepository _repository = EquipmentRepository();

  List<EquipmentModel> _equipment = [];
  List<EquipmentModel> get equipment => _equipment;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Stream<List<EquipmentModel>> watchEquipment() {
    return _repository.watchEquipment();
  }

  Stream<List<EquipmentModel>> watchActiveEquipment() {
    return _repository.watchActiveEquipment();
  }

  void setEquipment(List<EquipmentModel> items) {
    _equipment = items;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<EquipmentModel> get filteredEquipment {
    final query = _searchQuery.trim().toLowerCase();

    return _equipment.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;

      final matchesSearch = query.isEmpty ||
          item.itemName.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.storageLocation.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<bool> addEquipment({
    required String category,
    required String itemName,
    required String description,
    required String storageLocation,
    required int totalQuantity,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (totalQuantity <= 0) {
        throw Exception('enterValidNumber');
      }

      final equipment = EquipmentModel(
        equipmentId: '',
        category: category,
        itemName: itemName.trim(),
        description: description.trim(),
        storageLocation: storageLocation.trim(),
        totalQuantity: totalQuantity,
        borrowedQuantity: 0,
        status: EquipmentStatus.active,
      );

      await _repository.addEquipment(equipment);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEquipment({
    required EquipmentModel existingEquipment,
    required String category,
    required String itemName,
    required String description,
    required String storageLocation,
    required int totalQuantity,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (totalQuantity <= 0) {
        throw Exception('enterValidNumber');
      }

      if (totalQuantity < existingEquipment.borrowedQuantity) {
        throw Exception('quantityCannotBeLessThanBorrowed');
      }

      final updated = existingEquipment.copyWith(
        category: category,
        itemName: itemName.trim(),
        description: description.trim(),
        storageLocation: storageLocation.trim(),
        totalQuantity: totalQuantity,
      );

      await _repository.updateEquipment(updated);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markEquipmentInactive(EquipmentModel equipment) async {
    return _markEquipmentStatus(
      equipment: equipment,
      status: EquipmentStatus.inactive,
    );
  }

  Future<bool> markEquipmentActive(EquipmentModel equipment) async {
    return _markEquipmentStatus(
      equipment: equipment,
      status: EquipmentStatus.active,
    );
  }

  Future<bool> _markEquipmentStatus({
    required EquipmentModel equipment,
    required String status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.markEquipmentStatus(
        equipmentId: equipment.equipmentId,
        status: status,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}