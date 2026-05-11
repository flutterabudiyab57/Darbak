import 'package:bloc/bloc.dart';
import 'package:darbak/core/helpers/settings/settings_model.dart';
import 'package:darbak/core/helpers/settings/settings_repository.dart';
part 'settings__state.dart';
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(SettingsInitial());
  final SettingsRepository _repository;
  SettingsModel get current {
    final s = state;
    if (s is SettingsLoaded) return s.settings;
    if (s is SettingsFallback) return s.settings;
    return _repository.fallback;
  }

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    try {
      final model = await _repository.fetchSettings();
      emit(SettingsLoaded(model));
    } catch (e) {
      emit(
        SettingsFallback(
          settings: _repository.fallback,
          errorMessage: e.toString(),
        ),
      );
    }
  }
  Future<void> refreshSettings() async {
    try {
      final model = await _repository.fetchSettings();
      emit(SettingsLoaded(model));
    } catch (e) {
    }
  }
}