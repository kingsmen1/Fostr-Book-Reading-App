import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fostr/albums/DynamicLinkAlbum.dart';
import 'package:fostr/albums/DynamicLinkEpisode.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/models/RoomModel.dart';
import 'package:fostr/pages/rooms/ThemePage.dart';
import 'package:fostr/pages/user/BookClub.dart';
import 'package:fostr/providers/IndexProvider.dart';
import 'package:fostr/providers/ThemeProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/services/Locators.dart';
import 'package:fostr/services/NotificationService.dart';
import 'package:fostr/services/RatingsService.dart';
import 'package:fostr/utils/ConnectivityChecker.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/UserProfile/DynamiclinkUserProfile.dart';
import 'package:fostr/widgets/theatre/DynamicLinkTheatrePage.dart';

import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'widgets/FosterBits/DynamicLinkBitsPage.dart';
import 'widgets/ToastMessege.dart';
import 'widgets/UserRecordings/DynamicLinkPodsPage.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocators();
  await NotificationService.start();
  // NOTE: following line enables the always screen on
  Wakelock.enable();
  runApp(
    IndexProvider(child: MyApp()),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(

          theme: FosterThemeData.lightTheme,
          darkTheme: FosterThemeData.lightTheme,
          themeMode: themeProvider.mode,
          supportedLocales: [
            const Locale('en'),
          ],
          localizationsDelegates: [CountryLocalizations.delegate],
          debugShowCheckedModeBanner: false,
          showPerformanceOverlay: false,
          home: FostrApp(),
        );
      },
    );
  }
}

class FostrApp extends StatefulWidget  with WidgetsBindingObserver {
  const FostrApp({
    Key? key,
  }) : super(key: key);

  @override
  State<FostrApp> createState() => _FostrAppState();
}

class _FostrAppState extends State<FostrApp> {
  // Future<Position> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }

  //   return await Geolocator.getCurrentPosition();
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     NotificationService.listen(context);
  //     print("line 64 app back in foreground");
  //   }
  //   super.didChangeAppLifecycleState(state);
  // }

  bool bookClubBottomSheetOpen = false;
  void showLinkOpeningSheet(String title) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            bookClubBottomSheetOpen = false;
            return true;
          },
          child: Container(
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(),
                SizedBox(
                  height: 50,
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
      isDismissible: false,
      enableDrag: false,
    );
  }

  void handleBookClubLink(String linkCode) async {
    bookClubBottomSheetOpen = true;
    showLinkOpeningSheet("Opening Book Club");
    var roomDoc =
        FirebaseFirestore.instance.collection("bookclubs").doc(linkCode);
    var clubData = await roomDoc.get();
    if (bookClubBottomSheetOpen) Navigator.of(context).pop();
    if (clubData.exists) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookClub(
              bookClub: BookClubModel.fromJson(clubData.data()!),
            ),
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book Club doesn\'t exists'),
        ),
      );
      return;
    }
  }

  void listenForDynamicLinks() {
    FirebaseDynamicLinks.instance.onLink
        .listen(handleDynamicLinkData)
        .onError((error) {});
  }

  void handleRoomInvite(String roomId, String creatorId) async {
    bookClubBottomSheetOpen = true;
    showLinkOpeningSheet("Opening Room");
    log(roomId);
    log(creatorId);
    var roomDoc = FirebaseFirestore.instance
        .collection("rooms")
        .doc(creatorId)
        .collection('rooms')
        .doc(roomId);
    var clubData = await roomDoc.get();
    if (bookClubBottomSheetOpen) Navigator.of(context).pop();
    if (clubData.exists) {
      var dataMap = clubData.data()!;
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (BuildContext context) => ThemePage(
            room: Room.fromJson(dataMap, ""),
          ),
        ),
      );
    } else {
      showErrorSnack('Room doesn\'t exists');
      return;
    }
  }

  void showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  Future<void> handleDynamicLinkData(PendingDynamicLinkData dynamicLinkData) async {
    log(dynamicLinkData.link.queryParameters.toString());
    if (dynamicLinkData.link.path == '/bookClub') {
      handleBookClubLink(dynamicLinkData.link.queryParameters['code']!);
    } else if (dynamicLinkData.link.path == '/r') {
      if (dynamicLinkData.link.queryParameters['roomId'] == null ||
          dynamicLinkData.link.queryParameters['creator'] == null) {
        showErrorSnack('Invalid Room Invite');
        return;
      }
      handleRoomInvite(dynamicLinkData.link.queryParameters['roomId']!,
          dynamicLinkData.link.queryParameters['creator']!);
    } else if (dynamicLinkData.link.path == '/fosterbits') {
      final parameters = dynamicLinkData.link.queryParameters;
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (BuildContext context) => DynamicLinkBitsPage(
            id: parameters["id"],
          ),
        ),
      );
    } else if (dynamicLinkData.link.path == "/pods") {
      final parameters = dynamicLinkData.link.queryParameters;
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (BuildContext context) => DynamicLinkPodsPage(
            id: parameters["id"],
          ),
        ),
      );
    } else if (dynamicLinkData.link.path == "/theatre") {
      final parameters = dynamicLinkData.link.queryParameters;
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (BuildContext context) => DynamicLinkTheatrePage(
            theatreId: parameters["theatreId"],
            creatorId: parameters["creatorId"],
          ),
        ),
      );
    } else if (dynamicLinkData.link.path == "/fosteruser") {
      final parameters = dynamicLinkData.link.queryParameters;
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (BuildContext context) => DynamicLinkUserProfile(
            id: parameters["id"],
          ),
        ),
      );
    } else if (dynamicLinkData.link.path == "/albums") {
      final parameters = dynamicLinkData.link.queryParameters;
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (BuildContext context) => DynamicLinkAlbum(
            authId: parameters["authId"],
            albumId: parameters["albumId"],
          ),
        ),
      );
    } else if (dynamicLinkData.link.path == "/episode") {
      final parameters = dynamicLinkData.link.queryParameters;
      await FirebaseFirestore.instance
          .collection("albums")
          .doc(parameters["albumId"])
          .collection("episodes")
          .doc(parameters["episodeId"])
          .get()
      .then((value){
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => DynamicLinkEpisode(
                episode: value.data()!,
              authorUsername: parameters['username']!,
            ),
          ),
        );
      });
    }
  }

  void checkForAnyPendingLinks() async {
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      handleDynamicLinkData(initialLink);
    }
  }


  Map _source = {ConnectivityResult.none: false};
  final ConnectivityChecker _connectivity = ConnectivityChecker.instance;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      NotificationService.listen(context);
    });
    checkForAnyPendingLinks();
    listenForDynamicLinks();
    // _determinePosition().then((position) {
    //   if (position != null) {
    //     log(position.toString());
    //   }
    // });
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (source.keys.first == ConnectivityResult.none) {
        ToastMessege("You need an Internet connection to use this app",
            context: context);
      } else {
        // ToastMessege("You are connected to the Internet");

      }
    });
    // fetchAgora();
  }

  @override
  void dispose() {
    _connectivity.disposeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: FosterThemeData.lightTheme,
      darkTheme: FosterThemeData.darkTheme,
      useInheritedMediaQuery: true,
      supportedLocales: [
        const Locale('en'),
      ],
      localizationsDelegates: [CountryLocalizations.delegate],
      themeMode: themeProvider.mode,
      // themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      initialRoute: "/",
      onGenerateRoute: (settings) =>
          FostrRouter.generateRoute(context, settings),
      title: "FOSTR",
      navigatorObservers: [FostrRouteObserver(context)],
    );
  }
}

