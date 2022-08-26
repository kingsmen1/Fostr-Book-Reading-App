import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' show ByteData, Excel, rootBundle;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/albums/EnterAlbumDetails.dart';
import 'package:fostr/albums/AlbumPage.dart';
import 'package:fostr/albums/PodcastPage.dart';
import 'package:fostr/core/constants.dart';

import 'package:fostr/core/data.dart';
import 'package:fostr/enums/search_enum.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/bookClub/dashboard.dart';
import 'package:fostr/pages/onboarding/LoginPage.dart';

import 'package:fostr/pages/rooms/ThemePage.dart';
import 'package:fostr/pages/user/AllLandingPage.dart';
import 'package:fostr/pages/user/CalendarPage.dart';
import 'package:fostr/pages/user/NotificationsPage.dart';
import 'package:fostr/pages/user/RewardsPage.dart';
import 'package:fostr/pages/user/RoomTheatrePage.dart';
import 'package:fostr/pages/user/SlidupPanel.dart';
import 'package:fostr/pages/user/UserProfile.dart';
import 'package:fostr/pages/user/homePageContent.dart';
import 'package:fostr/pages/user/userActivity/UserRecordings.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/RoomProvider.dart';
import 'package:fostr/providers/ThemeProvider.dart';
import 'package:fostr/reviews/goToReviews.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';

import 'package:fostr/services/MethodeChannels.dart';
import 'package:fostr/services/NotificationService.dart';
import 'package:fostr/services/RecordingService.dart';
import 'package:fostr/services/RoomService.dart';
import 'package:fostr/services/TheatreService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/theatre/TheatreHomePage.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/HomePage/NotificationBell.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:fostr/widgets/floatingMenu.dart';
import 'package:fostr/widgets/rooms/OngoingRoomCard.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../reviews/AllReviews.dart';
import 'AllRooms.dart';
import 'SearchPage.dart';

