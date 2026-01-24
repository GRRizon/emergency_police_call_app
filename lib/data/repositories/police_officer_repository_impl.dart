import '../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/police_officer.dart';
import '../../domain/repositories/police_officer_repository.dart';
import '../datasources/police_officer_datasource.dart';

class PoliceOfficerRepositoryImpl implements PoliceOfficerRepository {
  final PoliceOfficerDataSource dataSource;

  PoliceOfficerRepositoryImpl({required this.dataSource});

  @override
  Future<PoliceOfficer?> getOfficerById(String policeId) async {
    try {
      return await dataSource.getOfficerById(policeId) as PoliceOfficer?;
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<List<PoliceOfficer>> getAvailableOfficers({
    double? latitude,
    double? longitude,
    double? radiusInMeters,
  }) async {
    try {
      final officers = await dataSource.getAvailableOfficers();

      // ignore: todo
      // TODO: Filter by distance if coordinates provided
      // if (latitude != null && longitude != null && radiusInMeters != null) {
      //   return officers.where((officer) {
      //     // Calculate distance and filter
      //   }).toList();
      // }

      return officers.cast<PoliceOfficer>();
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<List<PoliceOfficer>> getAllOfficers() async {
    try {
      return (await dataSource.getAllOfficers()).cast<PoliceOfficer>();
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<PoliceOfficer> updateLocation({
    required String policeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      return (await dataSource.updateLocation(
        policeId: policeId,
        latitude: latitude,
        longitude: longitude,
      )) as PoliceOfficer;
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<PoliceOfficer> updateAvailabilityStatus({
    required String policeId,
    required bool isAvailable,
  }) async {
    try {
      return (await dataSource.updateAvailabilityStatus(
        policeId: policeId,
        isAvailable: isAvailable,
      )) as PoliceOfficer;
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<PoliceOfficer> updateOfficerInfo({
    required String policeId,
    String? name,
    String? phone,
    String? precinct,
    String? vehicleInfo,
  }) async {
    try {
      return (await dataSource.updateOfficerInfo(
        policeId: policeId,
        name: name,
        phone: phone,
        precinct: precinct,
        vehicleInfo: vehicleInfo,
      )) as PoliceOfficer;
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> incrementAcceptedRequests(String policeId) async {
    try {
      return await dataSource.incrementAcceptedRequests(policeId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> incrementCompletedRequests(String policeId) async {
    try {
      return await dataSource.incrementCompletedRequests(policeId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Stream<PoliceOfficer> watchOfficer(String policeId) {
    // ignore: todo
    // TODO: Implement realtime subscription
    throw UnimplementedError();
  }

  @override
  Stream<List<PoliceOfficer>> watchAvailableOfficers() {
    // ignore: todo
    // TODO: Implement realtime subscription
    throw UnimplementedError();
  }
}
