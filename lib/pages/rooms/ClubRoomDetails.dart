// import 'package:flutter/material.dart';
// import 'package:fostr/pages/rooms/EnterClubRoomDetails.dart';
// import 'package:fostr/utils/theme.dart';
//
// class ClubRoomDetails extends StatelessWidget with FostrTheme {
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment(-0.6, -1),
//             end: Alignment(1, 0.6),
//             colors: [
//               Color.fromRGBO(148, 181, 172, 1),
//               Color.fromRGBO(229, 229, 229, 1),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: paddingH + const EdgeInsets.only(top: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // SvgPicture.asset(ICONS + "menu.svg"),
//                     // SizedBox(
//                     //   height: 30,
//                     // ),
//
//                     Text(
//                       "Schedule a room",
//                       style: h1.apply(color: Colors.white),
//                     )
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 40,
//               ),
//               Expanded(
//                 child: EnterClubRoomDetails(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
