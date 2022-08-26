import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/NotificationService.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({Key? key}) : super(key: key);

  @override
  _NotificationSettingState createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 70),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                dark_blue,
                theme.colorScheme.primary
                //Color(0xFF2E3170)
              ],
              begin : Alignment.topCenter,
              end : Alignment(0,0.8),
              // stops: [0,1]
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment(-0.9,0.6),
                child: Container(
                  height: 50,
                  width: 20,
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios,color: Colors.black,),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0,0.6),
                child: Container(
                  height: 50,
                  child: Center(
                    child: Text(
                      "Notification Settings",
                      style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 20,
                          fontFamily: 'drawerhead',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.9,0.6),
                child: Container(
                  height: 50,
                  width: 50,
                  child: Center(
                      child: Image.asset("assets/images/logo.png", width: 40, height: 40,)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Row(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.only(left: 8.0, top: 10),
              //       child: IconButton(
              //           onPressed: () {
              //             Navigator.of(context).pop();
              //           },
              //           icon: Icon(
              //             Icons.arrow_back_ios,
              //           )),
              //     ),
              //     Padding(
              //         padding: const EdgeInsets.only(left: 30.0, top: 10),
              //         child: Text(
              //           "Notification settings",
              //           style: TextStyle(
              //             fontSize: 18,
              //           ),
              //         )),
              //   ],
              // ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  height: 200,
                  decoration: BoxDecoration(
                      // color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12)),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      NotificationRow(
                        title: "Rooms Notification",
                        description: "Someone in your community creates a room",
                        topic: NotificationTopic.roomNotification,
                      ),
                      NotificationRow(
                        title: "Other Notification",
                        description: "New Followers, Events, BookClubs",
                        topic: NotificationTopic.otherNotification,
                      )
                    ],
                  ),
                ),
              )
            ]),
      ),
    );
  }
}

class NotificationRow extends StatefulWidget {
  final String title;
  final String description;
  final NotificationTopic topic;
  const NotificationRow(
      {Key? key,
      required this.title,
      required this.description,
      required this.topic})
      : super(key: key);

  @override
  _NotificationRowState createState() => _NotificationRowState();
}

class _NotificationRowState extends State<NotificationRow> {
  bool _notificationValue = false;

  final NotificationService _notificationService =
      GetIt.I<NotificationService>();
  final UserService _userService = GetIt.I<UserService>();

  User handleChangeNotification(bool value, User user) {
    if (value) {
      _notificationService.subscribeToTopic(widget.topic);
      final Map<String, dynamic> userData = user.toJson();
      final Map<String, dynamic> notificationSetting =
          user.notificationsSettings as Map<String, dynamic>;
      notificationSetting[widget.topic.name] = true;
      userData['notificationsSettings'] = notificationSetting;
      _userService.updateUserField(userData);
      return User.fromJson(userData);
    } else {
      _notificationService.subscribeToTopic(widget.topic);
      final Map<String, dynamic> userData = user.toJson();
      final Map<String, dynamic> notificationSetting =
          new Map<String, dynamic>.from(userData['notificationsSettings']);

      notificationSetting[widget.topic.name] = false;
      userData['notificationsSettings'] = notificationSetting;
      _userService.updateUserField(userData);
      return User.fromJson(userData);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      setState(() {
        _notificationValue =
            user?.notificationsSettings?[widget.topic.name] ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  widget.description,
                  style: TextStyle(fontSize: 14),
                )
              ],
            ),
          ),
          Switch(
            onChanged: (value) {
              final newUser = handleChangeNotification(value, auth.user!);
              setState(() {
                _notificationValue = value;
              });
              auth.refreshUser(newUser);
            },
            value: _notificationValue,
            activeColor: theme.colorScheme.secondary,
            inactiveTrackColor: theme.colorScheme.secondary.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
