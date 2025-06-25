import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:amora/features/authentication/data/models/user_model.dart';

class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({this.isLoading = false, this.error});
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final Box<UserModel> _userBox;
  final FlutterSecureStorage _secureStorage;

  AuthStateNotifier(this._userBox, this._secureStorage) : super(const AuthState());

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String role,
    required String securityQuestion,
    required String securityAnswer,
    required String secretWord,
  }) async {
    state = const AuthState(isLoading: true);
    try {
      if (_userBox.length >= 2) {
        state = const AuthState(error: 'Only two users allowed');
        return null;
      }

      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final user = UserModel(
        id: userId,
        username: username,
        email: email,
        role: role,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
        secretWord: secretWord,
      );

      await _userBox.put(userId, user);
      await _secureStorage.write(key: 'password_$userId', value: password);

      state = const AuthState();
      return userId;
    } catch (e) {
      state = AuthState(error: e.toString());
      return null;
    }
  }

  Future<String> generateOtp(String email) async {
    try {
      final random = Random();
      final otp = (100000 + random.nextInt(900000)).toString();
      await _secureStorage.write(key: 'otp_$email', value: otp);
      debugPrint('Generated OTP for $email: $otp');
      return otp;
    } catch (e) {
      debugPrint('Error generating OTP: $e');
      return '000000';
    }
  }

  Future<bool> verifyOtp(String email, String inputOtp) async {
    try {
      final storedOtp = await _secureStorage.read(key: 'otp_$email');
      final isValid = storedOtp == inputOtp;
      if (isValid) {
        await _secureStorage.delete(key: 'otp_$email');
      }
      return isValid;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required String secretWord,
    required String role,
  }) async {
    state = const AuthState(isLoading: true);
    try {
      final user = _userBox.values.firstWhere(
            (user) => user.email == email && user.secretWord == secretWord && user.role == role,
        orElse: () => throw Exception('User not found'),
      );
      final storedPassword = await _secureStorage.read(key: 'password_${user.id}');
      if (storedPassword == password) {
        state = const AuthState();
        return true;
      } else {
        state = const AuthState(error: 'Invalid password');
        return false;
      }
    } catch (e) {
      state = AuthState(error: e.toString());
      return false;
    }
  }

  Future<String?> getSecurityQuestion(String email) async {
    try {
      final user = _userBox.values.firstWhere(
            (user) => user.email == email,
        orElse: () => throw Exception('User not found'),
      );
      return user.securityQuestion;
    } catch (e) {
      debugPrint('Error fetching security question: $e');
      return null;
    }
  }

  Future<String?> recoverPassword(String email, String securityAnswer) async {
    try {
      final user = _userBox.values.firstWhere(
            (user) => user.email == email && user.securityAnswer == securityAnswer,
        orElse: () => throw Exception('Invalid answer'),
      );
      return await _secureStorage.read(key: 'password_${user.id}');
    } catch (e) {
      debugPrint('Error recovering password: $e');
      return null;
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final userBox = Hive.box<UserModel>('users');
  const secureStorage = FlutterSecureStorage();
  return AuthStateNotifier(userBox, secureStorage);
});