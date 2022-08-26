import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/services/AudioPlayerService.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:get_it/get_it.dart';
import 'package:googleapis/script/v1.dart';
import 'package:provider/provider.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';

class SwipeCardWidget extends StatefulWidget {
  const SwipeCardWidget({Key? key}) : super(key: key);

  @override
  State<SwipeCardWidget> createState() => _SwipeCardWidgetState();
}

class _SwipeCardWidgetState extends State<SwipeCardWidget> {

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection("feeds")
          .where("idType", isEqualTo: "reviews")
          .where("isActive", isEqualTo: true)
          .orderBy("dateTime", descending: true)
          .snapshots(),
      builder: (context, snapshot) {

            if(!snapshot.hasData){
              return SizedBox.shrink();
            }

            List list = [];
            snapshot.data!.docs.forEach((element) {
              list.add(element.id);
            });

        return Card(bitIds: list);
      }
    );
  }
}

class Card extends StatefulWidget {
  final List bitIds;
  const Card({Key? key, required this.bitIds}) : super(key: key);

  @override
  State<Card> createState() => _CardState();
}

class _CardState extends State<Card> {

  List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  AudioPlayer player = AudioPlayer();
  final AudioPlayerService _audioPlayerService = GetIt.I<AudioPlayerService>();

  @override
  void initState() {
    print("swipe card ids ${widget.bitIds.length}");
    player = _audioPlayerService.player;
    for (int i = 0; i < widget.bitIds.length; i++) {
      _swipeItems.add(SwipeItem(
          content: Content(id: widget.bitIds[i]),
          likeAction: () {

          },
          nopeAction: () {

          },
          superlikeAction: () {

          },
          onSlideUpdate: (SlideRegion? region) async {
          }));
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);


    super.initState();
  }

  void play(String audio) async {
    await player.setUrl(audio).then((value) async {
      await player.resume().then((value) {
        setState(() {
          _audioPlayerService;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);
    return Container(
      width: 350,
      height: 350,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                theme.colorScheme.secondary,
                dark_blue
                //Color(0xFF2E3170)
              ],
              begin : Alignment.topCenter,
              end : Alignment.bottomCenter,
              stops: [0,0.92]
          ),
          borderRadius: BorderRadius.circular(10)
      ),
      child: Stack(
        children: [

          Container(
            child: Center(
              child: Text("no more reviews available",
                style: TextStyle(
                  fontFamily: "drawerbody",
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontSize: 12
              ),),
            ),
          ),

          SwipeCards(
              matchEngine: _matchEngine!,
              upSwipeAllowed: false,
              onStackFinished: () {
                print("stack finished");
              },
              itemBuilder: (context, index) {

                return StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection("reviews")
                        .doc(_swipeItems[index].content.id)
                        .snapshots(),
                    builder: (context, snapshot) {

                      if(!snapshot.hasData){
                        return SizedBox.shrink();
                      }

                      // if(snapshot.connectionState.index == ConnectionState.waiting.index){
                      //   return Container(child: AppLoading(width: 70, height: 70,));
                      // }

                      return Container(
                        decoration: BoxDecoration(
                            // color: theme.colorScheme.secondary,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.secondary,
                          dark_blue
                          //Color(0xFF2E3170)
                        ],
                        begin : Alignment.topCenter,
                        end : Alignment.bottomCenter,
                        stops: [0,0.92]
                      ),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          children: [

                            //image
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                width: 340,
                                height: 220,
                                decoration: BoxDecoration(
                                    color: Colors.white, //Color(0xFFFDBCA5),
                                    border: Border.all(color: theme.colorScheme.secondary, width: 0.5),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: snapshot.data!["imageUrl"].toString().isNotEmpty ?
                                  Image.network(snapshot.data!["imageUrl"],fit: BoxFit.contain,) :
                                  Image.asset("assets/images/logo.png"),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10) +
                                  const EdgeInsets.only(bottom: 10),
                              child: Container(
                                width: 340,
                                height: 80,
                                color:  Colors.transparent, //Color(0xFF386764),//Color(0xFFFDBCA5),
                                child: Row(
                                  children: [

                                    //title and author
                                    Container(
                                      width: 280,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [

                                          Text(snapshot.data!["bookName"].toString().isNotEmpty ?
                                          snapshot.data!["bookName"] : "",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "drawerhead",
                                                fontSize: 20
                                            ),textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,),

                                          SizedBox(height: snapshot.data!["bookAuthor"].toString().isNotEmpty ? 5 : 0,),

                                          Text(snapshot.data!["bookAuthor"].toString().isNotEmpty ?
                                          "by ${snapshot.data!["bookAuthor"]}" : "",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "drawerbody",
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic
                                            ),textAlign: TextAlign.center,),

                                        ],
                                      ),
                                    ),

                                    //play
                                    Container(
                                      width: 40,
                                      child: GestureDetector(
                                          onTap: (){
                                            if(audioPlayerData.mediaMeta.audioId == snapshot.data!["id"] &&
                                                _audioPlayerService.player.state.name == "PLAYING") {
                                              setState((){
                                                _audioPlayerService.player.pause();
                                                player.pause();
                                              });

                                            }
                                            else if (audioPlayerData.mediaMeta.audioId == snapshot.data!["id"] &&
                                                _audioPlayerService.player.state.name != "PLAYING"){
                                              setState(() {
                                                _audioPlayerService.player.resume();
                                                player.resume();
                                              });

                                            } else if (audioPlayerData.mediaMeta.audioId != snapshot.data!["id"]){
                                              audioPlayerData.setMediaMeta(
                                                  MediaMeta(
                                                      audioId: snapshot.data!["id"],
                                                      audioName: snapshot.data!["bookName"],
                                                      userName: snapshot.data!["bookAuthor"],
                                                      rawData: snapshot.data!.data(),
                                                      mediaType: MediaType.bits
                                                  ), shouldNotify: true);

                                              play(snapshot.data!["url"]);
                                            }
                                          },
                                          child: (audioPlayerData.mediaMeta.audioId == snapshot.data!["id"] &&
                                              _audioPlayerService.player.state == PlayerState.PLAYING ||
                                              _audioPlayerService.player.state == PlayerState.COMPLETED) ?
                                          Icon(Icons.pause_circle_outline_rounded, color: Colors.deepOrange, size: 35,) :
                                          Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 35,)),
                                    )
                                  ],
                                ),
                              ),
                            ),

                            Text("swipe for next",
                              style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              color: Colors.white
                            ),)


                          ],
                        ),
                      );
                    }
                );
              }
          ),
        ],
      ),
    );
  }
}

class Content {
  final String id;

  Content({required this.id});
}


