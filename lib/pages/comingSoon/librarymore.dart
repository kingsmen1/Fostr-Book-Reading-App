import 'package:flutter/material.dart';

class LibraryMore extends StatefulWidget {
  final String image, title, publisher, pubdate, desc;
  const LibraryMore({ Key? key, required this.image, required this.title, required this.publisher, required this.pubdate, required this.desc }) : super(key: key);

  @override
  _LibraryMoreState createState() => _LibraryMoreState();
}

class _LibraryMoreState extends State<LibraryMore> {
  @override
  // String image="", title="",publisher="",pubdate="",desc="";
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Book Details'),
        backgroundColor: Colors.black,
        leading: GestureDetector(
              child: Icon(Icons.arrow_back_ios, color: Colors.white,),
              onTap: (){
                Navigator.pop(context);
              },
            ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                                        padding: EdgeInsets.all(10.0),
                                        height: MediaQuery.of(context).size.height * 0.3,
                                        width: MediaQuery.of(context).size.width * 1,
                                        color: Colors.black,
                                          child: Stack(children: [

                                            Positioned(
                                              top: 30,
                                              child: Container(
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                              color: Colors.grey.shade900,

                                              ),
                                              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5,
                                                maxWidth: MediaQuery.of(context).size.width * 1,),
                                            )),




                                            Positioned(
                                              top: 10,
                                              left: 20,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image(
                                                  image: NetworkImage("${widget.image}"),
                                                  fit: BoxFit.fill,
                                                  height: 150,
                                                  width: 100
                                                ),
                                              ),

                                            ),

                                            Positioned(
                                              top: 50,
                                              left: 130,
                                              child: Container(
                                                padding: EdgeInsets.only(right: 40),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                  Text("${widget.title}", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                                                  SizedBox(height: 20,),
                                                  Text("By - ${widget.publisher}", style: TextStyle(color: Colors.white70, fontSize: 12),),
                                                  SizedBox(height: 20,),
                                                  Text("Published In - ${widget.pubdate}", style: TextStyle(color: Colors.white70, fontSize: 12),),
                                                  SizedBox(height: 20,),
                                                  //Text("Elisabeth Young-Bruehl illuminates the psychological and intellectual demands writing biography makes on the biographer and explores the complex and frequently conflicted relationship between feminism and psychoanalysis. She considers what remains valuable in Sigmund Freud's work, and what areas - theory of character, for instance - must be rethought to be useful for current psychoanalytic work, for feminist studies, and for social theory. Psychoanalytic theory used for biography, she argues, can yield insights for psychoanalysis itself, particularly in the understanding of creativity.", style: TextStyle(color: Colors.white,fontSize: 1), overflow: TextOverflow.ellipsis,)
                                                ],),
                                              )
                                            ),
                                          ],
                                        ),
                                      ),
                SizedBox(height: 20.0,),
                Container(padding: EdgeInsets.all(10), child: Text("About :", style: TextStyle(color: Colors.white, fontSize: 30))),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text("${widget.desc}",textAlign: TextAlign.justify, style: TextStyle(color: Colors.white70, fontSize: 20),)
                ),
              ],
            ),
          )
        ),
    );
  }
}