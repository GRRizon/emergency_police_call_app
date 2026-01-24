const String supabaseUrl = 'https://xvpwnzxlczjyhzbomcxk.supabase.co';
const String supabaseAnonKey = 'sb_publishable_IkgkR72tiPInVP8I2XOd_A_ZA6rQQF6';

// API Configuration
const int connectTimeout = 30000; // milliseconds
const int receiveTimeout = 30000; // milliseconds

// Location Configuration
const double defaultLocationAccuracy = 10.0; // meters
const int locationUpdateIntervalSeconds = 5;

// Emergency Request Configuration
const int maxEmergencyContactsPerUser = 10;
const double nearbyOfficerRadiusMeters = 5000; // 5km

// Pagination
const int defaultPageSize = 20;
const int defaultInitialLoadSize = 50;
