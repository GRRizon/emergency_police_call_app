import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_strings.dart';
import '../../domain/entities/emergency_request.dart';
import '../../presentation/providers/emergency_request_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/location_provider.dart';
import '../../presentation/widgets/app_dialogs.dart';
import '../../presentation/widgets/app_snackbar.dart';

class PoliceDashboardScreen extends ConsumerStatefulWidget {
  const PoliceDashboardScreen({super.key});

  @override
  ConsumerState<PoliceDashboardScreen> createState() =>
      _PoliceDashboardScreenState();
}

class _PoliceDashboardScreenState extends ConsumerState<PoliceDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening to location updates for real-time tracking
    ref.read(locationUpdatesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null ||
        currentUser.role.toString() != 'UserRole.police') {
      return const Scaffold(
        body: Center(child: Text(AppStrings.unauthorized)),
      );
    }

    final activeRequests = ref.watch(allActiveRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Police Dashboard'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Profile action
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(currentUserProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: activeRequests.when(
        data: (requests) {
          final pendingRequests = requests
              .where((r) => r.status == EmergencyRequestStatus.pending)
              .toList();
          final acceptedRequests = requests
              .where((r) =>
                  r.status == EmergencyRequestStatus.accepted ||
                  r.status == EmergencyRequestStatus.enRoute ||
                  r.status == EmergencyRequestStatus.arrived)
              .toList();
          final resolvedRequests = requests
              .where((r) => r.status == EmergencyRequestStatus.resolved)
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(allActiveRequestsProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.lg,
                        left: AppSpacing.sm,
                        right: AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, ${currentUser.name}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Manage emergency requests in real-time',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),

                    // Enhanced Stats Cards
                    StatsCard(
                      pendingCount: pendingRequests.length,
                      acceptedCount: acceptedRequests.length,
                      resolvedCount: resolvedRequests.length,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Pending Requests Section
                    _buildSectionHeader(
                      context,
                      'Pending Requests',
                      pendingRequests.length,
                      AppColors.warning,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (pendingRequests.isEmpty)
                      _buildEmptyState(
                        context,
                        'No pending requests',
                        Icons.check_circle_outline,
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pendingRequests.length,
                        itemBuilder: (context, index) {
                          final request = pendingRequests[index];
                          return EmergencyRequestCard(
                            request: request,
                            onAccept: () =>
                                _handleAcceptRequest(context, request),
                            onReject: () =>
                                _handleRejectRequest(context, request),
                            currentUser: currentUser,
                          );
                        },
                      ),
                    const SizedBox(height: AppSpacing.xl),

                    // My Active Requests Section
                    _buildSectionHeader(
                      context,
                      'Active Assignments',
                      acceptedRequests.length,
                      AppColors.info,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (acceptedRequests.isEmpty)
                      _buildEmptyState(
                        context,
                        'No active requests',
                        Icons.assignment_turned_in_outlined,
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: acceptedRequests.length,
                        itemBuilder: (context, index) {
                          final request = acceptedRequests[index];
                          return ActiveRequestCard(
                            request: request,
                            onUpdateStatus: () =>
                                _handleUpdateStatus(context, request),
                            onResolve: () => _handleResolve(context, request),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              Text(
                '$count request${count != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAcceptRequest(
    BuildContext context,
    EmergencyRequest request,
  ) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Accept Request',
        message:
            'Do you accept this emergency request? You will be assigned to handle it.',
        confirmText: 'Accept',
        cancelText: 'Cancel',
        onConfirm: () async {
          final currentUser = ref.read(currentUserProvider);
          if (currentUser != null) {
            final notifier =
                ref.read(emergencyRequestNotifierProvider.notifier);
            await notifier.updateRequestStatus(
              requestId: request.requestId,
              status: EmergencyRequestStatus.accepted,
            );
            await notifier.assignOfficer(
              requestId: request.requestId,
              policeId: currentUser.userId,
            );

            if (context.mounted) {
              AppSnackBar.show(
                context,
                message: 'Request accepted! Navigate to the location.',
                type: SnackBarType.success,
              );
            }
          }
        },
      ),
    );
  }

  void _handleRejectRequest(
    BuildContext context,
    EmergencyRequest request,
  ) {
    AppSnackBar.show(
      context,
      message: 'Request rejected',
      type: SnackBarType.info,
    );
  }

  void _handleUpdateStatus(
    BuildContext context,
    EmergencyRequest request,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('En Route'),
              onTap: () {
                final notifier =
                    ref.read(emergencyRequestNotifierProvider.notifier);
                notifier.updateRequestStatus(
                  requestId: request.requestId,
                  status: EmergencyRequestStatus.enRoute,
                );
                Navigator.pop(context);
                AppSnackBar.show(
                  context,
                  message: 'Status updated to En Route',
                  type: SnackBarType.success,
                );
              },
            ),
            ListTile(
              title: const Text('Arrived'),
              onTap: () {
                final notifier =
                    ref.read(emergencyRequestNotifierProvider.notifier);
                notifier.updateRequestStatus(
                  requestId: request.requestId,
                  status: EmergencyRequestStatus.arrived,
                );
                Navigator.pop(context);
                AppSnackBar.show(
                  context,
                  message: 'Status updated to Arrived',
                  type: SnackBarType.success,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleResolve(
    BuildContext context,
    EmergencyRequest request,
  ) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Resolve Request',
        message: 'Mark this emergency request as resolved?',
        confirmText: 'Resolve',
        cancelText: 'Cancel',
        onConfirm: () async {
          final notifier = ref.read(emergencyRequestNotifierProvider.notifier);
          await notifier.updateRequestStatus(
            requestId: request.requestId,
            status: EmergencyRequestStatus.resolved,
          );

          if (context.mounted) {
            AppSnackBar.show(
              context,
              message: 'Request resolved',
              type: SnackBarType.success,
            );
          }
        },
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final int pendingCount;
  final int acceptedCount;
  final int resolvedCount;

  const StatsCard({
    super.key,
    required this.pendingCount,
    required this.acceptedCount,
    required this.resolvedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              label: 'Pending',
              count: pendingCount,
              color: AppColors.warning,
              icon: Icons.schedule,
            ),
            Container(
              width: 1,
              height: 60,
              color: Colors.grey[300],
            ),
            _StatItem(
              label: 'Active',
              count: acceptedCount,
              color: AppColors.info,
              icon: Icons.directions_run,
            ),
            Container(
              width: 1,
              height: 60,
              color: Colors.grey[300],
            ),
            _StatItem(
              label: 'Resolved',
              count: resolvedCount,
              color: AppColors.success,
              icon: Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class EmergencyRequestCard extends StatelessWidget {
  final EmergencyRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final dynamic currentUser;

  const EmergencyRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border(
            left: BorderSide(
              color: AppColors.warning,
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Request',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'ID: ${request.requestId.substring(0, 12)}...',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    request.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Lat: ${request.latitude.toStringAsFixed(4)}, Lon: ${request.longitude.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveRequestCard extends StatelessWidget {
  final EmergencyRequest request;
  final VoidCallback onUpdateStatus;
  final VoidCallback onResolve;

  const ActiveRequestCard({
    super.key,
    required this.request,
    required this.onUpdateStatus,
    required this.onResolve,
  });

  String _getStatusColor(EmergencyRequestStatus status) {
    switch (status) {
      case EmergencyRequestStatus.accepted:
        return 'ACCEPTED';
      case EmergencyRequestStatus.enRoute:
        return 'EN ROUTE';
      case EmergencyRequestStatus.arrived:
        return 'ARRIVED';
      default:
        return 'ACTIVE';
    }
  }

  Color _getStatusColorValue(EmergencyRequestStatus status) {
    switch (status) {
      case EmergencyRequestStatus.accepted:
        return AppColors.info;
      case EmergencyRequestStatus.enRoute:
        return Colors.orange;
      case EmergencyRequestStatus.arrived:
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColorValue(request.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border(
            left: BorderSide(color: statusColor, width: 4),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Assignment',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'ID: ${request.requestId.substring(0, 12)}...',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    _getStatusColor(request.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    request.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: statusColor),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Lat: ${request.latitude.toStringAsFixed(4)}, Lon: ${request.longitude.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onUpdateStatus,
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Status'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    onPressed: onResolve,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Resolve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
