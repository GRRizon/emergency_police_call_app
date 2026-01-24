import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logger/app_logger.dart';
import '../../core/service_locator.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIt<AuthRepository>();
});

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  return CurrentUserNotifier(ref.watch(authRepositoryProvider));
});

class CurrentUserNotifier extends StateNotifier<User?> {
  final AuthRepository authRepository;

  CurrentUserNotifier(this.authRepository) : super(null) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      AppLogger.info('Loading current user');
      final user = await authRepository.getCurrentUser();
      state = user;
      AppLogger.info('Current user loaded: ${user?.userId}');
    } catch (e) {
      AppLogger.error('Load current user error: $e');
      state = null;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Logging in user: $email');
      final user = await authRepository.login(email: email, password: password);
      state = user;
      AppLogger.info('User logged in: ${user.userId}');
    } catch (e) {
      AppLogger.error('Login error: $e');
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
    required UserRole role,
  }) async {
    try {
      AppLogger.info('Registering user: $email');
      final user = await authRepository.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        address: address,
        role: role,
      );
      state = user;
      AppLogger.info('User registered: ${user.userId}');
    } catch (e) {
      AppLogger.error('Registration error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.info('Logging out user');
      await authRepository.logout();
      state = null;
      AppLogger.info('User logged out');
    } catch (e) {
      AppLogger.error('Logout error: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (state == null) return;

    try {
      AppLogger.info('Updating profile for user: ${state!.userId}');
      final updatedUser = await authRepository.updateProfile(
        userId: state!.userId,
        name: name,
        phone: phone,
        address: address,
      );
      state = updatedUser;
      AppLogger.info('Profile updated');
    } catch (e) {
      AppLogger.error('Update profile error: $e');
      rethrow;
    }
  }
}
