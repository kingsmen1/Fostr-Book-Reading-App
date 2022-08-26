import 'package:flutter/material.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:video_player/video_player.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({Key? key}) : super(key: key);

  @override
  _PodcastScreenState createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  late VideoPlayerController videoPlayerController;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Positioned.fill(child: Text("s")),
                Align(
                  alignment: Alignment(0, 0.95),
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0.0, 2.0), //(x,y)
                            blurRadius: 5.0,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15)),
                    child: Text("")
                  ),
                )
              ],
            )),
      ),
    );
  }
}
