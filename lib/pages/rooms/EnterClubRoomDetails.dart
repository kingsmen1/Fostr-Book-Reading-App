// import 'package:date_time_picker/date_time_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:fostr/core/constants.dart';
// import 'package:fostr/pages/clubOwner/dashboard.dart';
// import 'package:fostr/providers/AuthProvider.dart';
// import 'package:fostr/services/FilePicker.dart';
// import 'package:fostr/services/RoomService.dart';
// import 'package:fostr/services/StorageService.dart';
// import 'package:fostr/utils/theme.dart';
// import 'package:fostr/utils/widget_constants.dart';
// import 'package:get_it/get_it.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// class EnterClubRoomDetails extends StatefulWidget {
//   @override
//   _EnterClubRoomDetailsState createState() => _EnterClubRoomDetailsState();
// }
//
// class _EnterClubRoomDetailsState extends State<EnterClubRoomDetails>
//     with FostrTheme {
//   // String now = DateFormat('yyyy-MM-dd').format(DateTime.now()) +
//   //     " " +
//   //     DateFormat.Hm().format(DateTime.now());
//   DateTime now = DateTime.now().toUtc();
//   TextEditingController eventNameTextEditingController =
//       new TextEditingController();
//   TextEditingController withTextEditingController = new TextEditingController();
//   TextEditingController addAuthorTextEditingController =
//       new TextEditingController();
//   TextEditingController dateTextEditingController = new TextEditingController();
//   TextEditingController timeTextEditingController = new TextEditingController();
//   TextEditingController agendaTextEditingController =
//       new TextEditingController();
//   String image = "Select Image", imageUrl = "";
//   bool isLoading = false, scheduling = false;
//   bool  _switchValueHumanLibrary=false;
//
//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthProvider>(context);
//     final user = auth.user!;
//     print(user.userName);
//     return Material(
//       color: gradientBottom,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//             horizontal: MediaQuery.of(context).size.width * 0.03),
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: Image.asset(IMAGES + "background.png").image,
//             fit: BoxFit.cover,
//           ),
//           borderRadius: BorderRadiusDirectional.only(
//             topStart: Radius.circular(32),
//             topEnd: Radius.circular(32),
//           ),
//           color: Colors.white,
//         ),
//         child: ListView(
//           children: [
//             Container(
//               alignment: Alignment.topCenter,
//               child: Column(
//                 children: [
//                   // SizedBox(
//                   //   height: MediaQuery.of(context).size.height*0.03,
//                   // ),
//                   // Text(
//                   //   'Schedule a Room',
//                   //   style: h1
//                   // ),
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.05,
//                   ),
//                   SingleChildScrollView(
//                     //key: formKey,
//                     child: Column(
//                       children: [
//                         TextFormField(
//                           controller: eventNameTextEditingController,
//                           style: h2,
//                           decoration: InputDecoration(
//                             hintText: "Event Name",
//                             hintStyle: TextStyle(
//                               color: Color(0xff476747),
//                             ),
//                             border: InputBorder.none,
//                           ),
//                           textInputAction: TextInputAction.next,
//                           onEditingComplete: () =>
//                               FocusScope.of(context).nextFocus(),
//                         ),
//                         Divider(
//                           height: 0.5,
//                           color: Colors.grey,
//                         ),
//                         TextFormField(
//                           controller: withTextEditingController,
//                           style: h2,
//                           decoration: InputDecoration(
//                             hintText: "With",
//                             hintStyle: TextStyle(
//                               color: Color(0xff476747),
//                             ),
//                             border: InputBorder.none,
//                           ),
//                           textInputAction: TextInputAction.next,
//                           onEditingComplete: () =>
//                               FocusScope.of(context).nextFocus(),
//                         ),
//                         Divider(
//                           height: 0.5,
//                           color: Colors.grey,
//                         ),
//                         TextFormField(
//                           controller: addAuthorTextEditingController,
//                           style: h2,
//                           decoration: InputDecoration(
//                             hintText: "Author name",
//                             hintStyle: TextStyle(
//                               color: Color(0xff476747),
//                             ),
//                             border: InputBorder.none,
//                           ),
//                           textInputAction: TextInputAction.next,
//                           onEditingComplete: () =>
//                               FocusScope.of(context).nextFocus(),
//                         ),
//                         Divider(
//                           height: 0.5,
//                           color: Colors.grey,
//                         ),
//                         TextFormField(
//                           controller: agendaTextEditingController,
//                           style: h2,
//                           decoration: InputDecoration(
//                             hintText: "Agenda for the meeting is...",
//                             hintStyle: TextStyle(
//                               color: Color(0xff476747),
//                             ),
//                             border: InputBorder.none,
//                           ),
//                           textInputAction: TextInputAction.next,
//                           onEditingComplete: () =>
//                               FocusScope.of(context).nextFocus(),
//                         ),
//                         Divider(
//                           height: 0.5,
//                           color: Colors.grey,
//                         ),
//                         DateTimePicker(
//                           type: DateTimePickerType.date,
//                           dateMask: 'yyyy/MM/dd',
//                           controller: dateTextEditingController,
//                           firstDate: DateTime.now(),
//                           lastDate: DateTime(2100),
//                           icon: Icon(Icons.event, color: Color(0xff476747)),
//                           dateLabelText: 'Date',
//                           use24HourFormat: false,
//                           onChanged: (val) => setState(
//                               () => dateTextEditingController.text = val),
//                           // validator: (val) {
//                           //   setState(() => _valueToValidate2 = val ?? '');
//                           //   return null;
//                           // },
//                           // onSaved: (val) => setState(() => _valueSaved2 = val ?? ''),
//                         ),
//                         Divider(
//                           height: 0.5,
//                           color: Colors.grey,
//                         ),
//                         DateTimePicker(
//                           type: DateTimePickerType.time,
//                           controller: timeTextEditingController,
//                           icon:
//                               Icon(Icons.access_time, color: Color(0xff476747)),
//                           timeLabelText: "Time",
//                           initialTime: TimeOfDay.now(),
//                           onChanged: (val) => setState(
//                               () => timeTextEditingController.text = val),
//                           // validator: (val) {
//                           //   setState(() => _valueToValidate4 = val ?? '');
//                           //   return null;
//                           // },
//                           // onSaved: (val) => setState(() => _valueSaved4 = val ?? ''),
//                         ),
//                         Divider(
//                           height: 0.5,
//                           color: Colors.grey,
//                         ),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(image, style: h2, overflow: TextOverflow.clip),
//                             Spacer(),
//                             isLoading
//                                 ?
//                             Image.asset(
//                               "assets/images/loading.gif",
//                               width: 70,
//                               height: 70,
//                             )
//                             // CircularProgressIndicator(
//                             //         color: GlobalColors.signUpSignInButton,
//                             //       )
//                                 : IconButton(
//                                     onPressed: () async {
//                                       if (eventNameTextEditingController
//                                           .text.isNotEmpty) {
//                                         setState(() {
//                                           isLoading = true;
//                                         });
//                                         try {
//                                           final file = await Files.getFile();
//                                           if (file['file'] != null) {
//                                             final croppedFile =
//                                                 await ImageCropper().cropImage(
//                                               sourcePath: file['file'].path,
//                                               maxHeight: 150,
//                                               maxWidth: 150,
//                                               aspectRatio: CropAspectRatio(
//                                                   ratioX: 1, ratioY: 1),
//                                             );
//
//                                             if (croppedFile != null) {
//                                               imageUrl =
//                                                   await Storage.saveRoomImage(
//                                                       {
//                                                     "file": croppedFile,
//                                                     "ext": file["ext"]
//                                                   },
//                                                       eventNameTextEditingController
//                                                           .text);
//                                               setState(() {
//                                                 isLoading = false;
//                                                 image = file['file']
//                                                     .toString()
//                                                     .substring(
//                                                         file['file']
//                                                                 .toString()
//                                                                 .lastIndexOf(
//                                                                     '/') +
//                                                             1,
//                                                         file['file']
//                                                                 .toString()
//                                                                 .length -
//                                                             1);
//                                               });
//                                             } else {
//                                               setState(() {
//                                                 isLoading = false;
//                                               });
//                                             }
//                                           }
//                                         } catch (e) {
//                                           print(e);
//                                           setState(() {
//                                             isLoading = true;
//                                           });
//                                         }
//                                       } else {
//                                         Fluttertoast.showToast(
//                                             msg: "Event Name is required!",
//                                             toastLength: Toast.LENGTH_SHORT,
//                                             gravity: ToastGravity.BOTTOM,
//                                             timeInSecForIosWeb: 1,
//                                             backgroundColor: gradientBottom,
//                                             textColor: Colors.white,
//                                             fontSize: 16.0);
//                                       }
//                                     },
//                                     icon: Icon(
//                                       Icons.add_circle_outline_rounded,
//                                       color: Color(0xff476747),
//                                     ),
//                                   )
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * 0.03,
//                   ),
//                   scheduling
//                       ?
//                   Image.asset(
//                     "assets/images/loading.gif",
//                     width: 70,
//                     height: 70,
//                   )
//                   // CircularProgressIndicator(color:GlobalColors.signUpSignInButton)
//                       : ElevatedButton(
//                           child: Text('Schedule Room'),
//                           onPressed: () async {
//                             if (eventNameTextEditingController.text.isEmpty) {
//                               Fluttertoast.showToast(
//                                   msg: "Event Name is required!",
//                                   toastLength: Toast.LENGTH_SHORT,
//                                   gravity: ToastGravity.BOTTOM,
//                                   timeInSecForIosWeb: 1,
//                                   backgroundColor: gradientBottom,
//                                   textColor: Colors.white,
//                                   fontSize: 16.0);
//                             } else if (dateTextEditingController.text.isEmpty) {
//                               Fluttertoast.showToast(
//                                   msg: "Date is required!",
//                                   toastLength: Toast.LENGTH_SHORT,
//                                   gravity: ToastGravity.BOTTOM,
//                                   timeInSecForIosWeb: 1,
//                                   backgroundColor: gradientBottom,
//                                   textColor: Colors.white,
//                                   fontSize: 16.0);
//                             } else if (timeTextEditingController.text.isEmpty) {
//                               Fluttertoast.showToast(
//                                   msg: "Time is required!",
//                                   toastLength: Toast.LENGTH_SHORT,
//                                   gravity: ToastGravity.BOTTOM,
//                                   timeInSecForIosWeb: 1,
//                                   backgroundColor: gradientBottom,
//                                   textColor: Colors.white,
//                                   fontSize: 16.0);
//                             } else if (DateTime.parse(
//                                     dateTextEditingController.text +
//                                         " " +
//                                         timeTextEditingController.text)
//                                 .isBefore(DateTime.now())) {
//                               Fluttertoast.showToast(
//                                   msg: "Select valid time!",
//                                   toastLength: Toast.LENGTH_SHORT,
//                                   gravity: ToastGravity.BOTTOM,
//                                   timeInSecForIosWeb: 1,
//                                   backgroundColor: gradientBottom,
//                                   textColor: Colors.white,
//                                   fontSize: 16.0);
//                             } else {
//                               setState(() {
//                                 scheduling = true;
//                               });
//                               final newUser = await GetIt.I<RoomService>()
//                                   .createRoom(
//                                       user,
//                                       eventNameTextEditingController.text,
//                                       agendaTextEditingController.text,
//                                       DateTime.now(),
//                                 _switchValueHumanLibrary,
//                                 "value2",
//                                       imageUrl,
//                                       "",
//                                       now,
//                                   "adTitle.text",
//                                   "adDescription.text",
//                                   "redirectLink.text",
//                                   "imageUrl2",
//                                   addAuthorTextEditingController.text,
//                                   false,
//                                   false,
//                               );
//                               auth.refreshUser(newUser);
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => Dashboard()));
//                             }
//                           },
//                           style: ButtonStyle(
//                             backgroundColor:
//                                 MaterialStateProperty.all(Color(0xff94B5AC)),
//                             shape: MaterialStateProperty.all<OutlinedBorder>(
//                               RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
