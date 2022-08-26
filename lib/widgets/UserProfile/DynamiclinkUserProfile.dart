import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fostr/pages/user/SelectBookCLubGenre.dart';
import 'package:fostr/pages/user/UserProfile.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/screen/ExternalUserProfile.dart';
import 'package:fostr/services/UserService.dart';
import 'package:fostr/widgets/AppLoading.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class DynamicLinkUserProfile extends StatefulWidget {
  final String? id;

  const DynamicLinkUserProfile({Key? key, required this.id}) : super(key: key);

  @override
  State<DynamicLinkUserProfile> createState() => _DynamicLinkUserProfileState();
}

class _DynamicLinkUserProfileState extends State<DynamicLinkUserProfile> {
  void _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.logedIn) {
      if (widget.id == auth.user?.id) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) => UserProfilePage()),
        );
      } else {
        UserService userServices = GetIt.I<UserService>();

        final user = await userServices.getUserById(widget.id!);
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) =>
                  ExternalProfilePage(user: user!)),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary,
      child: Center(
        child: (widget.id != null && auth.logedIn)
            ? AppLoading()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          'Opps something went wrong',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'There might be a problem with link or you might have been logged out.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  AppLoading(),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 50,
                    child: ElevatedButton(
                        style: buildButtonStyle(theme.colorScheme.secondary),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                FontAwesomeIcons.arrowRightToBracket,
                                color: Colors.white,
                              ),
                            ),
                            Text("Go to Signup Page"),
                          ],
                        )),
                  ),
                ],
              ),
      ),
    );
  }
}
