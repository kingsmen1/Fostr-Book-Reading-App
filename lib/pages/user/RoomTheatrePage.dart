import 'package:flutter/material.dart';
import 'package:fostr/pages/user/AllRooms.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/theatre/TheatreHomePage.dart';
import 'package:provider/provider.dart';

class RoomTheatrePage extends StatefulWidget {
  const RoomTheatrePage({Key? key}) : super(key: key);

  @override
  State<RoomTheatrePage> createState() => _RoomTheatrePageState();
}

class _RoomTheatrePageState extends State<RoomTheatrePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Container(
              height: 50,
              child: TabBar(
                indicatorColor: Colors.white,
                labelStyle: TextStyle(
                    color: theme.colorScheme.inversePrimary,
                    fontSize: 16,
                    fontFamily: "drawerbody"),
                tabs: [
                  Tab(
                    child: Text(
                      "Rooms",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: "drawerhead"
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Theatres",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "drawerhead"
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              children: [
                //rooms
                AllRooms(),

                //theatres
                TheatreHomePage(page: "home", authId: auth.user!.id),
              ],
            ),
          )
      ),
    );
  }
}
