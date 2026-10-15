import 'package:flutter/material.dart';

class AppSettings {
  bool darkMode;
  bool pushNotifications;
  bool locationServices;

  AppSettings({
    this.darkMode = true,
    this.pushNotifications = true,
    this.locationServices = true,
  });
}

class SettingsProvider extends InheritedWidget {
  final AppSettings settings;
  final Function(AppSettings) updateSettings;

  const SettingsProvider({
    super.key,
    required this.settings,
    required this.updateSettings,
    required super.child,
  });

  static SettingsProvider of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SettingsProvider>();
    assert(result != null, 'No SettingsProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SettingsProvider oldWidget) {
    return oldWidget.settings != settings;
  }
}