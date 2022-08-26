import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/core/data.dart';
import 'package:fostr/utils/theme.dart';
import 'package:intl/intl.dart';

class UpcomingEvent extends StatelessWidget {
  const UpcomingEvent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: roomCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text("No Upcoming Events");
          }
          return Container(
            height: 200,
            child: ListView.builder(
              // physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                // print(snapshot.data?.docs[index].id);
                // if(snapshot.data?.docs[index].id != null){
                  return UpcomingCard(id:snapshot.data!.docs[index].id);
                // }
                // else{
                //   return Text("No Upcoming Events");
                // }

              },
            ),
          );
        },
      ),
    );
  }
}

class UpcomingCard extends StatefulWidget {
  const UpcomingCard({Key? key, required this.id}) : super(key: key);
  final String id;
  @override
  _UpcomingCardState createState() => _UpcomingCardState();
}

class _UpcomingCardState extends State<UpcomingCard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('rooms/${widget.id}/rooms').orderBy('dateTime', descending: true).where("isUpcoming",isEqualTo:true).where("isActive",isEqualTo: true)
            .get(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 0,
              width: 0,
            );
          }
          print(snapshot.data!.size);
          return CarouselSlider(
            options: CarouselOptions(
              enlargeCenterPage: true,
              // aspectRatio: MediaQuery.of(context).size.width/180,
              aspectRatio: 10 / 5,
              viewportFraction: .8,
              enableInfiniteScroll: false,
            ),

            items: snapshot.data!.docs.map((i) {

              final data = i.data();

              return data["isUpcoming"] == true ?  Builder(

                builder: (BuildContext context) {
                  // var checkIsDate = data['datetime'];
                  // DateTime tempDate = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(checkIsDate);
                  // var inputDate = DateTime.parse(tempDate.toString());
                  // var outputFormat = DateFormat('yMMMd');
                  return DefaultTextStyle(
                    style: TextStyle(color: Colors.white),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: data["image"] == ""
                                    ? Image.asset(IMAGES + "logo_white.png")
                                    .image
                                    : NetworkImage(data['image'])),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                gradientBottom,
                                gradientTop,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.9)
                                ],
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Text(data['title'],
                                        overflow: TextOverflow.fade,
                                        maxLines: 2,
                                        softWrap: false,
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.18,),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration( color: Colors.black45,
                                        border: Border.all(width: 1, color: Colors.black),
                                        borderRadius: BorderRadius.circular(24)),
                                    child: Text(data['genre'],style: TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              Text("By "+data['roomCreator'],
                                  style: TextStyle(
                                    color: Colors.white, )),
                              const SizedBox(
                                height: 28,
                              ),
                              Text(data['dateTime'].toDate().toString().substring(0,16)
                                ,style: TextStyle(fontSize: 18),),
                              // const SizedBox(
                              //   height: 12,
                              // ),
                              // Row(
                              //   children: [
                              //     Text(data['dateTime'].toString().substring(11,16)
                              //       ,style: TextStyle(fontSize: 18),),
                              //     Text("  HRS"
                              //       ,style: TextStyle(fontSize: 18),),
                              //   ],
                              // ),
                            ],
                          ),
                        )),
                  );
                },
              ):SizedBox.shrink();
            }).toList(),
          );
        });
  }
}

class UpcomingEventCard extends StatelessWidget {
  const UpcomingEventCard(
      {required this.imageUrl, required this.title, required this.genre});
  final String title, genre, imageUrl;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 16,
            ),
            Text(title),
            const SizedBox(
              height: 8,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(width: 2),
                  borderRadius: BorderRadius.circular(24)),
              child: Text(genre),
            )
          ],
        ),
      ),
    );
  }
}
