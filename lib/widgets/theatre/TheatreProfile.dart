import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/enums/role_enum.dart';
import 'package:fostr/models/UserModel/User.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:provider/provider.dart';
import '../RoundedImage.dart';

class TheatreProfile extends StatelessWidget {
  final User user;
  final double size;
  final bool isMute;
  final int? volume;
  final int myVolume;
  final Role role;

  const TheatreProfile({
    Key? key,
    required this.user,
    required this.size,
    required this.role,
    this.isMute = false,
    required this.volume,
    required this.myVolume,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final loggedUser = auth.user!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (auth.user!.id != user.id) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) {
                        {
                          return ExternalProfilePage(
                            user: user,
                          );
                        }
                      },
                    ),
                  );
                }
              },
              child: AnimatedContainer(
                // padding: EdgeInsets.all(10),
                duration: Duration(seconds: 0),
                curve: Curves.easeIn,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    Colors.black.withOpacity(0.02),
                    Colors.black45.withOpacity(0.4),
                  ], stops: [
                    0.5,
                    1
                  ]),
                ),
                child: RoundedImage(
                  url: user.userProfile?.profileImage.toString().replaceAll(
                      "https://firebasestorage.googleapis.com",
                      "https://ik.imagekit.io/fostrreads"),
                  width: size,
                  height: size,
                ),
              ),
            ),
            speaking(loggedUser.id),
            mute(isMute),
          ],
        ),
        SizedBox(height: 10),
        Text(
         (auth.user?.id == user.id)? "You": user.userName,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: "drawerbody",
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          role.name,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.blue,
            fontFamily: "drawerbody",
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  ///Return if user is moderator
  Widget moderator(bool isSpeaker) {
    return isSpeaker
        ? Container(
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Icons.star, color: Colors.white, size: 12),
          )
        : Container();
  }

  ///Return if user is mute
  Widget mute(bool isMute) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: isMute
          ? Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    offset: Offset(0, 1),
                  )
                ],
              ),
              child: Icon(
                Icons.mic_off,
                color: Colors.black,
              ),
            )
          : Container(),
    );
  }

  Widget speaking(String id) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: (id == user.id ? myVolume > 10 : volume! > 10) && isMute == false
          ? Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    offset: Offset(0, 1),
                  )
                ],
              ),
              child: Icon(
                CupertinoIcons.waveform_path,
                color: Colors.black,
              ),
            )
          : Container(),
    );
  }
}