class UserDashboard extends StatefulWidget {
  final String? tab;
  final bool? isOnboarding;
  final bool? refresh;
  final int? home;
  final int? chip;
  final int? currentindex;
  final DateTime? selectDay;
  const UserDashboard(
      {Key? key,
       this.tab,
      this.isOnboarding,
      this.refresh,
      this.home,
      this.chip,
        this.currentindex,
       this.selectDay
      })
      : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> with FostrTheme, ChangeNotifier {

  int _selectedIndex = 0;
  // ValueNotifier<int> currIndex = ValueNotifier<int>(0);

  static const url = "https://www.fosterreads.com/";
  int _currentindex = 0;
  bool isDark = true;
  String tab = "";
  String androidText = dotenv.env['androidLink'] ?? "";
  String iosText = dotenv.env['iosLink'] ?? "";
  String subject = 'Join now';
  String version = "";
  final UserService userService = GetIt.I<UserService>();
  User user = User.fromJson({
    "name": "user",
    "userName": "user",
    "id": "userId",
    "userType": "USER",
    "createdOn": DateTime.now().toString(),
    "lastLogin": DateTime.now().toString(),
    "invites": 10,
  });

  // HomePageIndex currIndex = HomePageIndex(0);

  void _onItemTapped(int index) {
    // _selectedIndex = index;
    setState(() {
      switch (index) {
        case 0:
          {
            _currentindex = 0;
          }

          break;
        case 1:
          {
            _currentindex = 1;
          }

          break;
        case 2:
          {
            _currentindex = 2;
          }

          break;
        case 3:
          {
            _currentindex = 3;
          }

          break;

        default:
      }
    });
  }

  currindex(int value) {
    _currentindex = value;
  }

  var _children;

  final FosterMethodChannel agoraChannel = GetIt.I<FosterMethodChannel>();

  static const textStyle = TextStyle(
    fontSize: 16,
    fontFamily: "drawerbody",
  );
  Future<void> routeTo(param) async {
    switch (param) {
      case 'home':
        setState(() {
          _currentindex = 0;
        });
        Navigator.of(context).pop();
        break;

      case 'notificationSetting':
        setState(() {
          _currentindex = 0;
        });
        Navigator.of(context).pop();
        FostrRouter.goto(
          context,
          Routes.notificationSetting,
        );
        break;
      case 'about':
        setState(() {
          _currentindex = 0;
        });
        if (await canLaunch(url)) {
          await launch(
            url,
            forceSafariVC: true,
            forceWebView: true,
            enableJavaScript: true,
            headers: <String, String>{'my_header_key': 'my_header_value'},
          );
          // print("c");
        } else {
          ToastMessege("Could not launch URL", context: context);
        }
        Navigator.of(context).pop();
        break;
      case 'contactus':
        setState(() {
          _currentindex = 0;
        });
        if (await canLaunch(url)) {
          await launch(
            url,
            forceSafariVC: false,
            forceWebView: false,
            headers: <String, String>{'my_header_key': 'my_header_value'},
          );
        } else {
          ToastMessege("Could not launch URL", context: context);
        }
        Navigator.of(context).pop();
        break;

      case 'allBookClubs':
        setState(() {
          _currentindex = 0;
        });
        FostrRouter.goto(
          context,
          Routes.dashboard,
        );
        break;
    }
  }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  bool? onboarding = false;
  List newUsers = [];
  List newUsersWithP = [];
  List newUsersWithoutP = [];

  void getNewUsers() async {

    // int count = 0;
    // List names = [];
    // try{
    //   await FirebaseFirestore.instance
    //       .collection("users")
    //       .where("special", isEqualTo: true)
    //       .get()
    //       .then((value){
    //         value.docs.forEach((element) {
    //           setState(() {
    //             count++;
    //             print("count $count ${element["name"]}");
    //             newUsers.add(element.id);
    //           });
    //         });
    //   });
    // } catch(e) {}

    dynamic list = await UserService().getRecentUser();
    list.forEach((element) {
      setState(() {
        newUsers.add(element);
      });
    });
    ///
    // for(String id in newUsers){
    //   await FirebaseFirestore.instance
    //       .collection("users")
    //       .doc(id)
    //       .get()
    //       .then((user){
    //     try{
    //       if(user["userProfile"]["profileImage"] != null ||
    //           user["userProfile"]["profileImage"] != "null" ||
    //           user["userProfile"]["profileImage"] != ""){
    //         setState(() {
    //           newUsersWithP.add(user.id);
    //           print("new user with profile image");
    //           print("${user.id} ${user["userProfile"]["profileImage"]}");
    //         });
    //       } else {
    //         setState(() {
    //           newUsersWithoutP.add(user.id);
    //         });
    //       }
    //     } catch(e) {
    //       setState(() {
    //         newUsersWithoutP.add(user.id);
    //       });
    //     }
    //   });
    // }
  }

  void sortNewUsers() async {

  }

  @override
  void initState() {
    // Future.delayed(Duration(seconds: 1), () {
      NotificationService.listen(context);
      print("listen called in homepage");
    // });
    // currIndex.addListener(() {
    //   setState(() {
    //     _currentindex = currIndex.value;
    //   });
    // });
    // getExcelData();
    getNewUsers();
    sortNewUsers();
    super.initState();
    getVersion();
    getTrendingPodcasts();
    // checkTabInfo();
    setState(() {
      _currentindex = widget.currentindex ?? 0;
      onboarding = widget.isOnboarding;
      _children = [
        // OngoingRoom(
        //   tab: widget.tab,
        //   refresh: widget.refresh,
        // ),
        // CalendarPage(
        //   chip: widget.chip,
        //   selectDay: widget.selectDay,
        // ),

        AllLandingPage(refresh: true,
        newUsers: newUsers,),
        AllReviews(
          page: 'home',
          postsOfUserId: '',
          refresh: widget.refresh,
        ),
        PodcastPage(enroute: false,),
        RoomTheatrePage(),
      ];
      if (widget.home == 1) {
        _currentindex = 1;
      }
    });
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _subscription = auth.updateSubscribedBookClubs();
      userService.getUserById(auth.user!.id).then((value) {
        if (value != null) {
          if (mounted) {
            setState(() {
              user = value;
              // tab = widget.tab;
            });
          }
        }
      });
    });
  }

  // void checkTabInfo() {
  //   setState(() {
  //     if(widget.tab == "all"){
  //       _currentindex = 0;
  //     } else if(widget.tab == "bits"){
  //       _currentindex = 1;
  //     } else if(widget.tab == "rooms" || widget.tab == "theatres"){
  //       _currentindex = 2;
  //     }
  //   });
  // }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void changeOrientation() {
    print("Change View");
  }

  PanelController _panelController = PanelController();

  List podIds = [];
  List podData = [];
  List podImages = [];
  List podTitles = [];
  List podAuthors = [];

  void getTrendingPodcasts() async {
    await FirebaseFirestore.instance
        .collection("recordings")
        .where("isActive", isEqualTo: true)
        .orderBy("dateTime", descending: true)
        .limit(3)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element["type"] == "ROOM"
            ? RoomService()
                .getRoomById(element["roomId"], element["userId"])
                .then((room) {
                setState(() {
                  podIds.add(element.id);
                  podData.add(element.data());
                  podImages.add(room!.imageUrl);
                  podTitles.add(room.title);
                  podAuthors.add(room.roomCreator);
                });
              })
            : TheatreService()
                .getTheatreById(element["roomId"], element["userId"])
                .then((theatre) {
                setState(() {
                  podIds.add(element.id);
                  podData.add(element.data());
                  podImages.add(theatre!.imageUrl);
                  podTitles.add(theatre.title);
                  podAuthors.add(theatre.creatorUsername);
                });
              });
      });
    });
  }

  Widget returnBody() {
    Widget bodyWidget = AllLandingPage(
      refresh: widget.refresh,
      newUsers: newUsers,
    );
    switch (_currentindex) {
      case 0:
        bodyWidget = AllLandingPage(
          refresh: widget.refresh,
          newUsers: newUsers,
        );
        break;
      case 1:
        bodyWidget = GoToReviews();
        break;
      case 2:
        bodyWidget = PodcastPage(enroute: false,);
        break;
      case 3:
        bodyWidget = RoomTheatrePage();
        break;
    }
    return bodyWidget;
  }

  ///getExcelData
  // void getExcelData() async {
  //
  //   ByteData data = await rootBundle.load("assets/data_for_posts.xlsx");
  //   var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  //   var excel = Excel.decodeBytes(bytes);
  //
  //   for (var table in excel.tables.keys) {
  //     // print("-------------------");
  //     // print(table); //sheet Name
  //     // print(excel.tables[table]!.maxCols);
  //     // print(excel.tables[table]!.maxRows);
  //     // print("-------------------");
  //
  //     Map data =
  //     json.decode(excel.tables[table]!.row(1)[0]!.value.toString().replaceAll("'", '"'));
  //
  //     for (int i = 89 ; i < (excel.tables[table]!.maxRows) ; i++){
  //       try {
  //               Map data =
  //               json.decode(excel.tables[table]!.row(i)[0]!.value.toString().replaceAll("'", '"'));
  //               ///data
  //               print("-------------------");
  //               print(data["title"]);
  //               // print(data["url"]);
  //               // print(data["covers"]["large"]);
  //               // print(data["authors"]);
  //               // ///description
  //               // print(excel.tables[table]!.row(i)[2]!.value);
  //               // print("-------------------");
  //
  //               await FirebaseFirestore.instance
  //                   .collection("booksearch")
  //                   .doc(data["title"].toString().toLowerCase().trim())
  //                   .set({
  //                 "book_title" : data["title"].toString().toLowerCase().trim(),
  //                 "author" : data["authors"],
  //                 "url" : data["url"],
  //                 "image" : data["covers"]["large"],
  //                 "description" : excel.tables[table]!.row(i)[2]!.value,
  //                 "dateTime" : DateTime.now()
  //               },SetOptions(merge: true));
  //
  //             } catch(e) {}
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final audioPlayerData = Provider.of<AudioPlayerData>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final theme = Theme.of(context);
    return new WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent, //theme.colorScheme.secondary,
            // theme.brightness == Brightness.light ?
            //                   Colors.teal.shade300 :
            //                   Colors.deepOrange.shade300,

          drawer: ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            child: Drawer(
              backgroundColor: theme.backgroundColor,
              child: ListView(
                padding: EdgeInsets.all(0),
                children: [

                  //logo and hello
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: UserAccountsDrawerHeader(
                      accountEmail: null,
                      accountName: null,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/images/Foster_logo.png'),
                        fit: BoxFit.contain,
                      )),
                    ),
                  ),
                  ListTile(
                    title: Container(
                      child: Text(
                        'Hello, ${auth.user?.name}',
                        style:
                            TextStyle(fontSize: 24, fontFamily: "drawerhead"),
                      ),
                    ),
                    // subtitle: Text(
                    //   'We missed you',
                    //   style: TextStyle(
                    //       color: Colors.teal, fontFamily: "drawerhead"),
                    // ),
                  ),

                  //home
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.home_outlined,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          const Text('Home', style: textStyle),
                        ],
                      ),
                    ),
                    onTap: () => routeTo('home'),
                  ),

                  //profile
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_circle_outlined,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          const Text('My Profile', style: textStyle),
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => UserProfilePage(),
                        ),
                      );
                    },
                  ),

                  //calendar
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          const Text('Calender', style: textStyle),
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => CalendarPage(
                            chip: 0,
                            selectDay: DateTime.now(),
                          )
                        ),
                      );
                    },
                  ),

                  //about us
                  // GestureDetector(
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(
                  //         vertical: 15.0, horizontal: 10),
                  //     child: Row(
                  //       children: [
                  //         Icon(
                  //           Icons.info_outline,
                  //         ),
                  //         SizedBox(
                  //           width: 10,
                  //         ),
                  //         const Text('About Us', style: textStyle),
                  //       ],
                  //     ),
                  //   ),
                  //   onTap: () => routeTo('about'),
                  // ),

                  //contact us
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.contact_support_outlined,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          const Text('Contact Us', style: textStyle),
                        ],
                      ),
                    ),
                    onTap: () => routeTo('contactus'),
                  ),

                  //share app
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10),
                      child: Row(
                        children: [
                          Image.asset("assets/images/share_black.png"),
                          // SvgPicture.asset("assets/icons/blue_share.svg"),
                          // Icon(Icons.share_outlined),
                          SizedBox(
                            width: 10,
                          ),
                          const Text('Share our App', style: textStyle),
                        ],
                      ),
                    ),
                    onTap: () {
                      // TODO: add link of ios app in iosText variable
                      Share.share(
                        (Platform.isIOS) ? iosText : androidText,
                        subject: subject,
                      );
                    },
                  ),

                  //rewards
                  // GestureDetector(
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(
                  //         vertical: 15.0, horizontal: 10),
                  //     child: Row(
                  //       children: [
                  //         Icon(
                  //           Icons.monetization_on_outlined,
                  //         ),
                  //         SizedBox(
                  //           width: 10,
                  //         ),
                  //         const Text('Foster Rewards', style: textStyle),
                  //       ],
                  //     ),
                  //   ),
                  //   onTap: () async {
                  //     setState(() {
                  //       currIndex = 0;
                  //     });
                  //
                  //     Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (context) => RewardsPage()));
                  //   },
                  // ),

                  //theme
                  // GestureDetector(
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(
                  //         vertical: 15.0, horizontal: 10),
                  //     child: Row(
                  //       children: [
                  //         Icon(Icons.dark_mode_outlined),
                  //         SizedBox(
                  //           width: 10,
                  //         ),
                  //         Text(
                  //             (theme.brightness == Brightness.dark)
                  //                 ? 'Light Mode'
                  //                 : "Dark Mode",
                  //             style: textStyle),
                  //       ],
                  //     ),
                  //   ),
                  //   onTap: () async {
                  //     themeProvider.toggleMode();
                  //   },
                  // ),

                  //notification settings
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notification_add_outlined,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Notification Settings',
                                    style: textStyle),
                                TextSpan(
                                    text: "",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => routeTo('notificationSetting'),
                  ),

                  //logout
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app_outlined, color: theme.colorScheme.secondary),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Logout',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.secondary,
                                  fontFamily: "drawerbody")),
                        ],
                      ),
                    ),
                    onTap: () async {
                      setState(() {
                        _currentindex = 0;
                      });
                      await auth.signOut();
                      // Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (Route<dynamic> route) => false);
                    },
                  ),

                  //version
                  version != ""
                      ? ListTile(
                          subtitle: Text(
                            "App version: $version",
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),

          appBar: AppBar(
            // iconTheme: IconThemeData(color: Colors.white),

            titleSpacing: 0,
            // leading: Builder(
            //   builder: (BuildContext context) {
            //     return Padding(
            //       padding: const EdgeInsets.only(left: 10),
            //       child: GestureDetector(
            //         onTap: () {
            //           Scaffold.of(context).openDrawer();
            //         },
            //
            //         child: RoundedImage(
            //           width: 70,
            //           height: 70,
            //           borderRadius: 30,
            //           url: auth.user?.userProfile?.profileImage,
            //         ),
            //       ),
            //     );
            //     //   IconButton(
            //     //   icon: SvgPicture.asset(
            //     //     'assets/icons/menu.svg',
            //     //     color: theme.colorScheme.inversePrimary,
            //     //     height: 20,
            //     //   ),
            //     //   onPressed: () {
            //     //     Scaffold.of(context).openDrawer();
            //     //   },
            //     //   tooltip:
            //     //       MaterialLocalizations.of(context).openAppDrawerTooltip,
            //     // );
            //   },
            // ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [

                    ///profile
                    Builder(
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },

                            child: RoundedImage(
                              width: 65,
                              height: 65,
                              borderRadius: 30,
                              url: auth.user?.userProfile?.profileImage,
                            ),
                          ),
                        );
                      }
                    ),
                    Expanded(
                        child: Container(
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Welcome Back",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold
                                ),),
                                SizedBox(height: 5,),
                                Text(user.name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: "drawerhead"
                                  ),overflow: TextOverflow.ellipsis,)
                              ],
                            ),
                          ),
                        )
                    ),

                    ///create
                    FloatingButtonMenu(),

                    ///notifications page
                    NotificationBelll(
                      isOnboarding: onboarding,
                    ),

                    ///search page
                    IconButton(
                        onPressed: () async {

                          // await FirebaseFirestore.instance
                          //     .collection("users")
                          //     .get()
                          //     .then((value){
                          //    value.docs.forEach((element) {
                          //      print(element.id);
                          //      print(element["followers"]);
                          //      // try{
                          //      //   print("----");
                          //      //   print(element["followers"]);
                          //      //   print("----");
                          //      // } catch(e) {
                          //      //   print("missing followers");
                          //      //   print(element.id);
                          //      // }
                          //    });
                          // });

                          ///add data in special users
                          // try{
                          //   await FirebaseFirestore.instance
                          //       .collection("users")
                          //       .where("special", isEqualTo: true)
                          //       .get()
                          //       .then((value){
                          //     value.docs.forEach((element) async {
                          //       await FirebaseFirestore.instance
                          //       .collection("users")
                          //       .doc(element.id)
                          //       .set({
                          //         "invites" : 0,
                          //         "lastLogin" : DateTime.now().toIso8601String(),
                          //       }, SetOptions(merge: true));
                          //     });
                          //   });
                          // } catch(e) {}

                          ///add bio in special users
                          // int cnt = 0;
                          // try{
                          //   await FirebaseFirestore.instance
                          //       .collection("users")
                          //       .where("special", isEqualTo: true)
                          //       .get()
                          //       .then((value){
                          //     value.docs.forEach((element) async {
                          //       setState(() {
                          //         cnt++;
                          //         print(cnt);
                          //       });
                          //       final _random = new Random();
                          //       var b1 = bio[_random.nextInt(bio.length)];
                          //
                          //       await FirebaseFirestore.instance
                          //       .collection("users")
                          //       .doc(element.id)
                          //       .set({
                          //         "userProfile" : {
                          //           "bio" : b1
                          //         }
                          //       }, SetOptions(merge: true));
                          //     });
                          //   });
                          // } catch(e) {}

                          ///add genre in special users
                          // int cnt = 0;
                          // try{
                          //   await FirebaseFirestore.instance
                          //       .collection("users")
                          //       .where("special", isEqualTo: true)
                          //       .get()
                          //       .then((value){
                          //     value.docs.forEach((element) async {
                          //       setState(() {
                          //         cnt++;
                          //         print(cnt);
                          //       });
                          //       final _random = new Random();
                          //       var g1 = genres[_random.nextInt(genres.length)];
                          //       var g2 = genres[_random.nextInt(genres.length)];
                          //       var g3 = genres[_random.nextInt(genres.length)];
                          //       var g4 = genres[_random.nextInt(genres.length)];
                          //
                          //       await FirebaseFirestore.instance
                          //       .collection("users")
                          //       .doc(element.id)
                          //       .set({
                          //         "userProfile" : {
                          //           "genres" : [g1,g2,g3,g4]
                          //         }
                          //       }, SetOptions(merge: true));
                          //     });
                          //   });
                          // } catch(e) {}

                          ///add topReads in special users
                          // int cnt = 0;
                          // try{
                          //   await FirebaseFirestore.instance
                          //       .collection("users")
                          //       .where("special", isEqualTo: true)
                          //       .get()
                          //       .then((value){
                          //     value.docs.forEach((element) async {
                          //       setState(() {
                          //         cnt++;
                          //         print(cnt);
                          //       });
                          //       final _random = new Random();
                          //       var b1 = topReads[_random.nextInt(topReads.length)];
                          //       var b2 = topReads[_random.nextInt(topReads.length)];
                          //       var b3 = topReads[_random.nextInt(topReads.length)];
                          //
                          //       await FirebaseFirestore.instance
                          //       .collection("users")
                          //       .doc(element.id)
                          //       .set({
                          //         "userProfile" : {
                          //           "topRead" : [b1,b2,b3]
                          //         }
                          //       }, SetOptions(merge: true));
                          //     });
                          //   });
                          // } catch(e) {}

                          ///special user count
                          // int count = 0;
                          // List names = [];
                          // try{
                          //   await FirebaseFirestore.instance
                          //       .collection("users")
                          //       .where("special", isEqualTo: true)
                          //       .get()
                          //       .then((value){
                          //         value.docs.forEach((element) {
                          //           setState(() {
                          //             names.add(element["name"]);
                          //             count++;
                          //             print("count $count ${element["name"]}");
                          //           });
                          //         });
                          //         // for(int i=0; i<users.length; i++){
                          //         //   if(!names.contains(users[i]["name"])){
                          //         //     print(users[i]["name"]);
                          //         //   }
                          //         //   else {
                          //         //     // print("exists");
                          //         //   }
                          //         // }
                          //   });
                          //   // print("count $count");
                          // } catch(e) {}

                          ///add special users in db
                          // const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                          // Random _rnd = Random();
                          //
                          // String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
                          //     length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
                          //
                          // for( int i=0; i<users.length ; i++){
                          //   String id = getRandomString(30);
                          //   print("$i ${users[i]["name"]}");
                          //
                          //   await FirebaseFirestore.instance
                          //       .collection("users")
                          //       .doc(id)
                          //       .set({
                          //     "special" : true,
                          //     "appVersion" : "1.4.1",
                          //     "bookClubName" : "",
                          //     "bookmarks" : [],
                          //     "createdOn" : DateTime.now().toIso8601String(),
                          //     "followers" : [],
                          //     "followings" : [],
                          //     "id" : id,
                          //     "name" : users[i]["name"],
                          //     "userName" : users[i]["username"],
                          //     "toLowerName" : users[i]["name"].toString().toLowerCase().trim(),
                          //     "toLowerUserName" : users[i]["username"].toString().toLowerCase().trim(),
                          //     "userProfile" : {
                          //       "Bookmarks" : null,
                          //       "bio" : "",
                          //       "description" : "",
                          //       "genres" : [],
                          //       "profileImage" : "",
                          //       "topReads" : [],
                          //       "userType" : "USER"
                          //     },
                          //   });
                          // }

                          ///search page
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                                  SearchPage()
                              )
                          );
                        },
                        icon: Icon(
                          Icons.search_outlined,
                          color: Colors.white,
                          size: 25,
                        )),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
            ),
            toolbarHeight: 0,
            elevation: 0,
            backgroundColor: dark_blue//theme.colorScheme.secondary
            // theme.brightness == Brightness.light ?
            //                   Colors.teal.shade300 :
            //                   Colors.deepOrange.shade300,
            // actions: [
            //
            //   ///calendar page
            //   // IconButton(
            //   //     highlightColor: theme.colorScheme.primary,
            //   //     splashColor: theme.colorScheme.primary,
            //   //     onPressed: () {
            //   //       Navigator.push(context,
            //   //           MaterialPageRoute(builder: (context) => CalendarPage(
            //   //             chip: 0,
            //   //             selectDay: DateTime.now(),
            //   //           )));
            //   //     },
            //   //     icon: Icon(
            //   //       Icons.calendar_today_outlined,
            //   //       color: theme.colorScheme.inversePrimary,
            //   //       size: 22,
            //   //     )),
            //
            //   ///create
            //   FloatingButtonMenu(),
            //
            //   ///notifications page
            //   NotificationBelll(
            //     isOnboarding: onboarding,
            //   ),
            //
            //   ///search page
            //   IconButton(
            //       onPressed: () {
            //         // FostrRouter.goto(context, Routes.search);
            //         Navigator.push(context,
            //             MaterialPageRoute(builder: (context) => SearchPage()));
            //       },
            //       icon: Icon(
            //         Icons.search_outlined,
            //         color: theme.colorScheme.inversePrimary,
            //         size: 25,
            //       )),
            //
            //   SizedBox(
            //     width: 10,
            //   )
            // ],
          ),

          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: _currentindex == 0 ?
                  SvgPicture.asset("assets/icons/orange_home.svg") :
                  SvgPicture.asset("assets/icons/grey_home.svg")
                  // Icon(Icons.home_outlined)
                  , label: 'Home',
                  backgroundColor: theme.colorScheme.primary),
              BottomNavigationBarItem(
                  icon: _currentindex == 1 ?
                  SvgPicture.asset("assets/icons/orange_Bits.svg") :
                  SvgPicture.asset("assets/icons/grey_Bits.svg")
                  // Icon(Icons.music_note)
                  , label: 'Reviews',
                  backgroundColor: theme.colorScheme.primary),
              BottomNavigationBarItem(
                  icon: _currentindex == 2 ?
                  SvgPicture.asset("assets/icons/orange_podcast.svg") :
                  SvgPicture.asset("assets/icons/grey_podcast.svg")
                  // Icon(Icons.podcasts)
                  , label: 'Podcasts',
                  backgroundColor: theme.colorScheme.primary),
              BottomNavigationBarItem(
                  icon: _currentindex == 3 ?
                  SvgPicture.asset("assets/icons/orange_room.svg") :
                  SvgPicture.asset("assets/icons/grey_room.svg")
                  // Icon(Icons.mic)
                  , label: 'Room',
                  backgroundColor: theme.colorScheme.primary),
            ],
            currentIndex: _currentindex,
            elevation: 10,
            selectedItemColor: Colors.deepOrange,
            enableFeedback: false,
            showUnselectedLabels: true,
            unselectedItemColor: Color.fromRGBO(111, 116, 129, 1),
            onTap: _onItemTapped,
            backgroundColor: theme.colorScheme.primary,
          ),

          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: dark_blue
              // gradient: LinearGradient(
              //   colors: [
              //     theme.colorScheme.secondary,
              //     Color(0xFF223B3A)
              //     //Color(0xFF2E3170)
              //   ],
              //   begin : Alignment.topCenter,
              //   end : Alignment.bottomCenter,
              //   stops: [0,0.2]
              // )
            ),
            child: Stack(
              children: [
                //white background
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.61,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(60),
                          topLeft: Radius.circular(60)
                        )
                    ),
                  ),
                ),

                //body
                returnBody(),

                // _children[currIndex],

                //global player
                SlidupPanel(),
              ],
            ),
          ),

          // floatingActionButton:
          //     (audioPlayerData.mediaMeta.mediaType != MediaType.none)
          //         ? null
          //         : FloatingButtonMenu(),
        ),
      ),
    );
  }
}

