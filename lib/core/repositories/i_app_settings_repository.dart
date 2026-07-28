import '../../features/buyer_bloc_architecture/user_profile_image/AppSettings_State.dart';

abstract class IAppSettingsRepository {
  Future<AppSettingsState> loadSettings(String userId);
  Future<void> saveSettings(AppSettingsState state);
}
