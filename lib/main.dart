import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_strings.dart';
import 'config/app_theme.dart';
import 'core/logger/app_logger.dart';
import 'core/service_locator.dart';
import 'domain/entities/user.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/sos_screen.dart';
import 'presentation/screens/police_dashboard_screen.dart';
import 'presentation/screens/emergency_contacts_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    AppLogger.info('Initializing app');
    await setupServiceLocator();
    AppLogger.info('Service locator initialized');
  } catch (e) {
    AppLogger.error('Service locator initialization error: $e');
  }

  runApp(const ProviderScope(child: EmergencyApp()));
}

class EmergencyApp extends ConsumerWidget {
  const EmergencyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme(),
      home: currentUser == null
          ? const LoginScreen()
          : _buildHomeByRole(currentUser),
    );
  }

  Widget _buildHomeByRole(User user) {
    switch (user.role) {
      case UserRole.citizen:
        return const CitizenHomePage();
      case UserRole.police:
        return const PoliceDashboardScreen();
      case UserRole.admin:
        return const AdminHomePage();
    }
  }
}

class CitizenHomePage extends ConsumerWidget {
  const CitizenHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () async {
                  final authNotifier = ref.read(currentUserProvider.notifier);
                  await authNotifier.logout();
                },
                child: const Text(AppStrings.logout),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome ${currentUser?.name}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Role: CITIZEN',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SOSScreen()),
                );
              },
              icon: const Icon(Icons.emergency),
              label: const Text('Emergency SOS'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyContactsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.contacts),
              label: const Text('Emergency Contacts'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Notifications action
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Profile action
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authNotifier = ref.read(currentUserProvider.notifier);
              await authNotifier.logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${currentUser?.name}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SYSTEM ADMINISTRATOR',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'System management and configuration',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              // System Stats
              _buildSystemStatsCard(context),
              const SizedBox(height: 24),

              // Admin Management Sections
              Text(
                'Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 16),

              // Management Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildAdminCard(
                    context,
                    Icons.people_outline,
                    'Manage Users',
                    'View and manage all users',
                    Colors.blue,
                    () {},
                  ),
                  _buildAdminCard(
                    context,
                    Icons.local_police_outlined,
                    'Police Officers',
                    'Manage police force',
                    Colors.indigo,
                    () {},
                  ),
                  _buildAdminCard(
                    context,
                    Icons.assessment_outlined,
                    'Reports',
                    'System analytics & reports',
                    Colors.orange,
                    () {},
                  ),
                  _buildAdminCard(
                    context,
                    Icons.history_outlined,
                    'Audit Logs',
                    'System activity logs',
                    Colors.purple,
                    () {},
                  ),
                  _buildAdminCard(
                    context,
                    Icons.settings_outlined,
                    'Configuration',
                    'System settings',
                    Colors.green,
                    () {},
                  ),
                  _buildAdminCard(
                    context,
                    Icons.security_outlined,
                    'Security',
                    'Security & permissions',
                    Colors.red,
                    () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 16),
              _buildQuickActionButton(
                context,
                'System Health Check',
                Icons.health_and_safety_outlined,
                Colors.green,
                () {},
              ),
              const SizedBox(height: 12),
              _buildQuickActionButton(
                context,
                'Database Backup',
                Icons.backup_outlined,
                Colors.blue,
                () {},
              ),
              const SizedBox(height: 12),
              _buildQuickActionButton(
                context,
                'Emergency Broadcast',
                Icons.notification_important_outlined,
                Colors.red,
                () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn(context, 'Active Users', '42', Colors.blue),
            Container(width: 1, height: 60, color: Colors.grey[300]),
            _buildStatColumn(context, 'Police Officers', '18', Colors.indigo),
            Container(width: 1, height: 60, color: Colors.grey[300]),
            _buildStatColumn(context, 'Total Requests', '156', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
      BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.trending_up, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              top: BorderSide(color: color, width: 3),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
