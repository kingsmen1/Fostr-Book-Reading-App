import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/albums/AlbumPage.dart';
import 'package:fostr/pages/user/SlidupPanel.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:provider/provider.dart';

class AllAlbums extends StatefulWidget {
  const AllAlbums({Key? key}) : super(key: key);

  @override
  State<AllAlbums> createState() => _AllAlbumsState();
}

class _AllAlbumsState extends State<AllAlbums> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,

      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Podcasts",
          style: TextStyle(
              color: theme.colorScheme.inversePrimary,
              fontSize: 20,
              fontFamily: "drawerhead"
          ),
        ),
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios,)
        ),
        actions: [
          Image.asset(
            "assets/images/logo.png",
            fit: BoxFit.contain,
            width: 40,
            height: 40,
          ),
          SizedBox(width: 10,)
        ],
      ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("albums")
                      .orderBy("dateTime", descending: true)
                      .where("isActive", isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {

                    if(!snapshot.hasData){
                      return Text("no albums available");
                    }

                    return GridView.builder(
                        itemCount: snapshot.data!.docs.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
                        itemBuilder: (context, index){
                          return GestureDetector(

                            onTap: (){

                              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                  AlbumPage(
                                albumId: snapshot.data!.docs[index]["id"],
                                authId: auth.user!.id,
                                fromShare: true,
                              )));

                              // showModalBottomSheet(
                              //   context: context,
                              //   isScrollControlled: true,
                              //   backgroundColor: Colors.transparent,
                              //   builder: (context) => Padding(
                              //     padding: EdgeInsets.only(top: 100),
                              //     child: AlbumPage(
                              //       albumId: snapshot.data!.docs[index]["id"],
                              //       authId: auth.user!.id,
                              //       fromShare: false,
                              //     ),
                              //   ),
                              // );
                            },

                            child: Container(
                              height: 220,
                              child: Column(
                                children: [
                                  Expanded(child: Container()),

                                  //image
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 1,
                                            color: snapshot.data!.docs[index]["image"].isEmpty ? Colors.grey : Colors.transparent
                                        ),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: snapshot.data!.docs[index]["image"].toString().isEmpty ?
                                      Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
                                      Image.network(snapshot.data!.docs[index]["image"], fit: BoxFit.cover,),
                                    ),
                                  ),

                                  //data
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Container(
                                      height: 60,
                                      width: 130,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(),
                                          Text(snapshot.data!.docs[index]["title"],style: TextStyle(fontSize: 14),overflow: TextOverflow.ellipsis),
                                          Text(snapshot.data!.docs[index]["authorName"],style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis),
                                          Text("${snapshot.data!.docs[index]["episodes"]} episodes",style: TextStyle(fontSize: 10, color: Colors.grey),overflow: TextOverflow.ellipsis),
                                          SizedBox(),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                    );
                  }
              ),
            ),

            SlidupPanel()
          ],
        ),
      ),
    );
  }
}
