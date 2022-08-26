import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/models/BookClubModel/PendingRequests.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:provider/provider.dart';

import '../../pages/user/NotificationsPage.dart';

class PendingRequestBell extends StatefulWidget {
  final BookClubModel bookClub;
  const PendingRequestBell({
    Key? key,
    required this.bookClub,
  }) : super(key: key);

  @override
  State<PendingRequestBell> createState() => _PendingRequestBellState();
}

class _PendingRequestBellState extends State<PendingRequestBell> {
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
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => PendingRequests(
                  club: widget.bookClub,
                ),
              ),
            );
            ;
          },
          icon: Icon(
            Icons.notifications,
            color: theme.colorScheme.inversePrimary,
            size: 30,
          ),
        ),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('bookclubs')
                .doc(widget.bookClub.id)
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
              final List pendingMembers =
                  snapshot.data?.data()?['pendingMembers'] ?? [];
              return (pendingMembers.length > 0)
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
