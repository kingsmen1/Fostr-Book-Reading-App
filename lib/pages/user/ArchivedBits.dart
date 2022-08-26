import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/SingleReviewCard.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:provider/provider.dart';

class ArchivedBits extends StatefulWidget {
  const ArchivedBits({Key? key}) : super(key: key);

  @override
  _ArchivedBitsState createState() => _ArchivedBitsState();
}

class _ArchivedBitsState extends State<ArchivedBits> {

  // void abc(){
  //   FirebaseFirestore.instance
  //       .collection("Archive Bits")
  //       .doc(auth.user!.id).snapshots()
  // }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: Text("Archived Bits",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "drawerhead"
          ),),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white,size: 30,)
          ),
          actions: [
            Image.asset("assets/images/logo.png",width: 50,height: 50,)
          ],
        ),

        body: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
          stream: FirebaseFirestore.instance
          .collection("Archive Bits")
          .doc(auth.user!.id)
          .collection("bits")
          .snapshots(),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return SizedBox.shrink();
            }

            switch(snapshot.connectionState){
              case ConnectionState.waiting:
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: AppLoading(
                      width: 70,
                      height: 70,
                    ),
                  ),
                );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.only(bottom: 70),
              itemCount: snapshot.data!.docs.length + 1,
              itemBuilder: (context, index) {
                if(snapshot.data!.docs.length == 0){
                  return Text("no archived bits",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic
                  ),);
                }
                if (index == snapshot.data!.docs.length) {
                  return Container(
                    height: 100,
                  );
                }
                return SingleReviewCard(
                  key: Key(snapshot.data!.docs[index].id),
                  id: snapshot.data!.docs[index].id,
                  uid: auth.user!.id,
                  reviewData: snapshot.data?.docs[index].data() ?? {},
                );
              },
            );
          },
        ),
      ),
    );
  }
}
