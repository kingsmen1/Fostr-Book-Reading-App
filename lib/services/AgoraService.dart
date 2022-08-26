import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/functions.dart';

class AgoraService {
  RtcEngine? _engine;

  RtcEngine? get engine => _engine;
  AgoraRtmClient? _rtmClient;

  String rtmToken = "";

  AgoraService.init() {
    initEngine();
  }

  Future<RtcEngine?> initEngine() async {
    try {
      _engine =
          await RtcEngine.createWithContext(RtcEngineContext(AGORA_APP_ID));
      await _engine?.enableAudio();
      await _engine?.disableVideo();
      await _engine?.setChannelProfile(ChannelProfile.LiveBroadcasting);
      await _engine?.setClientRole(ClientRole.Broadcaster);
      _engine?.enableAudioVolumeIndication(200, 3, true);
      return _engine;
    } catch (e) {
      throw e;
    }
  }

  Future<AgoraRtmClient?> getRtmClient(String channelName, String id,
      String userName, bool useFreshToken) async {
    if (_rtmClient == null) {
      _rtmClient = await AgoraRtmClient.createInstance(AGORA_APP_ID);
    }

    if (useFreshToken || rtmToken.isEmpty) {
      rtmToken = await getRTMToken(channelName, id, userName);
      try {
        await _rtmClient?.login(rtmToken, userName);
      } catch (e) {
        print("-------------------");
        print(e);
        print("-------------------");
      }
    }

    return _rtmClient;
  }

  Future<void> sendRtmMessage(String id, AgoraRtmMessage message) async {
    if (_rtmClient == null) {
      _rtmClient = await AgoraRtmClient.createInstance(AGORA_APP_ID);
    }
    await _rtmClient?.sendMessageToPeer(id, message, false);
  }

  Future<void> destroyEngine() async {
    try {
      await engine?.leaveChannel();
    } catch (e) {}
  }

  Future<void> joinChannel(String token, String channelName) async {
    if (_engine == null) {
      await initEngine();
    }

    await _engine?.joinChannel(token, channelName, null, 0);
    await _engine?.muteLocalAudioStream(true);
  }

  Future<void> leaveChannel() async {
    engine?.leaveChannel();
  }

  // Future<void> destroyInstance() async {
  //   engine?.destroy();
  // }

  Future<void> toggleMute(bool state) async {
    _engine?.muteLocalAudioStream(state);
  }

  void setAgoraEventHandlers(RtcEngineEventHandler handler) {
    _engine!.setEventHandler(handler);
  }

  Future<void> setChannelProfile(ChannelProfile profile) async {
    await _engine?.setChannelProfile(profile);
  }

  Future<void> destroyClient() async {
    // await _rtmClient?.destroy();
    _rtmClient = null;
  }
}
