import 'package:flutter/material.dart';

import 'sos_page.dart';
import 'contacts_page.dart';
import 'map_page.dart';
import 'navigation_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "POLICE EMERGENCY",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "ONE-TAP DISTRESS TRIGGER",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const Spacer(),

          /// SOS Button
          GestureDetector(
            onTap: () => NavigationService.navigateTo(const SosPage()),
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.2),
                    spreadRadius: 30,
                    blurRadius: 60,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  height: 240,
                  width: 240,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_active,
                          size: 50, color: Colors.white),
                      Text(
                        "SOS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 65,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Row(
              children: [
                Expanded(
                  child: _buildNavButton(
                    icon: Icons.people_alt,
                    label: "Contacts",
                    onTap: () =>
                        NavigationService.navigateTo(const ContactsPage()),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildNavButton(
                    icon: Icons.map,
                    label: "Live Map",
                    onTap: () => NavigationService.navigateTo(const MapPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
      ),
    );
  }
}
