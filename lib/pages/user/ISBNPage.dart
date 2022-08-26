import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/Posts/EnterNewPostDetails.dart';
import 'package:fostr/albums/EnterAlbumDetails.dart';
import 'package:fostr/pages/rooms/EnterRoomDetails.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/EnterReviewDetails.dart';
import 'package:fostr/screen/CollectionPage.dart';
import 'package:fostr/widgets/CollectionCard.dart';
import 'package:fostr/widgets/floatingMenu.dart';
import 'package:provider/provider.dart';

class ISBNPage extends StatefulWidget {
  final String title;
  final String description;
  final String image;
  final String authorname;
  final String year;
  final String isbn13;
  const ISBNPage({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.authorname,
    required this.year,
    required this.isbn13
  }) : super(key: key);

  @override
  State<ISBNPage> createState() => _ISBNPageState();
}

class _ISBNPageState extends State<ISBNPage> {

  List bnamelist = [];
  List list = [];
  bool showMore = false;

  @override
  void initState() {
    super.initState();
    getbnamelist();
  }

  void getbnamelist() async {
    await FirebaseFirestore.instance
        .collection("booksearch")
        .get()
        .then((value){
      value.docs.forEach((element) async {
        setState(() {
          bnamelist.add(element.id);
        });
      });
    }).then((value){
      bnamelist.forEach((element) async {
        if(element.toLowerCase().trim().contains(widget.title.toLowerCase().trim()) || widget.title.toLowerCase().trim().contains(element.toLowerCase().trim())){
          setState(() {
            list.add(element);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,

      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        automaticallyImplyLeading: false,
        title: Text(widget.title,
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'drawerbody'
          ),),
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios,)
        ),
        actions: [
          Image.asset(
            "assets/images/logo.png",
            width: 50,
          )
        ],
      ),

      body: Stack(
        children: [

          //image
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width - 150,
              height: MediaQuery.of(context).size.width - 150,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey,width: 2),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: widget.image.isEmpty ?
                  Image.asset("assets/images/logo.png", fit: BoxFit.contain,) :
                  Image.network(widget.image, fit: BoxFit.contain,),
                ),
              ),
            ),
          ),
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: Container(
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.width,
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         colors: [Colors.white10, theme.colorScheme.primary],
          //         begin: Alignment(0,0.7),
          //         end: Alignment.bottomCenter
          //       )
          //     ),
          //   ),
          // ),

          //data
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.width - 250),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [

                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.white10, theme.colorScheme.primary],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter
                              )
                          ),
                        ),

                        Container(
                          color: theme.colorScheme.primary,
                          child: Column(
                            children: [

                              /// title
                              widget.title.isNotEmpty ?
                              widget.title != "No Summary"?
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(widget.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "drawerhead"
                                )
                                  ,),
                              ) : SizedBox.shrink() : SizedBox.shrink(),
                              widget.title.isNotEmpty ?
                              widget.title != "No Summary"?
                              SizedBox(height: 5,) : SizedBox.shrink() : SizedBox.shrink(),


                              ///author
                              widget.authorname.isNotEmpty ?
                              widget.authorname != "No Summary"?
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text("by ${widget.authorname}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                      fontFamily: "drawerbody"
                                  )
                                  ,),
                              ) : SizedBox.shrink() : SizedBox.shrink(),
                              widget.authorname.isNotEmpty ?
                              widget.authorname != "No Summary"?
                              SizedBox(height: 20,) : SizedBox.shrink() : SizedBox.shrink(),

                              ///year and isbn
                              // Row(
                              //   children: [
                              //     Text(
                              //       "Year : " + widget.year.substring(0,4) + "   ISBN :" + widget.isbn13,
                              //       maxLines: 10,
                              //       style: TextStyle(
                              //         fontStyle: FontStyle.italic,
                              //         fontFamily: 'drawerbody',
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(height: 15,),

                              ///description
                              widget.description.isNotEmpty ?
                              widget.description != "No Summary"?
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text("Description -",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                      fontFamily: "drawerhead"
                                  ),textAlign: TextAlign.justify
                                  ,),
                              ) : SizedBox.shrink() : SizedBox.shrink(),
                              widget.description.isNotEmpty ?
                              widget.description != "No Summary"?
                              SizedBox(height: 5,) : SizedBox.shrink() : SizedBox.shrink(),
                              widget.description.isNotEmpty ?
                              widget.description != "No Summary"?
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: showMore ?
                                Text(widget.description,
                                  style: TextStyle(
                                      fontFamily: "drawerbody",
                                  ),textAlign: TextAlign.justify,
                                ) :
                                Text(widget.description,
                                  style: TextStyle(
                                    fontFamily: "drawerbody",
                                  ),
                                  textAlign: TextAlign.justify,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ) : SizedBox.shrink() : SizedBox.shrink(),
                              widget.description.isNotEmpty ?
                              widget.description != "No Summary"?
                              SizedBox(height: 5,) : SizedBox.shrink() : SizedBox.shrink(),

                              ///see more/less
                              widget.description.isNotEmpty ?
                                  widget.description != "No Summary"?
                              GestureDetector(

                                onTap: (){
                                  setState(() {
                                    showMore = !showMore;
                                  });
                                },

                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      Text(showMore ? "show less" : "show more",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            fontFamily: "drawerbody",
                                            fontStyle: FontStyle.italic
                                        )
                                        ,),
                                      SizedBox(width: 3,),
                                      Icon(
                                        !showMore ?
                                        Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded
                                        , size: 20, color: Colors.blue,
                                      )
                                    ],
                                  ),
                                ),
                              ) : SizedBox.shrink() : SizedBox.shrink(),

                              ///create content
                              // SizedBox(height: 10,),
                              // GestureDetector(
                              //
                              //   onTap: (){
                              //     showModalBottomSheet(context: context,
                              //         // transitionAnimationController: _controller,
                              //         enableDrag: true,
                              //         elevation: 10,
                              //         // context: context,
                              //         builder: (context) {
                              //           return CreateContent(
                              //             bookname: widget.title,
                              //             authorname: widget.authorname,
                              //             description: widget.description,
                              //             image: widget.image,
                              //           );
                              //         });
                              //   },
                              //
                              //   child:
                              //   Container(
                              //     width: 200,
                              //     height: 35,
                              //     decoration: BoxDecoration(
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.grey,
                              //           offset: const Offset(
                              //             5.0,
                              //             5.0,
                              //           ),
                              //           blurRadius: 10.0,
                              //           spreadRadius: 2.0,
                              //         ),
                              //       ],
                              //         color: theme.colorScheme.secondary,
                              //         borderRadius: BorderRadius.circular(20)
                              //     ),
                              //     child: Padding(
                              //       padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              //       child: Center(
                              //         child: Text("Create Content",
                              //           style: TextStyle(
                              //             fontSize: 18,
                              //               fontStyle: FontStyle.italic,
                              //               fontFamily: "drawerbody",
                              //             color: Colors.white
                              //           ),),
                              //       ),
                              //     ),
                              //   ),
                              // ),

                              ///collections
                              SizedBox(height: 30,),
                              list.length > 0 ?
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text("Collections -",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: "drawerhead"
                                  ),textAlign: TextAlign.justify
                                  ,),
                              ) : SizedBox.shrink(),
                              list.length > 0 ? SizedBox(height: 15,) : SizedBox.shrink(),
                              (list.isEmpty) ?
                              SizedBox.shrink() :
                              ListView.separated(
                                  itemCount: list.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index){

                                    return CollectionCard(bookName: list[index]);

                                  },
                                separatorBuilder: (BuildContext context, int index) {
                                  return //index != list.length ?
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width - 20,
                                        height: 1,
                                        color: Colors.grey,
                                      ),
                                    ) ;
                                  // ) : SizedBox.shrink();
                              },
                                  ),

                              SizedBox(height: 100,),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                ),
              ),
            ),
          ),

        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: GestureDetector(

        onTap: (){
          showModalBottomSheet(context: context,
              // transitionAnimationController: _controller,
              enableDrag: true,
              elevation: 10,
              // context: context,
              builder: (context) {
                return CreateContent(
                  bookname: widget.title,
                  authorname: widget.authorname,
                  description: widget.description,
                  image: widget.image,
                );
              });
        },

        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: const Offset(
                    5.0,
                    5.0,
                  ),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ),
              ],
              color: theme.colorScheme.secondary,
              shape: BoxShape.circle
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            child: Center(
              child: Text("+",
                style: TextStyle(
                    fontSize: 30,
                    fontFamily: "drawerbody",
                    color: Colors.white
                ),),
            ),
          ),
        ),
      ),

    );
  }
}

