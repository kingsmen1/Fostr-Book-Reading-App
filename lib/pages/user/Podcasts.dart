import 'package:flutter/material.dart';
import 'package:fostr/widgets/PodcastScreen.dart';
import 'package:video_player/video_player.dart';

class Podcasts extends StatefulWidget {
  const Podcasts({Key? key}) : super(key: key);

  @override
  _PodcastsState createState() => _PodcastsState();
}

class _PodcastsState extends State<Podcasts> {
  PageController controller = new PageController();
  List<Widget> podcasts = [
    PodcastScreen(),
    PodcastScreen(),
    PodcastScreen(),
    PodcastScreen(),
    PodcastScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: PageView(
                scrollDirection: Axis.vertical,
                children: podcasts,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
