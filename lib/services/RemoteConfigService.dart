import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _config = FirebaseRemoteConfig.instance;

  RemoteConfigService.init() {
    initConfig();
  }

  Future<void> initConfig() async {
    await _config.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 2),
      ),
    );
    await _config.setDefaults({
      "betaRecording": true,
    });
    await _config.fetchAndActivate();
  }

  bool get betaRecording => _config.getBool("betaRecording");
}