class FostrRouteObserver extends NavigatorObserver with FostrTheme {
  final RatingService _ratingService = GetIt.I<RatingService>();

  final BuildContext context;
  FostrRouteObserver(this.context);

  @override
  void didPop(Route route, Route? previousRoute) async {
    super.didPop(route, previousRoute);
    String name = route.settings.name ?? "";
    double ratings = 0;

    // if (name == "minimal") {
    //   bool isRated = await _ratingService.isAlreadyRated();
    //   if (!isRated) {
    //     Future.delayed(
    //       Duration(seconds: 1),
    //       () {
    //         showDialog(
    //           context: context,
    //           builder: (context) {
    //             final theme = Theme.of(context);
    //             return Dialog(
    //               backgroundColor: theme.backgroundColor,
    //               child: Container(
    //                 padding: const EdgeInsets.all(20),
    //                 decoration:
    //                     BoxDecoration(borderRadius: BorderRadius.circular(15)),
    //                 height: 250,
    //                 child: Center(
    //                   child: SingleChildScrollView(
    //                     child: Column(
    //                       children: [
    //                         Text(
    //                           "How much do you rate this room?",
    //                           style: h2.copyWith(
    //                               color: theme.colorScheme.inversePrimary),
    //                         ),
    //                         SizedBox(
    //                           height: 10,
    //                         ),
    //                         RatingBar.builder(
    //                           initialRating: 0,
    //                           minRating: 1,
    //                           maxRating: 5,
    //                           direction: Axis.horizontal,
    //                           allowHalfRating: true,
    //                           glow: false,
    //                           unratedColor: Colors.grey,
    //                           itemCount: 5,
    //                           itemPadding:
    //                               EdgeInsets.symmetric(horizontal: 4.0),
    //                           itemBuilder: (context, _) => Icon(
    //                             Icons.star,
    //                             color: theme.colorScheme.secondary,
    //                           ),
    //                           onRatingUpdate: (newRating) {
    //                             ratings = newRating;
    //                           },
    //                         ),
    //                         SizedBox(
    //                           height: 10,
    //                         ),
    //                         MaterialButton(
    //                           color: theme.colorScheme.secondary,
    //                           onPressed: () {
    //                             _ratingService.addRating(ratings);
    //                             Navigator.of(context).pop();
    //                           },
    //                           child: Text(
    //                             "Rate",
    //                             style: TextStyle(color: Colors.white),
    //                           ),
    //                         )
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             );
    //           },
    //         );
    //       },
    //     );
    //   }
    // }
  }
}
