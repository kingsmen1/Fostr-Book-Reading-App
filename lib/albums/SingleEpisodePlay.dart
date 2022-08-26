import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class SingleEpisodePlay extends StatefulWidget {
  final Map<String,dynamic> episode;
  final String authorName;
  const SingleEpisodePlay({
    Key? key,
    required this.episode,
    required this.authorName
  }) : super(key: key);

  @override
  State<SingleEpisodePlay> createState() => _SingleEpisodePlayState();
}

class _SingleEpisodePlayState extends State<SingleEpisodePlay> {

  late Timestamp datetime;
  String finalDateTime = "";

  AudioPlayer player = AudioPlayer();
  bool isAudioAvailable = false;
  bool loading = false;
  bool isReadyToPlay = false;
  bool isPlaying = false;
  bool isFinished = false;
  Duration? audioDuration;

  @override
  void initState() {

    if (widget.episode["dateTime"].runtimeType != Timestamp) {
      int seconds = int.parse(
          widget.episode["dateTime"].toString().split("_seconds: ")[1].split(", _")[0]);
      int nanoseconds = int.parse(
          widget.episode["dateTime"].toString().split("_nanoseconds: ")[1].split("}")[0]);
      datetime = Timestamp(seconds, nanoseconds);
    } else {
      datetime = widget.episode["dateTime"];
    }

    var dateDiff = DateTime.now().difference(datetime.toDate());
    if (dateDiff.inDays >= 1) {
      finalDateTime = DateFormat.yMMMd()
          .addPattern(" | ")
          .add_jm()
          .format(datetime.toDate())
          .toString();
    } else {
      finalDateTime = timeago.format(datetime.toDate());
    }

    player.positionStream.listen((event) async {
      if (audioDuration != null && event == audioDuration) {
        await player.stop();
        player.seek(Duration.zero);
        setState(() {
          isPlaying = false;
          isFinished = true;
        });
      }
    });
    isAudioAvailable = true;

    super.initState();
  }

  void _init() async {
    try {
      await player.setUrl(widget.episode["audio"]).then((value) {
        setState(() {
          audioDuration = value;
          isAudioAvailable = true;
          isReadyToPlay = true;
          isPlaying = true;
          loading = false;
        });
        player.play();
      });
    } catch (e) {
      debugPrint('An error occured $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void downloadWidget(String url) {
    setState(() {
      loading = true;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,

      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios,
                color: theme.colorScheme.inversePrimary)
        ),
        actions: [
          Image.asset("assets/images/logo.png", width: 45, height: 45,),
        ],
      ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: theme.colorScheme.primary,
        child: Column(
          children: [
            SizedBox(height: 50,),

            //image
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.episode['image'].toString().isEmpty ?
                Center(child: Image.asset("assets/images/logo.png", width: 100, height: 100,)) :
                Image.network(widget.episode['image'], fit: BoxFit.cover,),
              ),
            ),
            SizedBox(height: 10,),

            //title
            Container(
              width: MediaQuery.of(context).size.width-40,
              child: Text(widget.episode['title'],
                style: TextStyle(
                    color: theme.colorScheme.inversePrimary,
                    fontSize: 26,
                    fontFamily: "drawerhead"
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10,),

            //author
            Container(
              width: MediaQuery.of(context).size.width-40,
              child: Text("by ${widget.authorName}",
                style: TextStyle(
                    color: theme.colorScheme.inversePrimary,
                    fontSize: 12,
                    fontFamily: "drawerbody"
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 5,),

            //datetime
            Container(
              width: MediaQuery.of(context).size.width-40,
              child: Text(finalDateTime,
                style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 12,
                    fontFamily: "drawerbody"
                ),
                textAlign: TextAlign.center,
              ),
            ),

            //pause play seek bar
            isAudioAvailable
                ? Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //load button
                  GestureDetector(
                    onTap: () {
                      if (!loading) {
                        if (!isReadyToPlay) {
                          downloadWidget(widget.episode["audio"]);
                        } else if (!isPlaying) {
                          setState(() {
                            isPlaying = true;
                          });
                          player.play();
                        } else {
                          setState(() {
                            isPlaying = false;
                          });
                          player.pause();
                        }
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: loading
                              ? AppLoading(
                            height: 70,
                            width: 70,
                          )
                              : (!isReadyToPlay)
                              ? Icon(
                            Icons.play_arrow,
                            size: 20,
                            color: Colors.white,
                          )
                              : (!isPlaying)
                              ? Icon(
                            Icons.play_arrow,
                            size: 20,
                            color: Colors.white,
                          )
                              : Icon(
                            Icons.pause,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      width: 250,
                      child: Center(
                        child: StreamBuilder<DurationState>(
                          stream: Rx.combineLatest2<Duration,
                              PlaybackEvent, DurationState>(
                              player.positionStream,
                              player.playbackEventStream,
                                  (position, playbackEvent) => DurationState(
                                progress: position,
                                buffered:
                                playbackEvent.bufferedPosition,
                                total: playbackEvent.duration,
                              )),
                          builder: (context, snapshot) {
                            final durationState = snapshot.data;
                            final position =
                                durationState?.progress ?? Duration.zero;
                            final buffered =
                                durationState?.buffered ?? Duration.zero;
                            final total =
                                durationState?.total ?? Duration.zero;

                            return StreamBuilder<Duration>(
                                stream: player.positionStream,
                                builder: (context, snapshot) {
                                  return ProgressBar(
                                    progress:
                                    snapshot.data ?? Duration.zero,
                                    buffered: buffered,
                                    total: total,
                                    onSeek: (duration) {
                                      player.seek(duration);
                                    },
                                    barHeight: 5,
                                    baseBarColor: theme
                                        .colorScheme.secondary
                                        .withOpacity(0.5),
                                    progressBarColor:
                                    theme.colorScheme.secondary,
                                    bufferedBarColor: theme
                                        .colorScheme.secondary
                                        .withOpacity(0.5),
                                    thumbColor: Colors.grey.shade300,
                                    barCapShape: BarCapShape.round,
                                    thumbRadius: 10,
                                    thumbCanPaintOutsideBar: false,
                                    timeLabelLocation:
                                    TimeLabelLocation.below,
                                    timeLabelType:
                                    TimeLabelType.totalTime,
                                    timeLabelTextStyle: TextStyle(
                                      fontSize: 10,
                                      fontFamily: "drawerbody",
                                      color: theme
                                          .colorScheme.inversePrimary,
                                    ),
                                    timeLabelPadding: 0,
                                  );
                                });
                          },
                        ),
                      ),
                    ),
                  ),

                  //pause button
                ],
              ),
            )
                : Container(),

          ],
        ),
      ),

    );
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration? total;
}
