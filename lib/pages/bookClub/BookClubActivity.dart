import 'package:flutter/material.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/pages/bookClub/UpcomingBookClubEvents.dart';
import 'package:fostr/pages/user/BookClubRooms.dart';

class BookClubActivity extends StatefulWidget {
  final BookClubModel bookClub;
  final bool isSubscribed;
  const BookClubActivity(
      {Key? key, required this.bookClub, required this.isSubscribed})
      : super(key: key);

  @override
  State<BookClubActivity> createState() => _BookClubActivityState();
}

class _BookClubActivityState extends State<BookClubActivity> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height-160,
      child: DefaultTabController(
        child: Scaffold(
          backgroundColor: theme.colorScheme.primary,
          appBar: TabBar(
            indicatorColor: theme.colorScheme.secondary,
            tabs: [
              Tab(
                child: Text(
                  "Live Rooms",
                  style: TextStyle(color: theme.colorScheme.inversePrimary),
                ),
              ),
              Tab(
                child: Text(
                  "Upcoming Rooms",
                  style: TextStyle(color: theme.colorScheme.inversePrimary),
                ),
              ),
            ],
          ),
          body: TabBarView(children: [
            BookClubRooms(
              userID: widget.bookClub.createdBy,
              bookClubModel: widget.bookClub,
              isSubscribed: widget.isSubscribed,
            ),
            UpcomingBookClubEvents(bookClubModel: widget.bookClub),
          ]),
        ),
        length: 2,
      ),
    );
  }
}
