part of 'settings__cubit.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  SettingsLoaded(this.settings);
  final SettingsModel settings;
}

class SettingsFallback extends SettingsState {
  SettingsFallback({
    required this.settings,
    required this.errorMessage,
  });
  final SettingsModel settings;
  final String errorMessage;
}
