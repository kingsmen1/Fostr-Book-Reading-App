import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fostr/models/BookClubModel/BookClubModel.dart';
import 'package:fostr/pages/user/BookClub.dart';
import 'package:fostr/services/BookClubServices.dart';
import 'package:fostr/services/FilePicker.dart';
import 'package:fostr/services/StorageService.dart';
import 'package:fostr/utils/theme.dart';
import 'package:fostr/widgets/RoundedImage.dart';
import 'package:get_it/get_it.dart';

import '../widgets/AppLoading.dart';

class BookClubSettings extends StatefulWidget {
  final BookClubModel bookClubModel;

  const BookClubSettings({Key? key, required this.bookClubModel})
      : super(key: key);

  @override
  _BookClubSettingsState createState() => _BookClubSettingsState();
}

class _BookClubSettingsState extends State<BookClubSettings> with FostrTheme {
  final settingForm = GlobalKey<FormState>();
  var url;
  var file;
  bool newImage = false;
  bool deleting = false;
  bool saving = false;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  String tokenID = '';

  final BookClubServices bookClubServices = GetIt.I<BookClubServices>();

  String clubName = "";
  String clubBio = "";
  String clubImage = "";

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.bookClubModel.bookClubName;
    _bioController.text = widget.bookClubModel.bookClubBio ?? "";
    // setInitialValues();
  }

  void setInitialValues() async {
    await FirebaseFirestore.instance
        .collection("bookclubs")
        .doc(widget.bookClubModel.id)
        .get()
        .then((value) async {
      setState(() {
        clubName = value.get("bookclubName");
        clubBio = value.get("bookclubBio");
        clubImage = value.get("clubProfileimage");

        _nameController.value = TextEditingValue(text: clubName);
        _bioController.value = TextEditingValue(text: clubBio);
      });

      await FirebaseAuth.instance.currentUser!.getIdToken().then((value) {
        tokenID = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        resizeToAvoidBottomInset: true,
        body: Form(
          key: settingForm,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //top bar
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                            )),
                        Text(
                          "Book Club Settings",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                          ),
                        ),
                        saving
                            ? AppLoading(
                                height: 70,
                                width: 70,
                              )
                            :
                            // CircularProgressIndicator(color: GlobalColors.signUpSignInButton,) :
                            IconButton(
                                onPressed: () async {
                                  setState(() {
                                    saving = true;
                                  });
                                  if (settingForm.currentState!.validate()) {
                                    settingForm.currentState!.save();
                                    final newBookClub = widget.bookClubModel;
                                    var authTokenID = await FirebaseAuth
                                        .instance.currentUser!
                                        .getIdToken();
                                    if (newImage) {
                                      url = await Storage.saveBookClubImage(
                                          file, _nameController.text);

                                      newBookClub.bookClubProfile = url;
                                    } else {
                                      newBookClub.bookClubProfile =
                                          widget.bookClubModel.bookClubProfile;
                                    }
                                    newBookClub.bookClubName =
                                        _nameController.text;
                                    newBookClub.bookclubLowerName =
                                        _nameController.text.toLowerCase();
                                    newBookClub.bookClubBio =
                                        _bioController.text;
                                    await bookClubServices.editBookClub({
                                      "id": widget.bookClubModel.id,
                                      "bookClubName": _nameController.text,
                                      "bookClubBio": _bioController.text,
                                      "bookclubLowerName":
                                          _nameController.text.toLowerCase(),
                                      "bookClubProfile": (newImage)
                                          ? url
                                          : widget
                                              .bookClubModel.bookClubProfile,
                                    }, authTokenID);

                                    Navigator.pop(context);
                                  }
                                  setState(() {
                                    saving = false;
                                  });
                                },
                                icon: Icon(
                                  Icons.check,
                                ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),

                  //club image
                  Center(
                    child: InkWell(
                      onTap: () async {
                        try {
                          file = await Files.getFile();
                          print(file.toString().split("'")[1].split("'")[0]);
                          setState(() {
                            newImage = true;
                          });
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: newImage
                          ? Container(
                              width: 80,
                              height: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.file(
                                  File(file
                                      .toString()
                                      .split("'")[1]
                                      .split("'")[0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : RoundedImage(
                              width: 80,
                              height: 80,
                              borderRadius: 40,
                              url: clubImage.isNotEmpty ? clubImage : '',
                            ),
                    ),
                  ),

                  //name
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 10),
                    child: Text(
                      "Name",
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(top: 6, bottom: 9, left: 20, right: 20),
                    child: TextFormField(
                      controller: _nameController,
                      maxLines: 1,
                      validator: (val) =>
                          val!.isEmpty ? 'Please enter book club name' : null,
                      style:
                          h2.copyWith(color: theme.colorScheme.inversePrimary),
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        filled: true,
                        fillColor: theme.inputDecorationTheme.fillColor,
                        hintStyle: new TextStyle(color: Colors.grey[600]),
                        hintText: "Book Club Name",
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                              width: 1, color: theme.colorScheme.secondary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide:
                              BorderSide(width: 0.5, color: Colors.black),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                    ),
                  ),

                  //bio
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 10),
                    child: Text(
                      "About",
                      style: TextStyle(color: theme.colorScheme.inversePrimary),
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(top: 6, bottom: 9, left: 20, right: 20),
                    child: TextFormField(
                      controller: _bioController,
                      maxLength: 100,
                      maxLines: 5,
                      style:
                          h2.copyWith(color: theme.colorScheme.inversePrimary),
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        filled: true,
                        fillColor: theme.inputDecorationTheme.fillColor,
                        hintStyle: new TextStyle(color: Colors.grey[600]),
                        hintText: "Add Bio",
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                              width: 1, color: theme.colorScheme.secondary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide:
                              BorderSide(width: 0.5, color: Colors.black),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).nextFocus(),
                    ),
                  ),
                  // invite only

                  // false ?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            child: Tooltip(
                          triggerMode: TooltipTriggerMode.tap,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          message:
                              "This will make the book club private, Users will have to send request to join",
                          child: Row(
                            children: [
                              Text(
                                "invite only",
                                style: TextStyle(
                                    color: theme.colorScheme.inversePrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Icon(
                                Icons.info_outline,
                                size: 17,
                              )
                            ],
                          ),
                        )),
                        InviteToggle(
                          clubID: widget.bookClubModel.id,
                        ),
                      ],
                    ),
                  ),

                  //delete book club
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 10),
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          deleting = true;
                        });

                        try {
                          final cUser = FirebaseAuth.instance.currentUser;
                          if (cUser!.uid.isNotEmpty) {
                            final token = await cUser.getIdToken();

                            await bookClubServices.deleteBookClub(
                                widget.bookClubModel.id, token);
                            setState(() {
                              deleting = false;
                            });
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          setState(() {
                            deleting = false;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          deleting
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: AppLoading(
                                    height: 70,
                                    width: 70,
                                  )
                                  // CircularProgressIndicator(color: GlobalColors.signUpSignInButton,),
                                  )
                              : Text(
                                  " Delete Book Club",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16),
                                )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InviteToggle extends StatefulWidget {
  final String clubID;
  const InviteToggle({Key? key, required this.clubID}) : super(key: key);

  @override
  _InviteToggleState createState() => _InviteToggleState();
}

class _InviteToggleState extends State<InviteToggle> {
  bool isInviteOnly = false;

  @override
  void initState() {
    super.initState();
  }

  void updateInviteOnly(bool value) async {
    await FirebaseFirestore.instance
        .collection("bookclubs")
        .doc(widget.clubID)
        .update({"isInviteOnly": value});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("bookclubs")
            .doc(widget.clubID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Switch(value: false, onChanged: null);
          }
          return Switch(
              onChanged: (value) {
                updateInviteOnly(value);

                // print("Invite Value : $value");
              },
              value: snapshot.data?.data()?["isInviteOnly"] ?? false,
              activeColor: Color(0xFF2a9d8f),
              inactiveTrackColor: Colors.grey);
        });
  }
}
