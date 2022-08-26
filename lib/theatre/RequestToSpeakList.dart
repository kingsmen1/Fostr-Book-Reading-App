import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/services/AgoraService.dart';
import 'package:get_it/get_it.dart';

class RequestList extends StatefulWidget {
  final participants;
  final Theatre theatre;

  final int userID;
  const RequestList(
      {Key? key,
      this.participants,
      required this.theatre,
      required this.userID})
      : super(key: key);

  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
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
      body: SafeArea(
        child: Column(
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
            //       Expanded(
            //         child: Text(
            //             "Participants requested to speak",
            //             style: TextStyle(
            //                 fontSize: 20
            //             )
            //         ),
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
                                      // AgoraUserEvents(cname: widget.theatre.title, uid: 123)
                                      //     .unMuteParticipant(widget.participants[index]['rtcId']);

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
                                          // await TheatreService().acceptParticipantAsSpeaker(
                                          //     widget.theatre.createdBy?? "",
                                          //     widget.theatre.theatreId?? "",
                                          //     widget.participants[index]['userName']
                                          // );
                                          await roomCollection
                                              .doc(widget.theatre.createdBy)
                                              .collection("amphitheatre")
                                              .doc(widget.theatre.theatreId)
                                              .collection('users')
                                              .doc(widget.participants[index]
                                                  ['userName'])
                                              .update({
                                            "role": 1,
                                            "requestToSpeak": false
                                          });
                                          Navigator.of(context).pop();
                                        });
                                        print('Send peer message success.');
                                      } catch (errorCode) {
                                        print('Send peer message error: ' +
                                            errorCode.toString());
                                      }
                                    },
                                    child: Text(
                                      "Accept",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontFamily: "drawerbody"),
                                    )),
                              ),
                              SizedBox(
                                width: 5,
                              ),

                              //decline make speaker request
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
                                              Colors.red),
                                    ),
                                    onPressed: () async {
                                      await roomCollection
                                          .doc(widget.theatre.createdBy)
                                          .collection("amphitheatre")
                                          .doc(widget.theatre.theatreId)
                                          .collection('users')
                                          .doc(widget.participants[index]
                                              ['userName'])
                                          .update({"requestToSpeak": false});
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Reject",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontFamily: "drawerbody"),
                                    )),
                              )
                            ],
                          ),
                        )
                      : SizedBox.shrink();
                }),
          ],
        ),
      ),
    );
  }
}
