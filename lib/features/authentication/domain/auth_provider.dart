import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amora/features/authentication/data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<String?>>((ref) {
  return AuthStateNotifier(ref.read(authRepositoryProvider));
});

class AuthStateNotifier extends StateNotifier<AsyncValue<String?>> {
  final AuthRepository _authRepository;

  AuthStateNotifier(this._authRepository) : super(const AsyncValue.data(null));

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String role,
    required String securityQuestion,
    required String securityAnswer,
    required String secretWord,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = await _authRepository.registerUser(
        username: username,
        email: email,
        password: password,
        role: role,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
        secretWord: secretWord,
      );
      state = AsyncValue.data(userId);
      return userId;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<String> generateOtp(String email) async {
    return await _authRepository.generateOtp(email);
  }

  Future<bool> verifyOtp(String email, String otp) async {
    return await _authRepository.verifyOtp(email, otp);
  }
}