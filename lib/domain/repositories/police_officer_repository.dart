import '../../domain/entities/police_officer.dart';

abstract class PoliceOfficerRepository {
  Future<PoliceOfficer?> getOfficerById(String policeId);

  Future<List<PoliceOfficer>> getAvailableOfficers({
    double? latitude,
    double? longitude,
    double? radiusInMeters,
  });

  Future<List<PoliceOfficer>> getAllOfficers();

  Future<PoliceOfficer> updateLocation({
    required String policeId,
    required double latitude,
    required double longitude,
  });

  Future<PoliceOfficer> updateAvailabilityStatus({
    required String policeId,
    required bool isAvailable,
  });

  Future<PoliceOfficer> updateOfficerInfo({
    required String policeId,
    String? name,
    String? phone,
    String? precinct,
    String? vehicleInfo,
  });

  Future<void> incrementAcceptedRequests(String policeId);

  Future<void> incrementCompletedRequests(String policeId);

  Stream<PoliceOfficer> watchOfficer(String policeId);

  Stream<List<PoliceOfficer>> watchAvailableOfficers();
}
