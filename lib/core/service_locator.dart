import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../data/datasources/auth_datasource.dart';
import '../data/datasources/dispatch_datasource.dart';
import '../data/datasources/emergency_contact_datasource.dart';
import '../data/datasources/emergency_request_datasource.dart';
import '../data/datasources/location_datasource.dart';
import '../data/datasources/notification_datasource.dart';
import '../data/datasources/police_officer_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/dispatch_repository_impl.dart';
import '../data/repositories/emergency_contact_repository_impl.dart';
import '../data/repositories/emergency_request_repository_impl.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../data/repositories/police_officer_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/dispatch_repository.dart';
import '../domain/repositories/emergency_contact_repository.dart';
import '../domain/repositories/emergency_request_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/police_officer_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Supabase Client
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final supabaseClient = Supabase.instance.client;
  getIt.registerSingleton<SupabaseClient>(supabaseClient);

  // Data Sources
  getIt.registerSingleton<AuthDataSource>(
    AuthDataSourceImpl(supabaseClient: supabaseClient),
  );

  getIt.registerSingleton<LocationDataSource>(
    LocationDataSourceImpl(),
  );

  getIt.registerSingleton<EmergencyContactDataSource>(
    EmergencyContactDataSourceImpl(supabaseClient: supabaseClient),
  );

  getIt.registerSingleton<EmergencyRequestDataSource>(
    EmergencyRequestDataSourceImpl(supabaseClient: supabaseClient),
  );

  getIt.registerSingleton<PoliceOfficerDataSource>(
    PoliceOfficerDataSourceImpl(supabaseClient: supabaseClient),
  );

  getIt.registerSingleton<DispatchDataSource>(
    DispatchDataSourceImpl(supabaseClient: supabaseClient),
  );

  getIt.registerSingleton<NotificationDataSource>(
    NotificationDataSourceImpl(supabaseClient: supabaseClient),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(dataSource: getIt<AuthDataSource>()),
  );

  getIt.registerSingleton<EmergencyContactRepository>(
    EmergencyContactRepositoryImpl(
        dataSource: getIt<EmergencyContactDataSource>()),
  );

  getIt.registerSingleton<EmergencyRequestRepository>(
    EmergencyRequestRepositoryImpl(
        dataSource: getIt<EmergencyRequestDataSource>()),
  );

  getIt.registerSingleton<PoliceOfficerRepository>(
    PoliceOfficerRepositoryImpl(dataSource: getIt<PoliceOfficerDataSource>()),
  );

  getIt.registerSingleton<DispatchRepository>(
    DispatchRepositoryImpl(dataSource: getIt<DispatchDataSource>()),
  );

  getIt.registerSingleton<NotificationRepository>(
    NotificationRepositoryImpl(dataSource: getIt<NotificationDataSource>()),
  );
}