class OngoingRoom extends StatefulWidget {
  final String tab;
  final bool? refresh;
  const OngoingRoom({Key? key, required this.tab, this.refresh})
      : super(key: key);

  @override
  State<OngoingRoom> createState() => _OngoingRoomState();
}

class _OngoingRoomState extends State<OngoingRoom> with FostrTheme {
  String now = DateFormat('yyyy-MM-dd').format(DateTime.now()) +
      " " +
      DateFormat.Hm().format(DateTime.now());

  @override
  void initState() {
    askPermission();
    super.initState();
  }

  askPermission() async {
    await Permission.microphone.request().then(
          (value) => Permission.storage.request(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return HomePageContent(
      tab: widget.tab,
      refresh: widget.refresh,
    );
  }

  Widget startRoomButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        child: Text('Start Room'),
        onPressed: () {
          FostrRouter.goto(context, Routes.roomDetails);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Color(0xff94B5AC)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}

class RoomList extends StatelessWidget with FostrTheme {
  RoomList({
    Key? key,
    required this.id,
  }) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: roomCollection.doc(id).collection('rooms').snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.length == 0)
          return SizedBox.shrink();

        if (snapshot.hasData) {
          final roomList = snapshot.data!.docs;
          return Column(
            children: List.generate(
              roomList.length,
              (index) {
                final room = roomList[index].data();
                return GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (BuildContext context) => ThemePage(
                          room: Room.fromJson(room, ""),
                        ),
                      ),
                    );
                  },
                  child: (DateTime.parse(
                                  Room.fromJson(room, "").dateTime.toString())
                              .isAfter(DateTime.now()
                                  .toUtc()
                                  .subtract(Duration(minutes: 90))) &&
                          DateTime.parse(
                                  Room.fromJson(room, "").dateTime.toString())
                              .isBefore(DateTime.now()
                                  .toUtc()
                                  .add(Duration(minutes: 10))))
                      ? OngoingRoomCard(
                          room: Room.fromJson(room, ""),
                        )
                      : Container(),
                );
              },
            ).toList(),
          );
        }
        return Container();
      },
    );
  }
}
