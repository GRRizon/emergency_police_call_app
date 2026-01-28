import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_strings.dart';
import '../../presentation/providers/emergency_request_provider.dart';
import '../../presentation/providers/location_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/widgets/app_snackbar.dart';

class SOSScreen extends ConsumerStatefulWidget {
  const SOSScreen({super.key});

  @override
  ConsumerState<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends ConsumerState<SOSScreen> {
  final _descriptionController = TextEditingController();
  Position? _currentLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _sendEmergencySMS(String phoneNumber, String message) async {
    try {
      final Uri uri = Uri.parse("sms:$phoneNumber?body=${Uri.encodeComponent(message)}");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          AppSnackBar.show(
            context,
            message: 'Could not open SMS app',
            type: SnackBarType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Failed to send SMS: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final locationNotifier = ref.read(locationNotifierProvider.notifier);
      await locationNotifier.getCurrentLocation();
      final location = ref.read(locationNotifierProvider);
      setState(() => _currentLocation = location);
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppStrings.locationError,
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _triggerSOS() async {
    if (_currentLocation == null) {
      AppSnackBar.show(
        context,
        message: 'Please enable location services',
        type: SnackBarType.error,
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please describe your emergency',
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final requestNotifier =
          ref.read(emergencyRequestNotifierProvider.notifier);
      await requestNotifier.createRequest(
        userId: currentUser.userId,
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        description: _descriptionController.text,
      );

      // Create SMS message with location details
      final smsMessage = '''🚨 EMERGENCY ALERT 🚨
${currentUser.name} needs help!

Location: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}

Emergency: ${_descriptionController.text}

Please call police immediately!''';

      // Send SMS to emergency contact (police)
      // In production, this would send to registered emergency contacts
      await _sendEmergencySMS('911', smsMessage);

      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Emergency reported! Help is on the way.',
          type: SnackBarType.success,
        );

        // Clear form
        _descriptionController.clear();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Failed to report emergency: $e',
          type: SnackBarType.error,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.emergency)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Location Display
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.primary),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  AppStrings.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey600,
                                  ),
                                ),
                                if (_currentLocation != null)
                                  Text(
                                    '${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                else
                                  const Text(
                                    'Getting location...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _loadCurrentLocation,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Description Input
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: AppStrings.description,
                    hintText: 'Describe your emergency situation in detail...',
                    prefixIcon: const Icon(Icons.edit),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Big SOS Button
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      elevation: 8,
                    ),
                    onPressed: _isLoading ? null : _triggerSOS,
                    child: _isLoading
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                'Sending SOS...',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.emergency,
                                size: 64,
                                color: Colors.white,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Text(
                                AppStrings.sos,
                                style: TextStyle(
                                  fontSize: 36,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              const Text(
                                'Press to send emergency alert',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ℹ️ When you press SOS:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        '• Your location will be shared\n'
                        '• Emergency contacts will be notified\n'
                        '• Nearest police officer will respond\n'
                        '• Help center will track your case',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
