import '../../domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
    required UserRole role,
  });

  Future<User> login({required String email, required String password});

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<User> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
  });

  Future<bool> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  });

  Future<void> resetPassword({required String email});
}
