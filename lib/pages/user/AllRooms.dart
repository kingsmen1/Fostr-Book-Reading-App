import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/user/liveRooms.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/theatre/TheatreHomePage.dart';
import 'package:provider/provider.dart';


class AllRooms extends StatefulWidget {
  const AllRooms({Key? key}) : super(key: key);

  @override
  _AllRoomsState createState() => _AllRoomsState();
}

class _AllRoomsState extends State<AllRooms> {
  int selectedIndex = 0;
  final genres = [
    'Recent rooms',
    'My rooms',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //chips
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 20, top: 16),
                height: 51,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = i;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                              color: i != selectedIndex
                                  ? dark_blue
                                  : Colors.white,
                              border: Border.all(width: 0.5,color: Colors.white),
                              borderRadius: BorderRadius.circular(24)),
                          child: Center(
                            child: Text(
                              genres[i],
                              style: TextStyle(
                                  color: i != selectedIndex
                                      ? Colors.white
                                      : theme.colorScheme.secondary,
                                  fontFamily: "drawerbody"),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),

          Expanded(
              child: Container(
                  child: LiveRooms(selectedIndex, auth.user!.id))),
        ],
      ),
    );
  }
}
