import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/widgets/LikesList.dart';

class BookMarkedList extends StatefulWidget {
  final String title;
  final List users;
  const BookMarkedList({
    Key? key,
    required this.title,
    required this.users
  }) : super(key: key);

  @override
  State<BookMarkedList> createState() => _BookMarkedListState();
}

class _BookMarkedListState extends State<BookMarkedList> {
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
                      widget.title,
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
      // AppBar(
      //   backgroundColor: theme.colorScheme.primary,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   title: Text(widget.title,
      //     style: TextStyle(
      //         color: theme.colorScheme.inversePrimary,
      //         fontSize: 20,
      //         fontFamily: "drawerhead"
      //     ),
      //   ),
      //   leading: IconButton(
      //       onPressed: (){
      //         Navigator.pop(context);
      //         // Navigator.pushReplacement(context, MaterialPageRoute(
      //         //     builder: (context) =>
      //         //         UserDashboard(tab: "all", selectDay: DateTime.now())
      //         // ));
      //       },
      //       icon: Icon(Icons.arrow_back_ios,)
      //   ),
      //   actions: [
      //     Image.asset(
      //       "assets/images/logo.png",
      //       fit: BoxFit.contain,
      //       width: 40,
      //       height: 40,
      //     ),
      //     SizedBox(width: 10,)
      //   ],
      // ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            itemCount: widget.users.length,
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return LikesUserCard(id: widget.users[index]);
            }),
        ),
      ),
    );
  }
}
