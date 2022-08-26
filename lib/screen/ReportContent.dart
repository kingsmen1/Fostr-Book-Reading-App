import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/ToastMessege.dart';
import 'package:provider/provider.dart';

class ReportContent extends StatefulWidget {
  final String contentId;
  final String contentType;
  final String contentOwnerId;

  const ReportContent({
    required this.contentId,
    required this.contentType,
    required this.contentOwnerId,
    Key? key
  }) : super(key: key);

  @override
  State<ReportContent> createState() => _ReportContentState();
}

class _ReportContentState extends State<ReportContent>  with FostrTheme {

  String reason = "Violence";
  TextEditingController commentController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);

    return SafeArea(
        child: Scaffold(
          backgroundColor: theme.colorScheme.primary,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: theme.colorScheme.primary,
            automaticallyImplyLeading: false,
            title: Text(widget.contentType == "Profile" ? "Report Profile" : "Report Content",
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
              Icon(Icons.flag, color: Colors.red,)
            ],
          ),

          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    //let us know
                    Container(
                      width: MediaQuery.of(context).size.width - 20,
                      child: Text(widget.contentType == "Profile" ?
                      "Let us know why, according to you, this profile is not suitable for this platform." :
                        "Let us know why, according to you, this content is not suitable for this platform.",
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'drawerbody'
                        ),),
                    ),

                    //violence
                    ListTile(
                      title: Text("Violence"),
                      leading: Radio(
                          value: "Violence",
                          activeColor: theme.colorScheme.secondary,
                          groupValue: reason,
                          onChanged: (value){
                            setState(() {
                              reason = value.toString();
                            });
                          }),
                    ),
                    //Fake News
                    ListTile(
                      title: Text("Fake News"),
                      leading: Radio(
                          value: "Fake News",
                          activeColor: theme.colorScheme.secondary,
                          groupValue: reason,
                          onChanged: (value){
                            setState(() {
                              reason = value.toString();
                            });
                          }),
                    ),
                    //Hate Speech
                    ListTile(
                      title: Text("Hate Speech"),
                      leading: Radio(
                          value: "Hate Speech",
                          activeColor: theme.colorScheme.secondary,
                          groupValue: reason,
                          onChanged: (value){
                            setState(() {
                              reason = value.toString();
                            });
                          }),
                    ),
                    //Racial Hatred
                    ListTile(
                      title: Text("Racial Hatred"),
                      leading: Radio(
                          value: "Racial Hatred",
                          activeColor: theme.colorScheme.secondary,
                          groupValue: reason,
                          onChanged: (value){
                            setState(() {
                              reason = value.toString();
                            });
                          }),
                    ),
                    //Sexually Explicit
                    ListTile(
                      title: Text("Sexually Explicit"),
                      leading: Radio(
                          value: "Sexually Explicit",
                          activeColor: theme.colorScheme.secondary,
                          groupValue: reason,
                          onChanged: (value){
                            setState(() {
                              reason = value.toString();
                            });
                          }),
                    ),
                    //Copyright Violation
                    ListTile(
                      title: Text("Copyright Violation"),
                      leading: Radio(
                          value: "Copyright Violation",
                          activeColor: theme.colorScheme.secondary,
                          groupValue: reason,
                          onChanged: (value){
                            setState(() {
                              reason = value.toString();
                            });
                          }),
                    ),
                    //others
                    ListTile(
                      title: Text("Others"),
                      leading: Radio(
                          value: "Others",
                          activeColor: theme.colorScheme.secondary,
                          groupValue: reason,
                          onChanged: (value){
                            setState(() {
                              reason = value.toString();
                            });
                          }),
                    ),

                    //comment box
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: commentController,
                        style: h2.copyWith(
                            color: theme.colorScheme.inversePrimary),
                        maxLength: 500,
                        maxLines: 5,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15.0),
                            ),
                          ),
                          filled: true,
                          hintText: "Share comment",
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide(
                                width: 0.5, color: Colors.transparent),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        autofocus: false,
                        onEditingComplete: () =>
                            FocusScope.of(context).nextFocus(),
                      ),
                    ),

                    //report button
                    GestureDetector(

                      onTap: () async {

                        const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                        Random _rnd = Random();

                        String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
                            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

                        await FirebaseFirestore.instance
                            .collection('content moderation')
                            .doc()
                            .collection(widget.contentType)
                            .doc(widget.contentId)
                            .set({
                          'uniqueId' : getRandomString(12),
                          'contentId' : widget.contentId,
                          'contentType' : widget.contentType,
                          'typeOfViolation' : reason,
                          'comment' : commentController.text,
                          'contentOwnerUserId' : widget.contentOwnerId,
                          'reportedByUserId' : auth.user!.id,
                          'dateTime' : DateTime.now()
                        },SetOptions(merge: true)).then((value){
                          ToastMessege(widget.contentType == "Profile" ? 'Profile reported' : 'Content reported.', context: context);
                          Navigator.pop(context);
                        });

                      },

                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(25)
                        ),
                        child: Center(
                          child: Text(
                            "Report",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}
