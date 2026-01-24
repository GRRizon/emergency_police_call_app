import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/exceptions/app_exceptions.dart';
import '../../core/logger/app_logger.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
    required UserRole role,
  });

  Future<UserModel> login({required String email, required String password});

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<UserModel> updateProfile({
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

// Password validation helper
class _PasswordValidator {
  static String? validate(String password, UserRole role) {
    const minLength = 6; // All roles require minimum 6 characters
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }
}

class AuthDataSourceImpl implements AuthDataSource {
  final SupabaseClient supabaseClient;

  AuthDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
    required UserRole role,
  }) async {
    try {
      // Validate password
      final passwordError = _PasswordValidator.validate(password, role);
      if (passwordError != null) {
        throw AuthenticationException(message: passwordError);
      }

      AppLogger.info('Registering user: $email');

      final authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw AuthenticationException(message: 'Registration failed');
      }

      final roleString = role.toString().split('.').last;

      await supabaseClient.from('profiles').insert({
        'id': authResponse.user!.id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'role': roleString,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      AppLogger.info('User registered successfully: $email');

      return UserModel(
        userId: authResponse.user!.id,
        name: name,
        phone: phone,
        email: email,
        password: password,
        address: address,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      AppLogger.error('Auth error: ${e.message}');
      throw AuthenticationException(message: e.message, code: e.statusCode);
    } catch (e) {
      AppLogger.error('Registration error: $e');
      throw ServerException(message: 'Failed to register user');
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Logging in user: $email');

      try {
        final authResponse = await supabaseClient.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (authResponse.user == null) {
          throw AuthenticationException(message: 'Login failed');
        }

        try {
          // Try to fetch from profiles table
          final userData = await supabaseClient
              .from('profiles')
              .select()
              .eq('id', authResponse.user!.id)
              .single();

          AppLogger.info('User logged in successfully: $email');
          return UserModel.fromJson(userData);
        } catch (e) {
          // If profiles table doesn't exist, create a default user
          AppLogger.info('Profiles table not found, creating default user');

          return UserModel(
            userId: authResponse.user!.id,
            name: email.split('@')[0],
            phone: '0000000000',
            email: email,
            password: password,
            address: 'Not set',
            role: UserRole.citizen,
            isActive: true,
            createdAt: DateTime.now(),
          );
        }
      } on AuthException catch (authError) {
        // If Supabase auth fails, check for demo accounts
        AppLogger.info(
            'Supabase auth failed, checking demo accounts: ${authError.message}');

        // Demo credentials (all with 6+ character passwords)
        final demoAccounts = {
          '75golamrabbani@gmail.com': {
            'password': '12345678',
            'role': UserRole.citizen
          },
          '75citizen@gmail.com': {
            'password': '12345678',
            'role': UserRole.citizen
          },
          '75police@gmail.com': {'password': '123456', 'role': UserRole.police},
          '75admin@gmail.com': {'password': '123456', 'role': UserRole.admin},
        };

        if (demoAccounts.containsKey(email)) {
          final account = demoAccounts[email];
          if (account?['password'] == password) {
            AppLogger.info('Demo account login successful: $email');
            return UserModel(
              userId: 'demo_${email.split('@')[0]}',
              name: email.split('@')[0],
              phone: '0000000000',
              email: email,
              password: password,
              address: 'Demo User',
              role: account?['role'] as UserRole? ?? UserRole.citizen,
              isActive: true,
              createdAt: DateTime.now(),
            );
          } else {
            throw AuthenticationException(message: 'Invalid password');
          }
        }

        throw AuthenticationException(
            message: authError.message, code: authError.statusCode);
      }
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      AppLogger.error('Login error: $e');
      throw ServerException(message: 'Failed to login');
    }
  }

  @override
  Future<void> logout() async {
    try {
      AppLogger.info('Logging out user');
      await supabaseClient.auth.signOut();
      AppLogger.info('User logged out successfully');
    } catch (e) {
      AppLogger.error('Logout error: $e');
      throw ServerException(message: 'Failed to logout');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) return null;

      try {
        final userData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', session.user.id)
            .single();

        return UserModel.fromJson(userData);
      } catch (e) {
        // If profiles table doesn't exist, create a default user
        AppLogger.info(
            'Profiles table not found, creating default user for session');

        final email = session.user.email ?? 'user@example.com';
        return UserModel(
          userId: session.user.id,
          name: email.split('@')[0],
          phone: '0000000000',
          email: email,
          password: '',
          address: 'Not set',
          role: UserRole.citizen,
          isActive: true,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      AppLogger.error('Get current user error: $e');
      return null;
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      AppLogger.info('Updating profile for user: $userId');

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await supabaseClient.from('profiles').update(updateData).eq('id', userId);

      final userData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      AppLogger.info('Profile updated successfully');
      return UserModel.fromJson(userData);
    } catch (e) {
      AppLogger.error('Update profile error: $e');
      throw ServerException(message: 'Failed to update profile');
    }
  }

  @override
  Future<bool> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      AppLogger.info('Changing password for user: $userId');

      // Get current user role
      try {
        final userData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();

        final roleString = userData['role'] as String? ?? 'citizen';
        final role = UserRole.values.firstWhere(
          (r) => r.toString().split('.').last == roleString,
          orElse: () => UserRole.citizen,
        );

        // Validate new password
        final passwordError = _PasswordValidator.validate(newPassword, role);
        if (passwordError != null) {
          throw AuthenticationException(message: passwordError);
        }
      } catch (e) {
        // If role check fails, assume citizen (6 char minimum)
        if (newPassword.length < 6) {
          throw AuthenticationException(
              message: 'Password must be at least 6 characters');
        }
      }

      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      AppLogger.info('Password changed successfully');
      return true;
    } catch (e) {
      AppLogger.error('Change password error: $e');
      return false;
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      AppLogger.info('Resetting password for: $email');

      await supabaseClient.auth.resetPasswordForEmail(email);

      AppLogger.info('Password reset email sent');
    } catch (e) {
      AppLogger.error('Reset password error: $e');
      throw ServerException(message: 'Failed to reset password');
    }
  }
}
