import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart' as constant;
import 'package:fostr/pages/user/HomePage.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/router/router.dart';
import 'package:fostr/router/routes.dart';
import 'package:provider/provider.dart';

class EULA extends StatefulWidget {
  final bool isOnboarding;
  final String userid;
  const EULA({required this.userid, required this.isOnboarding, Key? key}) : super(key: key);

  @override
  State<EULA> createState() => _EULAState();
}

class _EULAState extends State<EULA> {

  bool agree = false;
  bool onboarding = false;
  String eula = "";

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
    .collection('config')
    .doc('EULA')
    .get()
    .then((value){
      setState(() {
        eula = value['eula'];
      });
    });
    checkIfUserAlreadyAgreed(widget.userid);

  }
  
  void checkIfUserAlreadyAgreed(String userid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('eulaAgreed')
        .where('id', isEqualTo: userid)
        .limit(1)
        .get()
        .then((value){
          if(value.docs.length == 1){
            if(value.docs.first['eulaAgreed']){
              setState(() {
                agree = true;
              });
            } else {
              setState(() {
                agree = false;
              });
            }
          } else {
            setState(() {
              agree = false;
            });
          }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        automaticallyImplyLeading: false,
        title: Text("",
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
        child: Column(
          children: [
            
            //heading
            Text("End User License Agreement",
              style: TextStyle(
                fontFamily: 'drawerhead',
                color: theme.colorScheme.inversePrimary,
                fontSize: 20,
              ),),
            SizedBox(height: 10,),

            //box
            Container(
              width: MediaQuery.of(context).size.width - 50,
              height: MediaQuery.of(context).size.height -  200,
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  border: Border.all(
                      color: Colors.transparent,
                      width: 1
                  ),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                children: [

                  //guidelines
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                              color: Colors.grey,
                              width: 0.5
                          ),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Text(eula,
                            style: TextStyle(
                              fontFamily: 'drawerbody',
                              color: theme.colorScheme.inversePrimary,
                              fontSize: 13,
                            ),),
                        ),
                      ),
                    ),
                  ),

                  //agree
                  Row(
                    children: [

                      Checkbox(
                        activeColor: theme.colorScheme.secondary,
                        shape: RoundedRectangleBorder(),
                        value: this.agree,
                        onChanged: (value) {
                          print(value);
                          setState(() {
                            this.agree = value!;
                          });
                        },
                      ),

                      Text(
                        "I agree with the terms and guidelines.",
                        style: TextStyle(
                            color: theme.colorScheme.inversePrimary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic
                        ),
                      )
                    ],
                  ),

                  //done
                  RaisedButton(
                    onPressed: () async {

                      if(agree){
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.id)
                             .set({
                          'eulaAgreed' : true,
                          'eulaDateTime' : DateTime.now()
                        }, SetOptions(merge: true));
                      } else {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.id)
                            .set({
                          'eulaAgreed' : false,
                          'eulaDateTime' : DateTime.now()
                        }, SetOptions(merge: true));
                      }

                      widget.isOnboarding?
                      Navigator.push(context, MaterialPageRoute(builder: (context)
                      => UserDashboard(
                          tab: 'all',
                          isOnboarding: true,
                          selectDay: DateTime.now()
                      )
                      )) :
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: theme.colorScheme.secondary,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
