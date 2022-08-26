import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/enums/search_enum.dart';
import 'package:fostr/screen/CollectionPage.dart';
import 'package:fostr/widgets/ImageContainer.dart';

class CollectionCard extends StatefulWidget {
  final String bookName;
  const CollectionCard({Key? key, required this.bookName}) : super(key: key);

  @override
  State<CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<CollectionCard> {

  List images = [];

  bool reviews = false;
  bool albums = false;
  bool posts = false;
  bool recordings = false;

  int review = 0;
  int album = 0;
  int post = 0;
  int recording = 0;

  String authorname = "";

  List data = [
    [
      SvgPicture.asset("assets/icons/grey_Bits.svg",width: 15, height: 15,),
      "Reviews",
    ],
    [
      Icon(Icons.post_add, color: Colors.grey.shade600, size: 15,),
      "Readings",
    ],
    [
      Icon(Icons.album_outlined, color: Colors.grey.shade600, size: 15,),
      "Albums",
    ],
    [
      Icon(Icons.mic, color: Colors.grey.shade600, size: 15,),
      "Recording",
    ],
  ];

  @override
  void initState() {
    getAuthorName();
    getImages();
    super.initState();
  }

  @override
  void dispose() {
    images.clear();
    reviews = false;
    albums = false;
    posts = false;
    recordings = false;
    super.dispose();
  }

  void getAuthorName() async {
    try{
      await FirebaseFirestore.instance
          .collection("booksearch")
          .doc(widget.bookName)
          .get()
          .then((value){
            setState(() {
              authorname = value["author"].toString();
            });
      });
    } catch(e) {print(e);}
  }

  void getImages() async {
    await FirebaseFirestore.instance
        .collection("booksearch")
        .doc(widget.bookName)
        .collection("activities")
        .get()
        .then((value){
          value.docs.forEach((element) {

            if(element["activitytype"] == SearchType.review.name){
              getReviewImage(element["activityid"]);

            } else if(element["activitytype"] == SearchType.recording.name){
              getRecordingImage(element["activityid"],element["creatorid"]);

            } else if(element["activitytype"] == SearchType.post.name){
              getPostImage(element["activityid"]);

            } else if(element["activitytype"] == SearchType.album.name){
              getAlbumImage(element["activityid"]);

            }
          });
    });

    await FirebaseFirestore.instance
        .collection("booksearch")
        .doc(widget.bookName)
        .get()
    .then((value){
      try{
        setState(() {
          images.add(value["image"]);
        });
      } catch (e){}
    });
  }

  void getReviewImage(String id) async {
    setState(() {
      review++;
      reviews = true;
      images.clear();
    });
    try{
      await FirebaseFirestore.instance
          .collection("reviews")
          .doc(id)
          .get()
          .then((value){
        if(value["imageUrl"].toString().isNotEmpty){
          setState(() {
            images.add(value["imageUrl"]);
            authorname = value["bookAuthor"].toString().isNotEmpty ?
            value["bookAuthor"].toString() :
                authorname;
          });
        }
      });
    } catch(e) {

    }
  }

  void getRecordingImage(String id, String uid) async {
    setState(() {
      recording++;
      recordings = true;
      images.clear();
    });
    try{
      await FirebaseFirestore.instance
          .collection("recordings")
          .doc(id)
          .get()
          .then((value) async {

        await FirebaseFirestore.instance
            .collection("rooms")
            .doc(uid)
            .collection(value["type"] == "ROOM" ? "rooms" : "amphitheatre")
            .doc(value["roomId"])
            .get()
            .then((room){
          if(room["image"].toString().isNotEmpty){
            setState(() {
              images.add(room["image"]);
              authorname = value["authorName"].toString().isNotEmpty ?
              value["authorName"].toString() :
              authorname;
            });
          }
        });

      });
    } catch(e) {

    }
  }

  void getPostImage(String id) async {
    setState(() {
      post++;
      posts = true;
      images.clear();
    });
    try{
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(id)
          .get()
          .then((value){
        if(value["image"].toString().isNotEmpty){
          setState(() {
            images.add(value["image"]);
          });
        }
      });
    } catch(e) {

    }
  }

  void getAlbumImage(String id) async {
    setState(() {
      album++;
      albums = true;
      images.clear();
    });
    try{
      await FirebaseFirestore.instance
          .collection("albums")
          .doc(id)
          .get()
          .then((value){
        if(value["image"].toString().isNotEmpty){
          print("album image");
          setState(() {
            images.add(value["image"]);
            authorname = value["authorName"].toString().isNotEmpty ?
            value["authorName"].toString() :
            authorname;
          });
        }
      });
    } catch(e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context)=>
                CollectionPage(bookname: widget.bookName)
            ));
      },

      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 1)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 75,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FosterImage(
                    fit: BoxFit.cover,
                    height: 100,
                    imageUrl: images.isNotEmpty ? images.first : "https://firebasestorage.googleapis.com/v0/b/fostr2021.appspot.com/o/FCMImages%2Ffostr.jpg?alt=media&token=42c10be6-9066-491b-a440-72e5b25fbef7"
                        // .image
                        // .thumb
                        // .toString()
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Flexible(
              child: Container(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bookName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'drawerhead',
                      ),
                    ),
                    SizedBox(height: 5,),

                    authorname != "" ?
                    Text(
                      "by ${authorname.replaceAll("[","").replaceAll("]", "")}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'drawerbody',
                      ),
                    ) : SizedBox.shrink(),
                    authorname != "" ? SizedBox(height: 10,) : SizedBox.shrink(),

                    (review + post + album + recording) > 0 ?
                    Text((review + post + album + recording) == 1 ? "1 activity" : "${review + post + album + recording} activities",
                            style: TextStyle(
                              fontFamily: "drawerbody",
                                fontStyle: FontStyle.italic,
                                color: Colors.black
                            )) : SizedBox.shrink(),

                    // recording > 0 ?
                    // Text(recording == 1 ? "1 recording" : "$recording recordings",
                    //     style: TextStyle(
                    //         fontFamily: "drawerbody",
                    //         fontStyle: FontStyle.italic,
                    //         color: Colors.black
                    //     )) : SizedBox.shrink(),
                    //
                    // post > 0 ?
                    // Text(post == 1 ? "1 reading" : "$post readings",
                    //     style: TextStyle(
                    //         fontFamily: "drawerbody",
                    //         fontStyle: FontStyle.italic,
                    //         color: Colors.black
                    //     )) : SizedBox.shrink(),
                    //
                    // album > 0 ?
                    // Text(album == 1 ? "1 album" : "$album albums",
                    //     style: TextStyle(
                    //         fontFamily: "drawerbody",
                    //         fontStyle: FontStyle.italic,
                    //         color: Colors.black
                    //     )) : SizedBox.shrink(),

                    // Container(
                    //   height: 40,
                    //   child: Row(
                    //     children: [
                    //
                    //       //reviews
                    //       data[0][0],
                    //       SizedBox(width: 5,),
                    //       Text(data[0][1],
                    //           style: TextStyle(
                    //               color: reviews ? theme.colorScheme.secondary : Colors.grey
                    //           )),
                    //       SizedBox(width: 20,),
                    //
                    //       //readings
                    //       data[1][0],
                    //       SizedBox(width: 5,),
                    //       Text(data[1][1],
                    //           style: TextStyle(
                    //               color: posts ? theme.colorScheme.secondary : Colors.grey
                    //           )),
                    //     ],
                    //   ),
                    // ),
                    //
                    // Container(
                    //   height: 40,
                    //   child: Row(
                    //     children: [
                    //
                    //       //albums
                    //       data[2][0],
                    //       SizedBox(width: 5,),
                    //       Text(data[2][1],
                    //           style: TextStyle(
                    //               color: albums ? theme.colorScheme.secondary : Colors.grey
                    //           )),
                    //       SizedBox(width: 20,),
                    //
                    //       //recordings
                    //       data[3][0],
                    //       SizedBox(width: 5,),
                    //       Text(data[3][1],
                    //           style: TextStyle(
                    //               color: recordings ? theme.colorScheme.secondary : Colors.grey
                    //           )),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )

      // Container(
      //   height: 210,
      //   width: MediaQuery.of(context).size.width,
      //   child: Column(
      //     children: [
      //       Expanded(child: Container()),
      //       //image
      //       Container(
      //         width: MediaQuery.of(context).size.width,
      //         height: 170,
      //         decoration: BoxDecoration(
      //             color: Colors.transparent,
      //             border: Border.all(
      //                 width: 1,
      //                 color: //images.length < 1 ? Colors.grey : Colors.transparent
      //                 Colors.grey
      //             ),
      //             borderRadius: BorderRadius.circular(10)
      //         ),
      //         child: ClipRRect(
      //             borderRadius: BorderRadius.circular(10),
      //             child:
      //             images.length < 1 ?
      //             Center(child: Image.asset("assets/images/logo.png", width: 50, height: 50,)) :
      //             ImageStack(images: images),
      //         ),
      //       ),
      //
      //       //data
      //       Padding(
      //         padding: const EdgeInsets.only(left: 0),
      //         child: Container(
      //           height: 40,
      //           width: MediaQuery.of(context).size.width - 20,
      //           child: Column(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               SizedBox(),
      //               Text(widget.bookName,
      //                   style: TextStyle(
      //                     fontSize: 18,
      //                     fontFamily: "drawerbody",
      //                     fontStyle: FontStyle.italic,
      //                     fontWeight: FontWeight.bold
      //                   ),
      //                   overflow: TextOverflow.ellipsis
      //               ),
      //               SizedBox(),
      //             ],
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}

