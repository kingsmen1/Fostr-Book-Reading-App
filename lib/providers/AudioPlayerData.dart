import 'dart:async';
import 'package:flutter/material.dart';

class AudioPlayerData with ChangeNotifier {
  bool _shoudlShow = false;
  MediaMeta _mediaMeta = MediaMeta();

  StreamController<MediaMeta> _mediaMetaController =
      StreamController.broadcast();
  Stream<MediaMeta> get mediaMetaStream => _mediaMetaController.stream;

  AudioPlayerData() {
    _mediaMetaController.add(MediaMeta());
  }

  MediaMeta get mediaMeta => _mediaMeta;
  bool get shouldShow => _shoudlShow;

  void showPlayer() {
    if (_mediaMeta.mediaType != MediaType.none) {
      _shoudlShow = true;
      notifyListeners();
    }
  }

  void hidePlayer() {
    if (_mediaMeta.mediaType != MediaType.none) {
      _shoudlShow = false;
      notifyListeners();
    }
  }

  void setMediaMeta(MediaMeta meta, {bool shouldNotify = false}) {
    _mediaMeta = meta;
    _mediaMetaController.add(meta);
    if (shouldNotify) notifyListeners();
  }
}

enum MediaType { rooms, theatres, bits, recordings, episode, none }

class MediaMeta {
  final MediaType mediaType;
  final String? audioId;
  final String? albumId;
  final String? audioName;
  final String? userName;
  final List? episodeList;
  final List? episodeNames;
  final int? episodeIndex;
  final Map<dynamic, dynamic>? rawData;

  MediaMeta(
      {this.audioId,
      this.audioName,
        this.albumId,
      this.userName,
      this.rawData,
        this.episodeList,
        this.episodeNames,
        this.episodeIndex,
      this.mediaType = MediaType.none});

  @override
  String toString() {
    return {
      "audioId": this.audioId,
      "albumId": this.albumId,
      "audioName": this.audioName,
      "userName": this.userName,
      "episodeList": this.episodeList,
      "episodeNames": this.episodeNames,
      "episodeIndex": this.episodeIndex,
      "rawData": this.rawData.toString(),
      "mediaType": this.mediaType.toString(),
    }.toString();
  }
}
