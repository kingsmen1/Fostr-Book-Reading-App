import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/core/functions.dart';
import 'package:fostr/enums/role_enum.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/RoomProvider.dart';
import 'package:fostr/services/AgoraService.dart';
import 'package:fostr/services/AudioPlayerService.dart';
import 'package:fostr/services/TheatreService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/theatre/TheatreRoom.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:fostr/widgets/rooms/Profile.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class TheatrePeekInPage extends StatefulWidget {
  final Theatre theatre;
  final String imageUrl, name;
  const TheatrePeekInPage(
      {Key? key,
      required this.theatre,
      required this.imageUrl,
      required this.name})
      : super(key: key);

  @override
  State<TheatrePeekInPage> createState() => _TheatrePeekInPageState();
}

class _TheatrePeekInPageState extends State<TheatrePeekInPage> {
  ClientRole role = ClientRole.Broadcaster;

  final TheatreService _theatreService = GetIt.I<TheatreService>();
  final AgoraService _agoraService = GetIt.I<AgoraService>();
  final AudioPlayerService _audioPlayerService = GetIt.I<AudioPlayerService>();
  late Future<QuerySnapshot<Map<String, dynamic>>>? roomSpeakers;

  late String userId;
  late String roomId;

  bool hostEntered = false;

  Event buildEvent(DateTime dateTime) {
    return Event(
      title: 'Foster Event : ${widget.theatre.title}',
      description: '',
      location: 'Foster Reads',
      startDate: dateTime,
      endDate: dateTime.add(Duration(minutes: 90)),
      iosParams: IOSParams(
          // reminder: Duration(minutes: 40),
          ),
      androidParams: AndroidParams(
          // emailInvites: ["test@example.com"],
          ),
    );
  }

  List specialUsers = [];
  List adminUsers = [];

  void getSpecialUsers() async {
    await FirebaseFirestore.instance
        .collection('special_users')
        .doc('admins')
        .get()
        .then((value){
      setState(() {
        adminUsers = value['admins'].toList();
      });
    });
    await FirebaseFirestore.instance
        .collection('special_users')
        .doc('users')
        .get()
        .then((value){
      setState(() {
        specialUsers = value['users'].toList();
      });
    });
    // print('func admins');
    // print(adminUsers);
    // print('func special users');
    // print(specialUsers);
  }

