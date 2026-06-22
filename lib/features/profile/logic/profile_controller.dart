// lib/features/profile/logic/profile_controller.dart

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repository/user_repository.dart';
import '../../../data/services/auth_service.dart';

class ProfileController extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthService _authService;

  ProfileController({
    UserRepository? userRepository,
    AuthService? authService,
  })  : _userRepository = userRepository ?? UserRepository(),
        _authService = authService ?? AuthService();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingProfileImage = false;
  String? _errorMessage;
  UserModel? _currentUserProfile;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isUploadingProfileImage => _isUploadingProfileImage;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUserProfile => _currentUserProfile;

  Future<void> loadCurrentUserProfile() async {
    _setLoading(true);
    _clearErrorSilently();

    try {
      final firebaseUser = _authService.currentUser;

      if (firebaseUser == null) {
        throw Exception('No user is currently logged in.');
      }

      final profile = await _userRepository.getUserById(firebaseUser.uid);

      if (profile == null) {
        throw Exception('User profile was not found.');
      }

      _currentUserProfile = profile;
      _setLoading(false);
    } catch (error) {
      _errorMessage = _toFriendlyMessage(error);
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? matricNumber,
  }) async {
    _setSaving(true);
    _clearErrorSilently();

    try {
      final firebaseUser = _authService.currentUser;

      if (firebaseUser == null) {
        throw Exception('No user is currently logged in.');
      }

      final currentProfile = _currentUserProfile;

      if (currentProfile == null) {
        throw Exception('User profile was not loaded.');
      }

      final isAdmin = currentProfile.role == UserRole.admin;

      await _userRepository.updateUserProfile(
        uid: firebaseUser.uid,
        fullName: fullName,
        phoneNumber: isAdmin ? null : phoneNumber,
        matricNumber: isAdmin ? null : matricNumber,
      );

      _currentUserProfile = currentProfile.copyWith(
        fullName: fullName.trim(),
        phoneNumber: isAdmin ? null : phoneNumber?.trim(),
        matricNumber: isAdmin ? null : matricNumber?.trim(),
      );

      _setSaving(false);
      return true;
    } catch (error) {
      _errorMessage = _toFriendlyMessage(error);
      _setSaving(false);
      return false;
    }
  }

  Future<bool> uploadProfileImage(XFile imageFile) async {
    _setUploadingProfileImage(true);
    _clearErrorSilently();

    try {
      final firebaseUser = _authService.currentUser;
      final currentProfile = _currentUserProfile;

      if (firebaseUser == null) {
        throw Exception('No user is currently logged in.');
      }

      if (currentProfile == null) {
        throw Exception('User profile was not loaded.');
      }

      final bytes = await imageFile.readAsBytes();

      final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child(firebaseUser.uid)
        .child('profile.jpg');

      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final imageUrl = await ref.getDownloadURL();

      await _userRepository.updateProfileImageUrl(
        uid: firebaseUser.uid,
        profileImageUrl: imageUrl,
      );

      _currentUserProfile = currentProfile.copyWith(
        profileImageUrl: imageUrl,
      );

      _setUploadingProfileImage(false);
      return true;
    } catch (error) {
      _errorMessage = _toFriendlyMessage(error);
      _setUploadingProfileImage(false);
      return false;
    }
  }

  Future<bool> removeProfileImage() async {
    _setUploadingProfileImage(true);
    _clearErrorSilently();

    try {
      final firebaseUser = _authService.currentUser;
      final currentProfile = _currentUserProfile;

      if (firebaseUser == null) {
        throw Exception('No user is currently logged in.');
      }

      if (currentProfile == null) {
        throw Exception('User profile was not loaded.');
      }

      await _userRepository.removeProfileImageUrl(uid: firebaseUser.uid);

      _currentUserProfile = currentProfile.copyWith(
        profileImageUrl: null,
      );

      _setUploadingProfileImage(false);
      return true;
    } catch (error) {
      _errorMessage = _toFriendlyMessage(error);
      _setUploadingProfileImage(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _setUploadingProfileImage(bool value) {
    _isUploadingProfileImage = value;
    notifyListeners();
  }

  void _clearErrorSilently() {
    _errorMessage = null;
  }

  String _toFriendlyMessage(Object error) {
    final raw = error.toString();

    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '');
    }

    return 'Something went wrong. Please try again.';
  }
}