class ImageStack extends StatefulWidget {
  final List images;
  const ImageStack({Key? key, required this.images}) : super(key: key);

  @override
  State<ImageStack> createState() => _ImageStackState();
}

class _ImageStackState extends State<ImageStack> {
  @override
  Widget build(BuildContext context) {
    return widget.images.length == 4 ?
    Stack(
      children: [

        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
            color: Colors.white,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Stack(
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black38,Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0,0.3]
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Image.network(widget.images[0], fit: BoxFit.cover,),
                ),
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black38,Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0,0.3]
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ],
            ),
          ),
        ),

        Align(
          alignment: Alignment(-0.4,0),
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Stack(
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black38,Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0,0.3]
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Image.network(widget.images[1], fit: BoxFit.cover,),
                ),
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black38,Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0,0.3]
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ],
            ),
          ),
        ),

        Align(
          alignment: Alignment(0.3,0),
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Stack(
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black38,Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0,0.3]
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Image.network(widget.images[2], fit: BoxFit.cover,),
                ),
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black38,Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0,0.3]
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ],
            ),
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Stack(
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black38,Colors.transparent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0,0.3]
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Image.network(widget.images[3], fit: BoxFit.cover,),
                ),
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black38,Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0,0.3]
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    ) :
    widget.images.length == 3 ?
      Stack(
        children: [

          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Stack(
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.black38,Colors.transparent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [0,0.3]
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Image.network(widget.images[0], fit: BoxFit.cover,),
                  ),
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.black38,Colors.transparent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [0,0.3]
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment(-0.1,0),
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Stack(
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.black38,Colors.transparent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [0,0.3]
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Image.network(widget.images[1], fit: BoxFit.cover,),
                  ),
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.black38,Colors.transparent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [0,0.3]
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Stack(
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.black38,Colors.transparent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [0,0.3]
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Image.network(widget.images[2], fit: BoxFit.cover,),
                  ),
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.black38,Colors.transparent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [0,0.3]
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ) :
    Container(
      child: Image.network(widget.images[0], fit: BoxFit.cover,),
    );
  }
}
