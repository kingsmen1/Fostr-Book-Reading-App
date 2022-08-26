import 'package:flutter/material.dart';
import 'package:fostr/albums/PodcastPage.dart';

class PodcastEnrote extends StatefulWidget {
  const PodcastEnrote({Key? key}) : super(key: key);

  @override
  State<PodcastEnrote> createState() => _PodcastEnroteState();
}

class _PodcastEnroteState extends State<PodcastEnrote> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.light ?
      Colors.teal.shade300 :
      Colors.deepOrange.shade300,

      body: Stack(
        children: [
          PodcastPage(enroute: true),

          Align(
            alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 20),
                child: IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios,)
                ),
              )
          )
        ],
      ),
    );
  }
}