  @override
  void initState() {
    super.initState();
    userId = widget.theatre.createdBy!;
    roomId = widget.theatre.theatreId!;

    getSpecialUsers();

    roomSpeakers = FirebaseFirestore.instance
        .collection("rooms")
        .doc(userId)
        .collection("amphitheatre")
        .doc(roomId)
        .collection("users")
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final user = auth.user!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Stack(
        alignment: Alignment.center,
        children: [
          SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: widget.theatre.imageUrl == ''
                            ? Image.asset(IMAGES + "logo_black.png").image
                            : NetworkImage(
                                widget.theatre.imageUrl!
                                // .toString().replaceAll("https://firebasestorage.googleapis.com", "https://ik.imagekit.io/fostrreads")
                                ,
                              ),
                      ),
                      color: theme.colorScheme.primary,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.5)
                            ],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                      width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              shape: BoxShape.circle
                        ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    "${widget.theatre.title}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 28,
                                        color: Colors.white,
                                        fontFamily: "drawerhead"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                Expanded(
                    child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.03),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(100),
                        topEnd: Radius.circular(32),
                      ),
                      color: theme.colorScheme.primary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        !widget.theatre.isActive! && !widget.theatre.isUpcoming!
                            ? SizedBox(
                                height: 50,
                              )
                            : SizedBox.shrink(),

                        widget.theatre.isActive! && widget.theatre.isUpcoming!
                            ?
                            //upcoming, add to calender
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text(
                                      "Upcoming event",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color:
                                              theme.colorScheme.inversePrimary,
                                          fontFamily: "drawerhead"),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),

                        //share option
                        !widget.theatre.isActive! ||
                                (widget.theatre.scheduleOn!
                                        .toUtc()
                                        .subtract(Duration(minutes: 10))
                                        .isBefore(DateTime.now().toUtc()) &&
                                    widget.theatre.scheduleOn!
                                        .toUtc()
                                        .add(Duration(minutes: 90))
                                        .isBefore(DateTime.now().toUtc()))
                            ? SizedBox.shrink()
                            : StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                            .collection("rooms")
                            .doc(widget.theatre.createdBy)
                            .collection("amphitheatre")
                            .doc(widget.theatre.theatreId)
                            .snapshots(),
                              builder: (context, snapshot) {

                                if (!snapshot.hasData) {
                                  return SizedBox.shrink();
                                }

                                return snapshot.data!.get("isInviteOnly") ?
                                    SizedBox.shrink() :
                                auth.user!.id != widget.theatre.createdBy ?
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                // Opacity will become zero
                                                // if (!isInviteOnly) return;
                                                Share.share(await DynamicLinksApi
                                                    .inviteOnlyTheatreLink(
                                                  widget.theatre.theatreId!,
                                                  widget.theatre.createdBy!,
                                                  roomName: widget.theatre.title!,
                                                  imageUrl: widget.theatre.imageUrl,
                                                  creatorName: "",
                                                ));
                                              },
                                              child: Text(
                                                "Share Invite",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedOpacity(
                                        opacity: 1,
                                        duration: Duration(milliseconds: 300),
                                        child: GestureDetector(
                                          onTap: () async {
                                            Share.share(await DynamicLinksApi
                                                .inviteOnlyTheatreLink(
                                              widget.theatre.theatreId!,
                                              widget.theatre.createdBy!,
                                              roomName: widget.theatre.title!,
                                              imageUrl: widget.theatre.imageUrl,
                                              creatorName: "",
                                            ));
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                child: Center(
                                                  child: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,)
                                                  // Icon(
                                                  //   Icons.share_rounded,
                                                  // ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ) :
                                SizedBox.shrink();
                              }
                            ),

                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            "About the event",
                            style: TextStyle(fontFamily: "drawerbody"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            widget.theatre.summary ?? "",
                            style: TextStyle(fontFamily: "drawerbody"),
                          ),
                        ),

                        //share
                        auth.user!.id == widget.theatre.createdBy ?
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      // Opacity will become zero
                                      // if (!isInviteOnly) return;
                                      Share.share(await DynamicLinksApi
                                          .inviteOnlyTheatreLink(
                                        widget.theatre.theatreId!,
                                        widget.theatre.createdBy!,
                                        roomName: widget.theatre.title!,
                                        imageUrl: widget.theatre.imageUrl,
                                        creatorName: "",
                                      ));
                                    },
                                    child: Text(
                                      "Share Invite",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: 1,
                              duration: Duration(milliseconds: 300),
                              child: GestureDetector(
                                onTap: () async {
                                  Share.share(await DynamicLinksApi
                                      .inviteOnlyTheatreLink(
                                    widget.theatre.theatreId!,
                                    widget.theatre.createdBy!,
                                    roomName: widget.theatre.title!,
                                    imageUrl: widget.theatre.imageUrl,
                                    creatorName: "",
                                  ));
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      child: Center(
                                        child: SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,)
                                        // Icon(
                                        //   Icons.share_rounded,
                                        // ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ) :
                        SizedBox(),
                        Divider(),

                        //audience
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            "Audience",
                            style: TextStyle(fontFamily: "drawerbody"),
                          ),
                        ),
                        Container(
                          height: 200,
                          child: !widget.theatre.isActive! ||
                                  (widget.theatre.scheduleOn!
                                          .toUtc()
                                          .subtract(Duration(minutes: 10))
                                          .isBefore(DateTime.now().toUtc()) &&
                                      widget.theatre.scheduleOn!
                                          .toUtc()
                                          .add(Duration(minutes: 90))
                                          .isBefore(DateTime.now().toUtc()))
                              ? FutureBuilder(
                                  future: roomSpeakers,
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                          snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container();
                                    }

                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Text(
                                          "",
                                        ),
                                      );
                                    }

                                    if (snapshot.data?.size == 0) {
                                      return Center(
                                        child: Text(
                                          "There were no speakers",
                                        ),
                                      );
                                    }
                                    final data = snapshot.data!.docs
                                        .map((element) => element.data())
                                        .toList();
                                    return Flexible(
                                      child: GridView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3),
                                        itemCount: data.length,
                                        padding: EdgeInsets.all(2.0),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Profile(
                                              user: User.fromJson(data[index]),
                                              size: 60,
                                              isMute: false,
                                              volume: 0,
                                              myVolume: 0);
                                        },
                                      ),
                                    );
                                  })
                              : StreamBuilder<
                                      QuerySnapshot<Map<String, dynamic>>>(
                                  stream: roomCollection
                                      .doc(widget.theatre.createdBy)
                                      .collection("amphitheatre")
                                      .doc(widget.theatre.theatreId)
                                      .collection('users')
                                      .where("isActiveInRoom", isEqualTo: true)
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<
                                              QuerySnapshot<
                                                  Map<String, dynamic>>>
                                          snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data!.docs.length == 0) {
                                      return Align(
                                        child: Text(
                                          "No speakers yet!",
                                          style: TextStyle(
                                              fontFamily: "drawerbody"),
                                        ),
                                        alignment: Alignment.topCenter,
                                      );
                                    } else if (snapshot.hasData) {
                                      List<
                                              QueryDocumentSnapshot<
                                                  Map<String, dynamic>>> map =
                                          snapshot.data!.docs;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 25),
                                        child: GridView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3),
                                          itemCount: map.length ,
                                          padding: EdgeInsets.all(2.0),
                                          itemBuilder: (BuildContext context,
                                              int index) {


                                            return Profile(
                                                user: User.fromJson(
                                                    map[index].data()),
                                                size: 60,
                                                isMute: false,
                                                volume: 0,
                                                myVolume: 0);
                                          },
                                        ),
                                      );
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  }),
                        ),

                        //add bots
                        adminUsers.contains(auth.user!.id) ?
                        // auth.user!.id == "tlMTZ9Wt9iRgojhFqOkEP7yDmVe2" ?
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(

                                      onTap: () async {
                                        User bot1, bot2, bot3, bot4, bot5, bot6;

                                        UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value1){ //sarahreads "G76B9y4G4TQaYH2MzLF4wuWrEbF3"
                                          bot1 = value1!;
                                          UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value2){ //mitesh14 "Gfqvx3GZg2YVkfaqoe7DM57Iilu1"
                                            bot2 = value2!;
                                            UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value3){ //renuraj "9Awa0HRhQIPcufxpY0f1qu5xq0O2"
                                              bot3 = value3!;
                                              UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value4){ //youngmike "Ej1R25VETWZ5PaUeZaIXhoRHp5J2"
                                                bot4 = value4!;
                                                UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value5){ //monica "5ai2yEOuWSZuxIlwpEeFkcOuQxx2"
                                                  bot5 = value5!;
                                                  UserService().getUserById((specialUsers.toList()..shuffle()).first).then((value6){ //amarsdiary "BtMUYkEIiabkGsUSRFEqMCwj0703"
                                                    bot6 = value6!;

                                                    _theatreService.joinRoomAsSpeaker(widget.theatre, bot1, Role.Participant);
                                                    _theatreService.joinRoomAsSpeaker(widget.theatre, bot2, Role.Participant);
                                                    _theatreService.joinRoomAsSpeaker(widget.theatre, bot3, Role.Participant);
                                                    _theatreService.joinRoomAsSpeaker(widget.theatre, bot4, Role.Participant);
                                                    _theatreService.joinRoomAsSpeaker(widget.theatre, bot5, Role.Participant);
                                                    _theatreService.joinRoomAsSpeaker(widget.theatre, bot6, Role.Participant);

                                                  });
                                                });
                                              });
                                            });
                                          });
                                        });

                                      },

                                      child: Container(
                                        width: 150,
                                        height: 30,
                                        color: Colors.grey,
                                        child: Center(
                                          child: Text("Add Bots 1",style: TextStyle(color: Colors.black),),
                                        ),
                                      ),
                                    ),
                                    // GestureDetector(
                                    //
                                    //   onTap: () async {
                                    //     User bot1, bot2, bot3, bot4, bot5, bot6;
                                    //
                                    //     UserService().getUserById("ra30ZrxbUig7IPgr7ovvTOP6gf22").then((value1){ //alanthomas
                                    //       bot1 = value1!;
                                    //       UserService().getUserById("0K9KDvJMQcP4dnOU5YIX1MWCxi12").then((value2){ //himani
                                    //         bot2 = value2!;
                                    //         UserService().getUserById("gOGf6tdFfedwnN3c1qxsmecNMw02").then((value3){ //shubham_23
                                    //           bot3 = value3!;
                                    //           UserService().getUserById("sMxK4h5CTuSgEI5YVxa5lCNj6TI3").then((value4){ //rashijain
                                    //             bot4 = value4!;
                                    //             UserService().getUserById("49j0Qyy6O4fzNjimR0T18Xc4Z9l1").then((value5){ //yash001
                                    //               bot5 = value5!;
                                    //               UserService().getUserById("BhnsIZl3dsW3cNKyllhWNoWxFDV2").then((value6){ //sara
                                    //                 bot6 = value6!;
                                    //
                                    //                 _theatreService.joinRoomAsSpeaker(widget.theatre, bot1, Role.Participant);
                                    //                 _theatreService.joinRoomAsSpeaker(widget.theatre, bot2, Role.Participant);
                                    //                 _theatreService.joinRoomAsSpeaker(widget.theatre, bot3, Role.Participant);
                                    //                 _theatreService.joinRoomAsSpeaker(widget.theatre, bot4, Role.Participant);
                                    //                 _theatreService.joinRoomAsSpeaker(widget.theatre, bot5, Role.Participant);
                                    //                 _theatreService.joinRoomAsSpeaker(widget.theatre, bot6, Role.Participant);
                                    //
                                    //               });
                                    //             });
                                    //           });
                                    //         });
                                    //       });
                                    //     });
                                    //
                                    //   },
                                    //
                                    //   child: Container(
                                    //     width: 100,
                                    //     height: 30,
                                    //     color: Colors.grey,
                                    //     child: Center(
                                    //       child: Text("Add Bots 2",style: TextStyle(color: Colors.black),),
                                    //     ),
                                    //   ),
                                    // )
                                  ]
                                ),
                                // SizedBox(height: 5,),
                                // Row(
                                //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                //     children: [
                                //       GestureDetector(
                                //
                                //         onTap: () async {
                                //           User bot1, bot2, bot3, bot4, bot5, bot6;
                                //
                                //           UserService().getUserById("zi5IGrlVEahPwL0TtrOv8Juf0ok2").then((value1){ //sumit
                                //             bot1 = value1!;
                                //             UserService().getUserById("3mu3VZEHk9gUenep0Efk0cBJUgS2").then((value2){ //snehak
                                //               bot2 = value2!;
                                //               UserService().getUserById("maCAcXKYvVQF7LpkGtlREttsBmy1").then((value3){ //meerareads
                                //                 bot3 = value3!;
                                //                 UserService().getUserById("1mYKKbntWsWPTljTHI4qzFHVWa93").then((value4){ //RakeshR
                                //                   bot4 = value4!;
                                //                   UserService().getUserById("YKkcHAJvi1R1dqYXelbMWOyI6vY2").then((value5){ //samv
                                //                     bot5 = value5!;
                                //                     UserService().getUserById("bPr1oURIlONvI8ny94GAtQ1qSG03").then((value6){ //eforeshaan
                                //                       bot6 = value6!;
                                //
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot1, Role.Participant);
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot2, Role.Participant);
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot3, Role.Participant);
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot4, Role.Participant);
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot5, Role.Participant);
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot6, Role.Participant);
                                //
                                //                     });
                                //                   });
                                //                 });
                                //               });
                                //             });
                                //           });
                                //
                                //         },
                                //
                                //         child: Container(
                                //           width: 100,
                                //           height: 30,
                                //           color: Colors.grey,
                                //           child: Center(
                                //             child: Text("Add Bots 3",style: TextStyle(color: Colors.black),),
                                //           ),
                                //         ),
                                //       ),
                                //       GestureDetector(
                                //
                                //         onTap: () async {
                                //           User bot1, bot2, bot3, bot4, bot5, bot6;
                                //
                                //           UserService().getUserById("RgcbGtHgqWeQXndtCl2sw5YdCXe2").then((value1){ //goelarman
                                //             bot1 = value1!;
                                //             UserService().getUserById("eGLr0oho39MXXcPdVYMnQ3j4gVH3").then((value2){ //jenny_t
                                //               bot2 = value2!;
                                //               UserService().getUserById("XiFifJUvMMaaLOLbkLbBfXYXLg52").then((value3){ //riya
                                //                 bot3 = value3!;
                                //                 UserService().getUserById("TAzNRayWOgXEfu20OphCAUl3KMj2").then((value4){ //r.k
                                //                   bot4 = value4!;
                                //                   UserService().getUserById("bFbSoVCzroOtXmg1uUu8YEDOWtH2").then((value5){ //akritic
                                //                     bot5 = value5!;
                                //                     UserService().getUserById("AwlT2XWps7UpIxgOp6lQ5jnlLme2").then((value6){ //deepansh
                                //                       bot6 = value6!;
                                //
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot1, Role.Participant);
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot2, Role.Participant);
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot3, Role.Participant);
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot4, Role.Participant);
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot5, Role.Participant);
                                //                       _theatreService.joinRoomAsSpeaker(widget.theatre, bot6, Role.Participant);
                                //
                                //                     });
                                //                   });
                                //                 });
                                //               });
                                //             });
                                //           });
                                //
                                //         },
                                //
                                //         child: Container(
                                //           width: 100,
                                //           height: 30,
                                //           color: Colors.grey,
                                //           child: Center(
                                //             child: Text("Add Bots 4",style: TextStyle(color: Colors.black),),
                                //           ),
                                //         ),
                                //       )
                                //     ]
                                // ),
                              ],
                            )
                            : SizedBox.shrink(),
                        auth.user!.id == "tlMTZ9Wt9iRgojhFqOkEP7yDmVe2" ?
                        SizedBox(
                          height: 20,
                        )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ))
              ],
            ),
          ),
          Positioned(
            top: 350.0, // (background container size) - (circle height / 2)
            child: RoundedImage(
              width: 110,
              height: 110,
              borderRadius: 35,
              url: widget.imageUrl
              // .toString().replaceAll("https://firebasestorage.googleapis.com", "https://ik.imagekit.io/fostrreads")
              ,
            ),
          )
        ],
      ),
      floatingActionButton: widget.theatre.isActive! &&
              widget.theatre.isUpcoming!
          ?
          //upcoming, add to calender
          MaterialButton(
              padding:
                  EdgeInsets.only(top: 15, bottom: 15, left: 50, right: 50),
              onPressed: () async {
                Add2Calendar.addEvent2Cal(
                    buildEvent(widget.theatre.scheduleOn!));
              },
              child: Text(
                'Add to calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              color: theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            )
          : widget.theatre.isActive!
              ?
      // widget.theatre.scheduleOn!
      //                     .toUtc()
      //                     .subtract(Duration(minutes: 10))
      //                     .isBefore(DateTime.now().toUtc()) &&
                      widget.theatre.scheduleOn!
                          .toUtc()
                          .add(Duration(minutes: 90))
                          .isBefore(DateTime.now().toUtc())
                  ?

                  //finished
                  MaterialButton(
                      padding: EdgeInsets.only(
                          top: 15, bottom: 15, left: 50, right: 50),
                      onPressed: () async {},
                      child: Text(
                        'Event finished',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      color: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    )
                  :
                  //join button
                  MaterialButton(
                      padding: EdgeInsets.only(
                          top: 15, bottom: 15, left: 50, right: 50),
                      onPressed: () async {


                        if(auth.user!.id == widget.theatre.createdBy) {

                          await FirebaseFirestore.instance
                              .collection("rooms")
                              .doc(widget.theatre.createdBy)
                              .collection("amphitheatre")
                              .where("hostEntered", isEqualTo: true)
                              .where("theatreId", isEqualTo: widget.theatre.theatreId)
                              .limit(1)
                              .get()
                          .then((value) async {

                            ///when host joins back after leaving
                            if(value.docs.length == 1){
                              await roomCollection
                                  .doc(widget.theatre.createdBy)
                                  .collection("amphitheatre")
                                  .doc(widget.theatre.theatreId)
                                  .collection('users')
                                  .get()
                                  .then((value) async {
                                List users = [];
                                value.docs.forEach((element) {
                                  users.add(element.id);
                                });
                                if(users.indexOf(auth.user!.userName)>-1){

                                  await roomCollection
                                      .doc(widget.theatre.createdBy)
                                      .collection("amphitheatre")
                                      .doc(widget.theatre.theatreId)
                                      .collection('users')
                                      .doc(auth.user!.userName)
                                      .get()
                                      .then((value) async {
                                    if(value['isKickedOut']){
                                      ToastMessege(
                                        "You have already been kicked out of this theatre.",
                                        context: context,
                                      );
                                    }
                                    else {
                                      var role = (user.id == widget.theatre.createdBy)
                                          ? Role.Host
                                          : Role.Participant;
                                      print(role);

                                      if (audioPlayerData.mediaMeta.audioId !=
                                          widget.theatre.theatreId) {
                                        await FirebaseFirestore.instance
                                            .collection("rooms")
                                            .doc(widget.theatre.createdBy)
                                            .collection("amphitheatre")
                                            .doc(widget.theatre.theatreId)
                                            .get()
                                        .then((value) async {

                                          _theatreService.getTheatreById(
                                          value['theatreId'], value['createdBy']
                                          ).then((theatre) async {

                                            roomProvider.setTheatre(
                                                Theatre.fromJson(value.data(), ""), user);
                                            _audioPlayerService.release();
                                            audioPlayerData.setMediaMeta(
                                              MediaMeta(
                                                audioId: value['theatreId'],
                                                audioName: value['title'],
                                                userName: value['creatorUsername'],
                                                mediaType: MediaType.theatres,
                                                rawData: value.data(),
                                              ),
                                              shouldNotify: true,
                                            );
                                            if (user.id == Theatre.fromJson(value.data(), "").createdBy) {
                                              await _theatreService.joinRoomAsSpeaker(
                                                  Theatre.fromJson(value.data(), ""), user, Role.Host);
                                              _agoraService.engine
                                                  ?.setClientRole(ClientRole.Broadcaster);
                                            }
                                            else {
                                              await _theatreService.joinRoomAsSpeaker(
                                                  Theatre.fromJson(value.data(), ""), user, Role.Participant);
                                              _agoraService.engine
                                                  ?.setClientRole(ClientRole.Audience);
                                            }
                                            print("line 591 ${value['token']}");
                                            await _agoraService.joinChannel(
                                                value['token'],
                                                value['theatreId']);
                                            Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) => Scaffold(
                                                    body: TheatreRoom(
                                                      role: role,
                                                      theatre: Theatre.fromJson(value.data(), ""),
                                                    )),
                                              ),
                                            );
                                          });
                                        });
                                      }
                                    }
                                  });

                                }
                                else {
                                  var role = (user.id == widget.theatre.createdBy)
                                      ? Role.Host
                                      : Role.Participant;
                                  print(role);

                                  if (audioPlayerData.mediaMeta.audioId !=
                                      widget.theatre.theatreId) {
                                    await FirebaseFirestore.instance
                                        .collection("rooms")
                                        .doc(widget.theatre.createdBy)
                                        .collection("amphitheatre")
                                        .doc(widget.theatre.theatreId)
                                        .get()
                                        .then((value) async {

                                      _theatreService.getTheatreById(
                                          value['theatreId'], value['createdBy']
                                      ).then((theatre) async {
                                        roomProvider.setTheatre(
                                            Theatre.fromJson(value.data(), ""), user);
                                        _audioPlayerService.release();
                                        audioPlayerData.setMediaMeta(
                                          MediaMeta(
                                            audioId: value['theatreId'],
                                            audioName: value['title'],
                                            userName: value['creatorUsername'],
                                            mediaType: MediaType.theatres,
                                            rawData: value.data(),
                                          ),
                                          shouldNotify: true,
                                        );
                                        if (user.id == Theatre.fromJson(value.data(), "").createdBy) {
                                          await _theatreService.joinRoomAsSpeaker(
                                              Theatre.fromJson(value.data(), ""), user, Role.Host);
                                          _agoraService.engine
                                              ?.setClientRole(ClientRole.Broadcaster);
                                        }
                                        else {
                                          await _theatreService.joinRoomAsSpeaker(
                                              Theatre.fromJson(value.data(), ""), user, Role.Participant);
                                          _agoraService.engine
                                              ?.setClientRole(ClientRole.Audience);
                                        }
                                        print("line 655 ${value['token']}");
                                        await _agoraService.joinChannel(
                                            value['token'],
                                            value['theatreId']);
                                        Navigator.pushReplacement(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) => Scaffold(
                                                body: TheatreRoom(
                                                  role: role,
                                                  theatre: Theatre.fromJson(value.data(), ""),
                                                )),
                                          ),
                                        );
                                      });
                                    });
                                  }
                                }
                              });
                            }
                            else {
                              print('host entering first time');
                              ///when host enters first time
                              await FirebaseFirestore.instance
                                  .collection("rooms")
                                  .doc(widget.theatre.createdBy)
                                  .collection("amphitheatre")
                                  .doc(widget.theatre.theatreId)
                                  .get()
                                  .then((theatre){
                                    print("--------------------------------------------------");
                                    print(theatre['theatreId']);
                                    print("--------------------------------------------------");
                                  getRTCToken(theatre['theatreId'])
                                    .then((rtcToken) async {
                                  await FirebaseFirestore.instance
                                    .collection("rooms")
                                    .doc(widget.theatre.createdBy)
                                    .collection("amphitheatre")
                                    .doc(widget.theatre.theatreId)
                                    .set({
                                  'token' : rtcToken,
                                  'hostEntered' : true
                                }, SetOptions(merge: true)).then((value) async {
                                  await roomCollection
                                      .doc(widget.theatre.createdBy)
                                      .collection("amphitheatre")
                                      .doc(widget.theatre.theatreId)
                                      .collection('users')
                                      .get()
                                      .then((value) async {
                                    List users = [];
                                    value.docs.forEach((element) {
                                      users.add(element.id);
                                    });
                                    if(users.indexOf(auth.user!.userName)>-1){

                                      await roomCollection
                                          .doc(widget.theatre.createdBy)
                                          .collection("amphitheatre")
                                          .doc(widget.theatre.theatreId)
                                          .collection('users')
                                          .doc(auth.user!.userName)
                                          .get()
                                          .then((value) async {
                                        if(value['isKickedOut']){
                                          ToastMessege(
                                            "You have already been kicked out of this theatre.",
                                            context: context,
                                          );
                                        }
                                        else {
                                          var role = (user.id == widget.theatre.createdBy)
                                              ? Role.Host
                                              : Role.Participant;
                                          print(role);

                                          if (audioPlayerData.mediaMeta.audioId !=
                                              widget.theatre.theatreId) {
                                            await FirebaseFirestore.instance
                                                .collection("rooms")
                                                .doc(widget.theatre.createdBy)
                                                .collection("amphitheatre")
                                                .doc(widget.theatre.theatreId)
                                                .get()
                                                .then((value) async {

                                              _theatreService.getTheatreById(
                                                  value['theatreId'], value['createdBy']
                                              ).then((theatre) async {
                                                roomProvider.setTheatre(
                                                    Theatre.fromJson(value.data(), ""), user);
                                                _audioPlayerService.release();
                                                audioPlayerData.setMediaMeta(
                                                  MediaMeta(
                                                    audioId: value['theatreId'],
                                                    audioName: value['title'],
                                                    userName: value['creatorUsername'],
                                                    mediaType: MediaType.theatres,
                                                    rawData: value.data(),
                                                  ),
                                                  shouldNotify: true,
                                                );
                                                if (user.id == Theatre.fromJson(value.data(), "").createdBy) {
                                                  await _theatreService.joinRoomAsSpeaker(
                                                      Theatre.fromJson(value.data(), ""), user, Role.Host);
                                                  _agoraService.engine
                                                      ?.setClientRole(ClientRole.Broadcaster);
                                                }
                                                else {
                                                  await _theatreService.joinRoomAsSpeaker(
                                                      Theatre.fromJson(value.data(), ""), user, Role.Participant);
                                                  _agoraService.engine
                                                      ?.setClientRole(ClientRole.Audience);
                                                }
                                                print("line 766 ${value['token']}");
                                                await _agoraService.joinChannel(
                                                  rtcToken,
                                                    // value['token'],
                                                    value['theatreId']);
                                                Navigator.pushReplacement(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) => Scaffold(
                                                        body: TheatreRoom(
                                                          role: role,
                                                          theatre: Theatre.fromJson(value.data(), ""),
                                                        )),
                                                  ),
                                                );
                                              });
                                            });
                                          }
                                        }
                                      });

                                    }
                                    else {
                                      var role = (user.id == widget.theatre.createdBy)
                                          ? Role.Host
                                          : Role.Participant;
                                      print(role);

                                      if (audioPlayerData.mediaMeta.audioId !=
                                          widget.theatre.theatreId) {
                                        await FirebaseFirestore.instance
                                            .collection("rooms")
                                            .doc(widget.theatre.createdBy)
                                            .collection("amphitheatre")
                                            .doc(widget.theatre.theatreId)
                                            .get()
                                            .then((value) async {

                                          _theatreService.getTheatreById(
                                              value['theatreId'], value['createdBy']
                                          ).then((theatre) async {
                                            roomProvider.setTheatre(
                                                Theatre.fromJson(value.data(), ""), user);
                                            _audioPlayerService.release();
                                            audioPlayerData.setMediaMeta(
                                              MediaMeta(
                                                audioId: value['theatreId'],
                                                audioName: value['title'],
                                                userName: value['creatorUsername'],
                                                mediaType: MediaType.theatres,
                                                rawData: value.data(),
                                              ),
                                              shouldNotify: true,
                                            );
                                            if (user.id == Theatre.fromJson(value.data(), "").createdBy) {
                                              await _theatreService.joinRoomAsSpeaker(
                                                  Theatre.fromJson(value.data(), ""), user, Role.Host);
                                              _agoraService.engine
                                                  ?.setClientRole(ClientRole.Broadcaster);
                                            }
                                            else {
                                              await _theatreService.joinRoomAsSpeaker(
                                                  Theatre.fromJson(value.data(), ""), user, Role.Participant);
                                              _agoraService.engine
                                                  ?.setClientRole(ClientRole.Audience);
                                            }
                                            print("line 831 ${value['token']}");
                                            await _agoraService.joinChannel(
                                              rtcToken,
                                                // value['token'],
                                                value['theatreId']);
                                            Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) => Scaffold(
                                                    body: TheatreRoom(
                                                      role: role,
                                                      theatre: Theatre.fromJson(value.data(), ""),
                                                    )),
                                              ),
                                            );
                                          });
                                        });
                                      }
                                    }
                                  });
                                });
                              });
    });
                            }
                          });

                        } else {

                          ///users entering
                          await FirebaseFirestore.instance
                              .collection("rooms")
                              .doc(widget.theatre.createdBy)
                              .collection("amphitheatre")
                              .where("hostEntered", isEqualTo: true)
                              .where("theatreId", isEqualTo: widget.theatre.theatreId)
                              .limit(1)
                              .get()
                              .then((value) async {

                            ///host already entered
                            if(value.docs.length == 1){
                              setState(() {
                                hostEntered = true;
                              });
                              await roomCollection
                                  .doc(widget.theatre.createdBy)
                                  .collection("amphitheatre")
                                  .doc(widget.theatre.theatreId)
                                  .collection('users')
                                  .get()
                                  .then((value) async {
                                List users = [];
                                value.docs.forEach((element) {
                                  users.add(element.id);
                                });
                                if(users.indexOf(auth.user!.userName)>-1){

                                  await roomCollection
                                      .doc(widget.theatre.createdBy)
                                      .collection("amphitheatre")
                                      .doc(widget.theatre.theatreId)
                                      .collection('users')
                                      .doc(auth.user!.userName)
                                      .get()
                                      .then((value) async {
                                    if(value['isKickedOut']){
                                      ToastMessege(
                                        "You have already been kicked out of this theatre.",
                                        context: context,
                                      );
                                    }
                                    else {
                                      var role = (user.id == widget.theatre.createdBy)
                                          ? Role.Host
                                          : Role.Participant;
                                      print(role);

                                      if (audioPlayerData.mediaMeta.audioId !=
                                          widget.theatre.theatreId) {
                                        await FirebaseFirestore.instance
                                            .collection("rooms")
                                            .doc(widget.theatre.createdBy)
                                            .collection("amphitheatre")
                                            .doc(widget.theatre.theatreId)
                                            .get()
                                            .then((value) async {

                                          _theatreService.getTheatreById(
                                              value['theatreId'], value['createdBy']
                                          ).then((theatre) async {
                                            roomProvider.setTheatre(
                                                Theatre.fromJson(value.data(), ""), user);
                                            _audioPlayerService.release();
                                            audioPlayerData.setMediaMeta(
                                              MediaMeta(
                                                audioId: value['theatreId'],
                                                audioName: value['title'],
                                                userName: value['creatorUsername'],
                                                mediaType: MediaType.theatres,
                                                rawData: value.data(),
                                              ),
                                              shouldNotify: true,
                                            );
                                            if (user.id == Theatre.fromJson(value.data(), "").createdBy) {
                                              await _theatreService.joinRoomAsSpeaker(
                                                  Theatre.fromJson(value.data(), ""), user, Role.Host);
                                              _agoraService.engine
                                                  ?.setClientRole(ClientRole.Broadcaster);
                                            }
                                            else {
                                              await _theatreService.joinRoomAsSpeaker(
                                                  Theatre.fromJson(value.data(), ""), user, Role.Participant);
                                              _agoraService.engine
                                                  ?.setClientRole(ClientRole.Audience);
                                            }
                                            print("line 945 ${value['token']}");
                                            await _agoraService.joinChannel(
                                                value['token'],
                                                value['theatreId']);
                                            Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) => Scaffold(
                                                    body: TheatreRoom(
                                                      role: role,
                                                      theatre: Theatre.fromJson(value.data(), ""),
                                                    )),
                                              ),
                                            );
                                          });
                                        });
                                      }
                                    }
                                  });

                                }
                                else {
                                  var role = (user.id == widget.theatre.createdBy)
                                      ? Role.Host
                                      : Role.Participant;
                                  print(role);

                                  if (audioPlayerData.mediaMeta.audioId !=
                                      widget.theatre.theatreId) {
                                    await FirebaseFirestore.instance
                                        .collection("rooms")
                                        .doc(widget.theatre.createdBy)
                                        .collection("amphitheatre")
                                        .doc(widget.theatre.theatreId)
                                        .get()
                                        .then((value) async {

                                      _theatreService.getTheatreById(
                                          value['theatreId'], value['createdBy']
                                      ).then((theatre) async {
                                        roomProvider.setTheatre(
                                            Theatre.fromJson(value.data(), ""), user);
                                        _audioPlayerService.release();
                                        audioPlayerData.setMediaMeta(
                                          MediaMeta(
                                            audioId: value['theatreId'],
                                            audioName: value['title'],
                                            userName: value['creatorUsername'],
                                            mediaType: MediaType.theatres,
                                            rawData: value.data(),
                                          ),
                                          shouldNotify: true,
                                        );
                                        if (user.id == Theatre.fromJson(value.data(), "").createdBy) {
                                          await _theatreService.joinRoomAsSpeaker(
                                              Theatre.fromJson(value.data(), ""), user, Role.Host);
                                          _agoraService.engine
                                              ?.setClientRole(ClientRole.Broadcaster);
                                        }
                                        else {
                                          await _theatreService.joinRoomAsSpeaker(
                                              Theatre.fromJson(value.data(), ""), user, Role.Participant);
                                          _agoraService.engine
                                              ?.setClientRole(ClientRole.Audience);
                                        }
                                        print("line 1009 ${value['token']}");
                                        await _agoraService.joinChannel(
                                            value['token'],
                                            value['theatreId']);
                                        Navigator.pushReplacement(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) => Scaffold(
                                                body: TheatreRoom(
                                                  role: role,
                                                  theatre: Theatre.fromJson(value.data(), ""),
                                                )),
                                          ),
                                        );
                                      });
                                    });
                                  }
                                }
                              });
                            }
                            else {
                              ToastMessege("Please wait until the host enters the theatre.", context: context);
                              setState(() {
                                hostEntered = false;
                              });
                            }
                          });
                        }


                      },
                      child: auth.user!.id == widget.theatre.createdBy ?
                      Text('Join Theatre', style: TextStyle(color: Colors.white)) :
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("rooms")
                              .doc(widget.theatre.createdBy)
                              .collection("amphitheatre")
                              .doc(widget.theatre.theatreId)
                              .snapshots(),
                          builder: (context, snapshot) {

                            if(!snapshot.hasData){
                              return Container();
                            }

                            try {
                              if (snapshot
                                  .data?['hostEntered']) {
                                return Text('Join Theatre',
                                    style: TextStyle(
                                        color: Colors
                                            .white));
                              } else {
                                return Text(
                                  'Waiting for the host to join in.',
                                  style: TextStyle(
                                      color: Colors
                                          .white),);
                              }
                            } catch (e) {
                              return Text(
                                'Waiting for the host to join in.',
                                style: TextStyle(
                                    color: Colors.white),);
                            }

                            }
                      ),
                      color: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    )
              :

              //theatre deleted
              MaterialButton(
                  padding:
                      EdgeInsets.only(top: 15, bottom: 15, left: 50, right: 50),
                  onPressed: () async {},
                  child: Text(
                    'Event deleted',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  color: theme.colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
    // Scaffold(
    //   backgroundColor: theme.colorScheme.primary,
    //   body: SafeArea(
    //     child: Container(
    //       width: MediaQuery.of(context).size.width,
    //       height: MediaQuery.of(context).size.height,
    //       color: Colors.transparent,
    //       child: Column(
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.symmetric(horizontal: 20),
    //             child: Container(
    //               width: MediaQuery.of(context).size.width,
    //               height: 30,
    //               child: Row(
    //                 children: [
    //                   IconButton(
    //                       onPressed: () {
    //                         Navigator.of(context).pop();
    //                       },
    //                       icon: Icon(
    //                         Icons.arrow_back_ios,
    //                         color: theme.colorScheme.inversePrimary,
    //                       )),
    //                 ],
    //               ),
    //             ),
    //           ),
    //           SizedBox(height: 100,),
    //
    //           Container(
    //             width: 150,
    //             height: 150,
    //             decoration: BoxDecoration(
    //               color: Colors.transparent,
    //               border: Border.all(color: theme.colorScheme.secondary, width: 1),
    //               shape: BoxShape.circle
    //             ),
    //             child: Center(
    //               child: Image.asset("assets/images/logo.png", width: 100, height: 100,),
    //             ),
    //           ),
    //
    //           SizedBox(height: 100,),
    //
    //           Text("This theatre is inactive",
    //             style: TextStyle(
    //                 color: Colors.grey,
    //                 fontSize: 14,
    //                 fontFamily: "drawerbody",
    //                 fontStyle: FontStyle.italic),
    //           ),
    //
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
