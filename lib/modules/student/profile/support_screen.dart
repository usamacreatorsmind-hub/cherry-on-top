import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // Method to launch email client
  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@cherryontop.com', // replace with your actual support email
      query: encodeQueryParameters(<String, String>{
        'subject': 'Support Request - Cherry on Top',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      Get.snackbar(
        "Error",
        "Could not launch email app. Please write to support@cherryontop.com",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.maroon),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Support",
          style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          const Center(
            child: Icon(Icons.headset_mic_rounded, size: 80, color: AppTheme.maroon),
          ),
          const SizedBox(height: 24),
          const Text(
            "How can we help you?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            "We are here to assist you with any questions or issues you may have.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 40),

          // EMAIL SUPPORT CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.maroon.withAlpha(10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.maroon.withAlpha(30)),
            ),
            child: Column(
              children: [
                const Text(
                  "Write to us at",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.maroon),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _sendEmail,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.maroon.withAlpha(50)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.email_outlined, color: AppTheme.maroon, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          "support@cherryontop.com",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // LEGAL OPTIONS
          _buildLegalTile(
            title: "Terms and Conditions",
            icon: Icons.description_outlined,
            onTap: () {
              // Navigation to actual terms text/web page
            },
          ),
          const SizedBox(height: 12),
          _buildLegalTile(
            title: "Privacy Policy",
            icon: Icons.privacy_tip_outlined,
            onTap: () {
              // Navigation to privacy policy
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegalTile({required String title, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      tileColor: Colors.grey.shade50,
      leading: Icon(icon, color: AppTheme.maroon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}
