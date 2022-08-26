import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OngoingRoomCard extends StatelessWidget with FostrTheme {
  final Room room;

  OngoingRoomCard({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user!;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          // height: MediaQuery.of(context).size.height * 0.25,
          constraints: BoxConstraints(maxHeight: 190, maxWidth: 360),
          decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: (room.imageUrl != null && room.imageUrl!.isNotEmpty)
                    ? FosterImageProvider(imageUrl: room.imageUrl!)
                    : Image.asset(IMAGES + "logo_white.png").image),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientBottom,
                gradientTop,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 5,
                color: Colors.black.withOpacity(0.25),
              )
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.9)
              ], begin: Alignment.centerRight, end: Alignment.centerLeft),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                // Align(
                //   alignment: Alignment.topRight,
                //   child: Container(
                //     height: 100,
                //     width: 100,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(20),
                //       image: DecorationImage(
                //           fit: BoxFit.cover,
                //           image: (room.imageUrl != null &&
                //                   room.imageUrl!.isNotEmpty)
                //               ? Image.network(room.imageUrl!).image
                //               : Image.asset(IMAGES + "logo_white.png").image),
                //     ),
                //   ),
                // ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        room.title.toString(),
                        style: TextStyle(
                            fontSize: 27,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=987&q=80'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://images.unsplash.com/photo-1488716820095-cbe80883c496?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=986&q=80'),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (room.speakersCount! < 0
                                    ? "0"
                                    : room.speakersCount.toString()),
                                style: h2.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {},
                      child: Text(
                        'Peek in',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w300),
                      ),
                      color: Color(0xff2A9D8F),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        (room.id == user.id)
            ? Positioned(
                right: 5,
                bottom: 0,
                child: IconButton(
                    icon: Icon(Icons.delete_outline_rounded),
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Material(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Do you really want to delete this room?",
                                        style: h1,
                                      ),
                                      Spacer(),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "No",
                                              style: h2.copyWith(
                                                color: Colors.black,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 40,
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              await roomCollection
                                                  .doc(user.id)
                                                  .collection('rooms')
                                                  .doc(room.title)
                                                  .delete();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Yes",
                                              style: h2.copyWith(
                                                color: Colors.black,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    }),
              )
            : Container(),
        // Positioned(
        //   right: 8,
        //   top: 20,
        //   child: BookmarkContainer(imgURL: room.imageUrl),
        // ),
      ],
    );
  }
}
//
// Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Row(
// mainAxisAlignment: MainAxisAlignment.start,
// children: [
// SvgPicture.asset(
// ICONS + "people.svg",
// height: 20,
// color: Colors.black54,
// ),
// SizedBox(
// width: 8,
// ),
// Text(
// (room.participantsCount! < 0
// ? "0"
// : room.participantsCount.toString()),
// style: h2.copyWith(
// color: Colors.black87,
// fontWeight: FontWeight.bold,
// ),
// ),
// SizedBox(
// width: 25,
// ),
// SvgPicture.asset(
// ICONS + "mic.svg",
// height: 20,
// color: Colors.black54,
// ),
// SizedBox(
// width: 8,
// ),
// Text(
// (room.speakersCount! < 0
// ? "0"
// : room.speakersCount.toString()),
// style: h2.copyWith(
// color: Colors.black87,
// fontWeight: FontWeight.bold,
// ),
// ),
// ],
// ),
// SizedBox(
// height: 5,
// ),
// Text(
// "by " + room.roomCreator.toString(),
// style: TextStyle(
// color: Colors.black87,
// fontSize: 11,
// fontFamily: "Lato",
// ),
// ),
// Spacer(),
// Text(
// room.title.toString(),
// style: h2.copyWith(
// color: Colors.black87, fontWeight: FontWeight.w700),
// ),
// SizedBox(
// height: 5,
// ),
// Text(
// room.agenda.toString(),
// style: TextStyle(
// fontSize: 12,
// color: Colors.black87,
// fontFamily: "Lato",
// ),
// overflow: TextOverflow.ellipsis,
// ),
// SizedBox(
// height: 5,
// ),
// Text(
// DateFormat('dd-MMM-yy (KK:mm) aa')
// .format(DateTime.parse(room.dateTime.toString())),
// style: TextStyle(
// fontSize: 15,
// color: Colors.black87,
// fontFamily: "Lato",
// ),
// overflow: TextOverflow.ellipsis,
// )
// ],
// ),