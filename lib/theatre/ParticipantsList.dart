import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/services/AgoraService.dart';
import 'package:fostr/services/AgoraUserEvents.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:get_it/get_it.dart';

class TheatreParticipantsList extends StatefulWidget {
  final participants;
  final Theatre theatre;
  final int userID;

  const TheatreParticipantsList({
    Key? key,
    required this.participants,
    required this.userID,
    required this.theatre,
  }) : super(key: key);

  @override
  _TheatreParticipantsListState createState() =>
      _TheatreParticipantsListState();
}

class _TheatreParticipantsListState extends State<TheatreParticipantsList> {
  final AgoraService agoraService = GetIt.I<AgoraService>();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text(
          "Participants requested to speak",
          style: TextStyle(fontSize: 16, fontFamily: "drawerhead"),
        ),
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(top:20.0,left:20),
          //   child: Row(
          //     children: [
          //
          //       Align(
          //         alignment: Alignment.centerLeft,
          //         child: IconButton(
          //             onPressed: (){
          //               Navigator.of(context).pop();
          //             },
          //             icon: Icon(Icons.arrow_back_ios)),
          //       ),
          //       Text(
          //         "Participants list",
          //         style: TextStyle(
          //           fontSize: 20
          //         )
          //       ),
          //     ],
          //   ),
          // ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: widget.participants.length,
              itemBuilder: (BuildContext context, int index) {
                return widget.participants[index]['rtcId'] != widget.userID
                    ? ListTile(
                        title: Row(
                          children: [
                            Text(
                              widget.participants[index]['name'],
                              style: TextStyle(
                                  fontSize: 14, fontFamily: "drawerbody"),
                            ),
                            Expanded(child: Container()),

                            //remove participant
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    )),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red),
                                  ),
                                  onPressed: () async {
                                    AgoraUserEvents(
                                            cname: widget.theatre.title,
                                            uid: widget.participants[index]
                                                ['rtcId'])
                                        .kickOutParticipant();

                                    // try {
                                    //   AgoraRtmMessage message = AgoraRtmMessage.fromText("mute");
                                    //   print(message.text);
                                    //   await widget.client.sendMessageToPeer(
                                    //       widget.participants[index]['rtcId'].toString(),
                                    //       message,
                                    //       false
                                    //   );
                                    //   print('Send peer message success.');
                                    // } catch (errorCode) {
                                    //   print('Send peer message error: ' + errorCode.toString());
                                    // }

                                    await roomCollection
                                        .doc(widget.theatre.createdBy)
                                        .collection("amphitheatre")
                                        .doc(widget.theatre.theatreId)
                                        .collection('users')
                                        .doc(widget.participants[index]
                                            ['userName'])
                                        .update({
                                      "isActiveInRoom": false,
                                      "isKickedOut": true
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Remove",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontFamily: "drawerbody"),
                                  )),
                            ),
                            SizedBox(
                              width: 5,
                            ),

                            widget.participants[index]["role"] == 2
                                ?

                                //make speaker
                                Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          )),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.teal),
                                        ),
                                        onPressed: () async {
                                          try {
                                            AgoraRtmMessage message =
                                                AgoraRtmMessage.fromText(
                                                    "makeSpeaker");
                                            print(message.text);
                                            await agoraService
                                                .sendRtmMessage(
                                                    widget.participants[index]
                                                            ['userName']
                                                        .toString(),
                                                    message)
                                                .then((value) async {
                                              await roomCollection
                                                  .doc(widget.theatre.createdBy)
                                                  .collection("amphitheatre")
                                                  .doc(widget.theatre.theatreId)
                                                  .collection('users')
                                                  .doc(
                                                      widget.participants[index]
                                                          ['userName'])
                                                  .update({
                                                "role": 1,
                                                "requestToSpeak": false
                                              });
                                              // await TheatreService().acceptParticipantAsSpeaker(
                                              //     widget.theatre.createdBy?? "",
                                              //     widget.theatre.theatreId?? "",
                                              //     widget.participants[index]['userName']
                                              // );
                                              Navigator.of(context).pop();
                                            });
                                            print('Send peer message success.');
                                          } catch (errorCode) {
                                            print('Send peer message error: ' +
                                                errorCode.toString());
                                          }

                                          // AgoraUserEvents(cname: widget.theatre.title, uid: 123)
                                          //     .unMuteParticipant(widget.participants[index]['rtcId']);
                                        },
                                        child: Text(
                                          "Speaker",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontFamily: "drawerbody"),
                                        )),
                                  )
                                :

                                //make participant
                                Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          )),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  GlobalColors
                                                      .signUpSignInButton),
                                        ),
                                        onPressed: () async {
                                          try {
                                            AgoraRtmMessage message =
                                                AgoraRtmMessage.fromText(
                                                    "makeParticipant");
                                            print(message.text);
                                            await agoraService
                                                .sendRtmMessage(
                                                    widget.participants[index]
                                                            ['userName']
                                                        .toString(),
                                                    message)
                                                .then((value) async {
                                              // await TheatreService().acceptSpeakerAsParticipant(
                                              //     widget.theatre.createdBy?? "",
                                              //     widget.theatre.theatreId?? "",
                                              //     widget.participants[index]['userName']
                                              // );
                                              await roomCollection
                                                  .doc(widget.theatre.createdBy)
                                                  .collection("amphitheatre")
                                                  .doc(widget.theatre.theatreId)
                                                  .collection('users')
                                                  .doc(
                                                      widget.participants[index]
                                                          ['userName'])
                                                  .update({
                                                "role": 2,
                                              });
                                              Navigator.of(context).pop();
                                            });
                                            print('Send peer message success.');
                                          } catch (errorCode) {
                                            print('Send peer message error: ' +
                                                errorCode.toString());
                                          }

                                          // Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Participant",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontFamily: "drawerbody"),
                                        )),
                                  ),
                          ],
                        ),
                      )
                    : SizedBox.shrink();
              }),
        ],
      ),
    );
  }
}
