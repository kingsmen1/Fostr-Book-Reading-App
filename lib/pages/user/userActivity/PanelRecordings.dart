import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:share_plus/share_plus.dart';

import 'UserRecordings.dart';

class PanelRecordingTile extends StatefulWidget {
  final Map<dynamic, dynamic> roomData;
  final Map<dynamic, dynamic> recordingData;
  final bool showShare;
  const PanelRecordingTile({
    Key? key,
    required this.roomData,
    required this.recordingData,
    this.showShare = true,
  }) : super(key: key);

  @override
  State<PanelRecordingTile> createState() => _PanelRecordingTileState();
}

class _PanelRecordingTileState extends State<PanelRecordingTile> {
  late String userId;
  late String roomId;
  late String type;

  static const DEFAULT_IMAGE =
      "https://static.wixstatic.com/media/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png/v1/fill/w_1920,h_1080,al_c/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png";

  @override
  void initState() {
    super.initState();
    print(widget.roomData['id']);
    userId = widget.roomData["id"];
    roomId = widget.roomData["roomID"];
    type = widget.recordingData["type"];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final data = widget.roomData;
    return Container(
      constraints: BoxConstraints(minHeight: 200),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: size.width,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 70,
              ),
              Text(
                data["title"] ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "drawerbody"),
              ),
              data["authorName"] != null && data["authorName"] != ""
                  ? SizedBox(
                      height: 10,
                    )
                  : SizedBox.shrink(),
              Text(
                data["authorName"] != null && data["authorName"] != ""
                    ? "By " + data["authorName"]
                    : "",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: "drawerbody"),
              ),
              data["authorName"] != null && data["authorName"] != ""
                  ? SizedBox(
                      height: 10,
                    )
                  : SizedBox.shrink(),
              SizedBox.shrink(),
              Container(
                height: 100,
                width: 100,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: theme.colorScheme.inversePrimary, width: 3),
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FosterImageProvider(
                      imageUrl: data["image"] != ""
                          ? data["image"]
                          : DEFAULT_IMAGE,
                    ),
                    fit: BoxFit.contain,
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 10),
                      blurRadius: 10,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ],
                ),
              ),
              Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: RecordingTile(
                    duration: widget.recordingData["duration"] ?? 0,
                    roomId: roomId,
                    userId: userId,
                    recordingId: widget.recordingData["fileName"],
                    recordingDocId: widget.recordingData["id"],
                    roomData: data,
                    recordingData: widget.recordingData,
                  ),
                )
              ]),
            ],
          ),
          (!widget.showShare)
              ? Align(
                  alignment: Alignment.topLeft,
                  child: (IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                    ),
                  )),
                )
              : SizedBox.shrink(),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () async {
                final url = await DynamicLinksApi.fosterPodsLink(
                  widget.recordingData["id"],
                  roomName: data["title"] ?? "",
                );
                Share.share(url);
              },
              icon: SvgPicture.asset("assets/icons/blue_share.svg"),
              // Icon(Icons.share),
            ),
          )
        ],
      ),
    );
  }
}

class RecordingTile extends StatefulWidget {
  final String roomId;
  final String userId;
  final String recordingId;
  final int? duration;
  final String recordingDocId;
  final Map<dynamic, dynamic>? recordingData;
  final Map<dynamic, dynamic>? roomData;
  const RecordingTile(
      {Key? key,
      required this.roomId,
      required this.userId,
      required this.recordingId,
      required this.duration,
      required this.recordingDocId,
      required this.recordingData,
      required this.roomData})
      : super(key: key);

  @override
  State<RecordingTile> createState() => _RecordingTileState();
}

class _RecordingTileState extends State<RecordingTile> {
  @override
  Widget build(BuildContext context) {
    return RecordingPlayer(
      rawData: {
        "roomData": widget.roomData,
        "recordingData": widget.recordingData,
      },
      fileName: widget.recordingId,
      duration: widget.duration,
      onDurationFetched: (duration) {
        FirebaseFirestore.instance
            .collection("recordings")
            .doc(widget.recordingDocId)
            .update({"duration": duration?.inSeconds});
      },
    );
  }
}