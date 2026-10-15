import 'package:flutter/material.dart';
import '../theme.dart';
import '../settings_provider.dart';
import 'change_password_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = SettingsProvider.of(context);
    final settings = provider.settings;

    return Scaffold(
      backgroundColor: settings.darkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: settings.darkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: settings.darkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Settings", style: TextStyle(color: settings.darkMode ? Colors.white : Colors.black, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _switchOption(context, provider, "Push Notifications", settings.pushNotifications, (val) {
            provider.updateSettings(AppSettings(
              darkMode: settings.darkMode,
              pushNotifications: val,
              locationServices: settings.locationServices,
            ));
          }),
          _switchOption(context, provider, "Location Services", settings.locationServices, (val) {
            provider.updateSettings(AppSettings(
              darkMode: settings.darkMode,
              pushNotifications: settings.pushNotifications,
              locationServices: val,
            ));
          }),
          _switchOption(context, provider, "Dark Mode", settings.darkMode, (val) {
            provider.updateSettings(AppSettings(
              darkMode: val,
              pushNotifications: settings.pushNotifications,
              locationServices: settings.locationServices,
            ));
          }),
          const SizedBox(height: 20),
          _tapOption(context, settings, "Change Password", const ChangePasswordScreen()),
          _tapOption(context, settings, "Privacy Policy", const PrivacyPolicyScreen()),
          _tapOption(context, settings, "Terms of Service", const TermsOfServiceScreen()),
        ],
      ),
    );
  }

  Widget _switchOption(BuildContext context, SettingsProvider provider, String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: provider.settings.darkMode ? BizaTheme.cardBackground : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title, style: TextStyle(color: provider.settings.darkMode ? Colors.white : Colors.black, fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeColor: BizaTheme.primaryGreen,
      ),
    );
  }

  Widget _tapOption(BuildContext context, AppSettings settings, String title, Widget destination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: settings.darkMode ? BizaTheme.cardBackground : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: settings.darkMode ? Colors.white : Colors.black, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      ),
    );
  }
}