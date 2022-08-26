import 'package:flutter/material.dart';
import 'package:fostr/providers/AudioPlayerData.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/providers/BitsProvider.dart';
import 'package:fostr/providers/FeedProvider.dart';
import 'package:fostr/providers/RoomProvider.dart';
import 'package:fostr/providers/RoomsMetaProvider.dart';
import 'package:provider/provider.dart';

import 'PostProvider.dart';
import 'ThemeProvider.dart';

class IndexProvider extends StatelessWidget {
  final Widget child;
  const IndexProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider.init(),
        ),
        ChangeNotifierProvider(create: (context) => FeedProvider()),
        ChangeNotifierProvider(create: (context) => BitsProvider()),
        ChangeNotifierProvider(create: (context) => PostsProvider()),
        ChangeNotifierProvider(create: (context) => RoomsMetaProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AudioPlayerData()),
        ChangeNotifierProvider(create: (context) => RoomProvider()),
      ],
      child: child,
    );
  }
}
