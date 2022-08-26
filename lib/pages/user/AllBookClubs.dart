import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/pages/rooms/EnterBookClubDetails.dart';
import 'package:fostr/pages/user/BookClub.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:fostr/widgets/ImageContainer.dart';
import 'package:fostr/widgets/floatingMenu.dart';
import 'package:provider/provider.dart';

class AllBookClubs extends StatefulWidget {
  const AllBookClubs({Key? key}) : super(key: key);

  @override
  _AllBookClubsState createState() => _AllBookClubsState();
}

class _AllBookClubsState extends State<AllBookClubs> {
  List bClubid = [];
  List bClubName = [];
  List bClubBios = [];
  List bClubImages = [];
  List bClubCreatedBy = [];
  List bClubadminProfile = [];
  List bClubRoomCount = [];
  List bClubMemberCount = [];
  List bClubMembers = [];

  bool myClubs = false;

  @override
  void initState() {
    super.initState();

    bookClubList();
  }

  @override
  void dispose() {
    super.dispose();
    bClubid.clear();
    bClubName.clear();
    bClubBios.clear();
    bClubImages.clear();
    bClubCreatedBy.clear();
    bClubadminProfile.clear();
    bClubRoomCount.clear();
    bClubMemberCount.clear();
    bClubMembers.clear();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMyBookClubs(String id) async {
    print(id);
    return await FirebaseFirestore.instance
        .collection('bookclubs')
        .where('createdBy', isEqualTo: id)
        .get();
  }

  Future<void> bookClubList() async {
    // String userid = FirebaseAuth.instance.currentUser!.uid;
    // var ref = FirebaseFirestore.instance.collection("bookclubs");
    // ref.get().then((value) async {
    //   for (int i = 0; i < value.docs.length; i++) {
    //     bool active = value.docs[i].get("isActive");
    //     bClubMembers = List.from(value.docs[i].data()['memberusers']);
    //     for (int j = 0; j < bClubMembers.length; j++) {
    //       if (bClubMembers[j] == userid && active) {
    //         // setState(() {
    //           bClubid.add(value.docs[i].id);
    //           bClubName.add(value.docs[i].get("bookclubName"));
    //           bClubBios.add(value.docs[i].get("bookclubBio"));
    //           bClubImages.add(value.docs[i].get("clubProfileimage"));
    //           bClubCreatedBy.add(value.docs[i].get("createdBy"));
    //           bClubadminProfile.add(value.docs[i].get("adminprofile"));
    //           bClubRoomCount.add(value.docs[i].get("roomcount"));
    //           bClubMemberCount.add(value.docs[i].get("membercount"));
    //         // });
    //       }
    //     }
    //     bClubMembers.clear();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(minHeight: 400),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Subscribed Clubs tab
                Expanded(
                    child: Container(
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        myClubs = false;
                      });
                    },
                    child: Column(
                      children: [
                        Expanded(child: Container()),
                        Text(
                          "Subscribed Clubs",
                          style: TextStyle(
                              fontWeight: myClubs
                                  ? FontWeight.normal
                                  : FontWeight.bold),
                        ),
                        Expanded(child: Container()),
                        Container(
                          height: 2,
                          color: myClubs
                              ? Colors.white
                              : theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                )),

                //my Clubs tab
                Expanded(
                    child: Container(
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        myClubs = true;
                      });
                    },
                    child: Column(
                      children: [
                        Expanded(child: Container()),
                        Text(
                          "My Clubs",
                          style: TextStyle(
                              fontWeight: myClubs
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                        Expanded(child: Container()),
                        Container(
                          height: 2,
                          color: myClubs
                              ? theme.colorScheme.secondary
                              : Colors.white,
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
            myClubs
                ?

                //my Book Clubs
                Container(
                    child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: getMyBookClubs(auth.user!.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text("Error");
                          }
                          if (!snapshot.hasData) {
                            return Center(
                              child: AppLoading(),
                            );
                          }

                          final myClubs = snapshot.data?.docs.map((e) {
                            return BookClubModel.fromJson({
                              "id": e.id,
                              ...e.data(),
                            });
                          }).toList();
                          print(myClubs);

                          return myClubs!.length > 0
                              ? GridView.builder(
                                  shrinkWrap: true,
                                  itemCount: myClubs.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final bookClub = myClubs[index];

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: GestureDetector(
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                  child: Container(
                                                width: 70,
                                                height: 100,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: bookClub.bookClubProfile !=
                                                              null &&
                                                          bookClub
                                                              .bookClubProfile!
                                                              .isNotEmpty
                                                      ? FosterImage(
                                                          imageUrl: bookClub
                                                              .bookClubProfile!)
                                                      : Image.asset(
                                                          'assets/images/logo.png',
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              )),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                bookClub.bookClubName,
                                                style: TextStyle(fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            ],
                                          ),
                                        ),
                                        onTap: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BookClub(
                                                bookClub: bookClub,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      "Create your own Book Clubs using the + icon",
                                    ),
                                  ),
                                );
                        }),
                  )
                :

                //Subscribed Book Clubs
                Container(
                    child: bClubid.length > 0
                        ? GridView.builder(
                            shrinkWrap: true,
                            itemCount: bClubid.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: GestureDetector(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Expanded(
                                            child: Container(
                                          width: 70,
                                          height: 100,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: bClubImages[index]
                                                    .toString()
                                                    .isNotEmpty
                                                ? FosterImage(
                                                    imageUrl:
                                                        bClubImages[index],
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    'assets/images/logo.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        )),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          bClubName[index],
                                          style: TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    String userID = "";
                                    await UserService()
                                        .getUserByField(
                                            "userName", bClubCreatedBy[index])
                                        .then((value) => {
                                              if (value != null)
                                                {userID = value.id}
                                            });
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => BookClub(
                                    //               bookClub: ,
                                    //             )));
                                  },
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "Search for Book Clubs to subscribe in the search tab",
                              ),
                            ),
                          ),
                  ),
          ],
        ));
  }
}