class CreateContent extends StatefulWidget {
  final String bookname;
  final String authorname;
  final String description;
  final String image;
  const CreateContent({
    Key? key,
    required this.bookname,
    required this.authorname,
    required this.description,
    required this.image,
  }) : super(key: key);

  @override
  State<CreateContent> createState() => _CreateContentState();
}

class _CreateContentState extends State<CreateContent> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "What would you like to create?",
          style: TextStyle(fontFamily: "drawerhead", fontSize: 22),
          textAlign: TextAlign.center,
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              FontAwesomeIcons.chevronDown,
              size: 20,
            )),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 400,
              child: GridView(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 20,
                    crossAxisCount: 2),
                children: [

                  //room/theatre
                  CircleButton(
                    icon: Icon(
                      Icons.mic,
                      color: Colors.grey.shade600,
                      size: 50,
                    ),
                    onPressed: () {

                      Navigator.pop(context);
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => EnterRoomDetails(
                            bookname: widget.bookname,
                            authorname: widget.authorname,
                            description: widget.description,
                            image: widget.image,
                          )
                      ));
                    },
                    text: Text("Room/Theatre"),
                  ),

                  //album
                  CircleButton(
                    icon: Icon(
                      Icons.album_outlined,
                      color: Colors.grey.shade600,
                      size: 50,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => EnterAlbumDetails(
                            bookname: widget.bookname,
                            authorname: widget.authorname,
                            description: widget.description,
                            image: widget.image,
                          )));
                    },
                    text: Text("Album"),
                  ),

                  //bit
                  CircleButton(
                    icon: SvgPicture.asset("assets/icons/grey_Bits.svg",width: 40, height: 40,),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => EnterReviewDetails(
                            bookname: widget.bookname,
                            authorname: widget.authorname,
                            description: widget.description,
                            image: widget.image,
                          )));
                    },
                    text: Text("Reviews"),
                  ),

                  //reading
                  CircleButton(
                    icon: Icon(
                      Icons.post_add,
                      color: Colors.grey.shade600,
                      size: 50,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) =>
                              EnterNewPostDetails(
                                  user: auth.user!,
                                bookname: widget.bookname,
                                authorname: widget.authorname,
                                description: widget.description,
                                image: widget.image,
                              )));
                    },
                    text: Text("Readings"),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}