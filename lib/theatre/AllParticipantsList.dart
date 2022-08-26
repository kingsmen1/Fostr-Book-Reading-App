import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/models/TheatreModel.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/pages/user/UserProfile.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AllTheatreParticipantsList extends StatefulWidget {
  final Theatre theatre;

  const AllTheatreParticipantsList({
    Key? key,
    required this.theatre,
  }) : super(key: key);

  @override
  _AllTheatreParticipantsListState createState() =>
      _AllTheatreParticipantsListState();
}

class _AllTheatreParticipantsListState
    extends State<AllTheatreParticipantsList> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text(
          "All Participants",
          style: TextStyle(fontSize: 16, fontFamily: "drawerhead"),
        ),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: roomCollection
              .doc(widget.theatre.createdBy)
              .collection("amphitheatre")
              .doc(widget.theatre.theatreId)
              .collection('users')
              .where("isActiveInRoom", isEqualTo: true) // participants
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error Happened"));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text("No Participants"));
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No Participants"));
            }

            final participants =
                snapshot.data!.docs.map((e) => e.data()).toList();

            return Column(
              children: [
                Text("Total Participants: ${participants.length}"),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: participants.length,
                  itemBuilder: (BuildContext context, int index) {
                    return UserCard(user: User.fromJson(participants[index]));
                  },
                ),
              ],
            );
          }),
    );
  }
}

class UserCard extends StatefulWidget {
  final User user;
  const UserCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> with FostrTheme {
  bool followed = false;
  final UserService userService = GetIt.I<UserService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user!.followings!.contains(widget.user.id)) {
        setState(() {
          followed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) {
              if (auth.user?.id == widget.user.id) {
                return UserProfilePage();
              }
              return ExternalProfilePage(
                user: widget.user,
              );
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 60.w,
        constraints: BoxConstraints(minHeight: 70),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: theme.colorScheme.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (widget.user.name.isNotEmpty)
                    ? SizedBox(
                        width: 200,
                        child: Text(
                          widget.user.name,
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,),
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 3,
                ),
                (widget.user.bookClubName != null &&
                        widget.user.bookClubName!.isNotEmpty)
                    ? SizedBox(
                        width: 200,
                        child: Text(
                          widget.user.bookClubName!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "@" + widget.user.userName,
                  style: TextStyle(fontSize: 10.sp),
                )
              ],
            ),
            Container(
              height: 15.w,
              width: 15.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: (widget.user.userProfile != null)
                        ? (widget.user.userProfile?.profileImage != null)
                            ? FosterImageProvider(
                                imageUrl:
                                    widget.user.userProfile!.profileImage!,
                              )
                            : Image.asset(IMAGES + "profile.png").image
                        : Image.asset(IMAGES + "profile.png").image),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
