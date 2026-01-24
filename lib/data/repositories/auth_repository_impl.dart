import '../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<User> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
    required UserRole role,
  }) async {
    try {
      return await dataSource.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        address: address,
        role: role,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      return await dataSource.login(email: email, password: password);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      return await dataSource.logout();
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await dataSource.getCurrentUser();
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<User> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      return await dataSource.updateProfile(
        userId: userId,
        name: name,
        phone: phone,
        address: address,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<bool> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      return await dataSource.changePassword(
        userId: userId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      return await dataSource.resetPassword(email: email);
    } on AppException {
      rethrow;
    }
  }
}
