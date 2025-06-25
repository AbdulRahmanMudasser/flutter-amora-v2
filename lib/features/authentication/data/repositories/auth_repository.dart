import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:amora/features/authentication/data/models/user_model.dart';

class AuthRepository {
  static const String _boxName = 'users';
  static const String _secretWordKey = 'secret_word';
  static const String _passwordKey = 'password';
  final Box<UserModel> _userBox;
  final FlutterSecureStorage _secureStorage;

  AuthRepository()
      : _userBox = Hive.box<UserModel>(_boxName),
        _secureStorage = const FlutterSecureStorage();

  Future<bool> canRegister() async {
    return _userBox.length < 2;
  }

  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
    required String securityQuestion,
    required String securityAnswer,
    required String secretWord,
  }) async {
    if (await canRegister()) {
      final id = const Uuid().v4();
      final user = UserModel(
        id: id,
        username: username,
        email: email,
        role: role,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
        secretWord: secretWord,
      );
      await _userBox.put(id, user);
      await _secureStorage.write(key: '${id}_$_passwordKey', value: password);
      await _secureStorage.write(key: '${id}_$_secretWordKey', value: secretWord);
      return id;
    }
    return null;
  }

  Future<String> generateOtp(String email) async {
    // Simulate OTP generation (offline app)
    final random = Random().nextInt(900000) + 100000;
    final otp = random.toString();
    await _secureStorage.write(key: '${email}_otp', value: otp);
    return otp;
  }

  Future<bool> verifyOtp(String email, String otp) async {
    final storedOtp = await _secureStorage.read(key: '${email}_otp');
    return storedOtp == otp;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      for (var user in _userBox.values) {
        if (user.email == email) {
          return user;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}