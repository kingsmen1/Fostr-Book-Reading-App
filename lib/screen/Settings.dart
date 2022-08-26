


import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/pages/onboarding/LoginPage.dart';
import 'package:fostr/pages/onboarding/UpdateEmail.dart';
import 'package:fostr/pages/onboarding/UpdatePhoneDetails.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/Eula.dart';
import 'package:fostr/screen/ProfileSettings.dart';
import 'package:fostr/utils/dynamic_links.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/CheckboxFormField.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with FostrTheme{



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).user;
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 50),
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
                      'Settings',
                      style: TextStyle(fontSize: 20,color: Colors.black,fontFamily: "drawerhead"),
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
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 40,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      // AppBar(
      //   elevation: 0,
      //   backgroundColor: dark_blue,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   title: Text(
      //     'Settings',
      //     style: TextStyle(fontSize: 20,color: Colors.white,fontFamily: "drawerhead"),
      //   ),
      // ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //       colors: [
        //         dark_blue,
        //         theme.colorScheme.primary
        //         //Color(0xFF2E3170)
        //       ],
        //       begin : Alignment.topCenter,
        //       end : Alignment(0,0.5),
        //       stops: [0,0.92]
        //   ),
        // ),
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: [

            //personal info
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ProfileSettings(),
                  ),
                );
              },
              title: Text(
                'Personal Information',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(
                Icons.chevron_right,
              ),
            ),
            Divider(),

            //Update Phone Number
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => UpdatePhoneDetails(
                      fromSettings: true,
                    ),
                  ),
                );
              },
              title: Text(
                'Update Phone Number',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(
                Icons.chevron_right,
              ),
            ),
            Divider(),

            //Update Email
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => UpdateEmailDetails(fromSettings: true),
                  ),
                );
              },
              title: Text(
                'Update Email',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(
                Icons.chevron_right,
              ),
            ),
            Divider(),

            //Share your profile
            ListTile(
              onTap: () async {
                final url = await DynamicLinksApi.fosterUserLink(
                    userId: user!.id, name: user.name);
                try {
                  Share.share(url);
                } catch (e) {
                  ToastMessege("Couldn't share your profile", context: context);
                }
              },
              title: Text(
                'Share your profile',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(
                Icons.chevron_right,
              ),
            ),
            Divider(),

            //EULA
            ListTile(
              onTap: () async {

                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => EULA(userid: user!.id,isOnboarding: false,),
                  ),
                );

                // showGeneralDialog(
                //     context: context,
                //     barrierDismissible: true,
                //     barrierLabel: MaterialLocalizations.of(context)
                //         .modalBarrierDismissLabel,
                //     barrierColor: Colors.black45,
                //     transitionDuration: const Duration(milliseconds: 200),
                //     pageBuilder: (BuildContext buildContext,
                //         Animation animation,
                //         Animation secondaryAnimation) {
                //       return Center(
                //         child: Container(
                //           width: MediaQuery.of(context).size.width - 50,
                //           height: MediaQuery.of(context).size.height -  200,
                //           padding: EdgeInsets.all(20),
                //           decoration: BoxDecoration(
                //             color: theme.colorScheme.primary,
                //             border: Border.all(
                //               color: theme.colorScheme.secondary,
                //               width: 1
                //             ),
                //             borderRadius: BorderRadius.circular(10)
                //           ),
                //           child: Column(
                //             children: [
                //
                //               //guidelines
                //               Container(
                //                 width: MediaQuery.of(context).size.width,
                //                 decoration: BoxDecoration(
                //                     color: Colors.transparent,
                //                     border: Border.all(
                //                         color: Colors.grey,
                //                         width: 0.5
                //                     ),
                //                     borderRadius: BorderRadius.circular(10)
                //                 ),
                //                 child: SingleChildScrollView(
                //                   child: Text("",
                //                   style: TextStyle(
                //                     fontFamily: 'drawerbody',
                //                     color: theme.colorScheme.inversePrimary,
                //                     fontSize: 12,
                //                   ),),
                //                 ),
                //               ),
                //
                //               //agree
                //               Row(
                //                 children: [
                //
                //                   Text(
                //                     "I agree with the terms and guidelines.",
                //                     style: TextStyle(
                //                         color: theme.colorScheme.inversePrimary,
                //                       fontSize: 12,
                //                       fontStyle: FontStyle.italic
                //                     ),
                //                   )
                //                 ],
                //               ),
                //
                //               //go back
                //               RaisedButton(
                //                 onPressed: () {
                //                   Navigator.of(context).pop();
                //                 },
                //                 child: Text(
                //                   "Go back",
                //                   style: TextStyle(color: Colors.white),
                //                 ),
                //                 color: theme.colorScheme.secondary,
                //               )
                //             ],
                //           ),
                //         ),
                //       );
                //     });
              },
              title: Text(
                'EULA (End User License Agreement)',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(
                Icons.chevron_right,
              ),
            ),
            Divider(),

            //delete account
            ListTile(
              onTap: () async {
                await confirmDialog(context, h2);
              },
              title: Text(
                'Delete Account',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Icon(
                Icons.chevron_right,
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
Future<bool?> confirmDialog(BuildContext context, TextStyle h2) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final theme = Theme.of(context);
      final auth = Provider.of<AuthProvider>(context);
      final size = MediaQuery.of(context).size;
      return Container(
        height: size.height,
        width: size.width,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Align(
            alignment: Alignment(0, 0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: size.width * 0.9,
                constraints: BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to delete this account permanently?',
                      style: h2.copyWith(
                        fontSize: 15.sp,
                        color: theme.colorScheme.inversePrimary,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            )),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                theme.colorScheme.secondary),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            "Cancel",
                            style: h2.copyWith(
                              fontSize: 17.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            )),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                theme.colorScheme.secondary),
                          ),
                          onPressed: (){
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(auth.user!.id)
                                .set({
                              'accDeleted' : true
                            }, SetOptions(merge: true)).then((value) async {
                              await auth.firebaseUser!.delete().then((value){
                                print('user deleted');
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => LoginPage()),
                                        (Route<dynamic> route) => false);
                                ToastMessege('Account deleted successfully', context: context);
                              });
                            });
                          },
                          child: Text(
                            "Delete",
                            style: h2.copyWith(
                              fontSize: 17.sp,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}