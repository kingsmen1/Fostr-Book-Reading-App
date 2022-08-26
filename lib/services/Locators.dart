import 'package:fostr/services/BookClubServices.dart';
import 'package:fostr/services/TheatreService.dart';
import 'package:get_it/get_it.dart';

import 'AgoraService.dart';
import 'AudioPlayerService.dart';
import 'CacheService.dart';
import 'DeviceSettings.dart';
import 'InAppNotificationService.dart';
import 'ISBNService.dart';
import 'MethodeChannels.dart';
import 'NotificationService.dart';
import 'RatingsService.dart';
import 'RecordingService.dart';
import 'RoomService.dart';
import 'UserService.dart';
import 'RemoteConfigService.dart';

void setupLocators() {
  GetIt.I.registerSingleton(UserService());
  GetIt.I.registerSingleton(AgoraService.init());
  GetIt.I.registerSingleton(FosterMethodChannel());
  GetIt.I.registerSingleton(RatingService());
  GetIt.I.registerSingleton(RoomService());
  GetIt.I.registerSingleton(NotificationService());
  GetIt.I.registerSingleton(InAppNotificationService());
  GetIt.I.registerSingleton(CacheService());
  GetIt.I.registerSingleton(RecordingService());
  GetIt.I.registerSingleton(RemoteConfigService.init());
  GetIt.I.registerSingleton(DeviceSettings());
  GetIt.I.registerSingleton(AudioPlayerService());
  GetIt.I.registerSingleton(ISBNService());
  GetIt.I.registerSingleton(TheatreService());
  GetIt.I.registerSingleton(BookClubServices());
}
