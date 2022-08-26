import 'package:flutter/material.dart';

import '../../utils/widget_constants.dart';

class SingnUpOptions extends StatefulWidget {
  const SingnUpOptions({
    Key? key,
  }) : super(key: key);

  @override
  _SingnUpOptionsState createState() => _SingnUpOptionsState();
}

class _SingnUpOptionsState extends State<SingnUpOptions> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: GlobalColors.signUpSignInButton,
            tabs: [
              Tab(
                  icon: Icon(
                Icons.post_add,
              )),
              Tab(
                  icon: Icon(
                Icons.audiotrack,
              )),
            ],
          ),
          TabBarView(
            children: [
              Text("1"),
              Text("2"),
            ],
          ),
        ],
      ),
    );
  }
}
