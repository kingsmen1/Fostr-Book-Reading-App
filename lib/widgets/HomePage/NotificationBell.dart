import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:provider/provider.dart';

import '../../pages/user/NotificationsPage.dart';

class NotificationBelll extends StatefulWidget {
  final bool? isOnboarding;
  const NotificationBelll({this.isOnboarding,Key? key}) : super(key: key);

  @override
  State<NotificationBelll> createState() => _NotificationBelllState();
}

class _NotificationBelllState extends State<NotificationBelll> {

  bool? unreadNotifications;
  bool? onboarding = false;

  @override
  void initState() {
    onboarding = widget.isOnboarding;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          highlightColor: theme.colorScheme.primary,
          splashColor: theme.colorScheme.primary,
          onPressed: () {
            setState(() {
              onboarding = false;
            });
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NotificationPage()));
          },
          icon: Icon(
            Icons.notifications,
            color: Colors.white,
            size: 30,
          ),
        ),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(auth.user!.id)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.connectionState != ConnectionState.active) {
                return SizedBox.shrink();
              }
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              unreadNotifications =
                  snapshot.data?.data()?['unreadNotifications'] ?? false;
              return (unreadNotifications! || (onboarding != null && onboarding == true))
                  ? Positioned(
                      top: 22,
                      right: 13,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )
                  : SizedBox.shrink();
            }),
      ],
    );
  }
}
