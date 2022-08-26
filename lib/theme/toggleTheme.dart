import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

class ToggleTheme extends StatefulWidget {
  const ToggleTheme({Key? key}) : super(key: key);

  @override
  _ToggleThemeState createState() => _ToggleThemeState();
}

class _ToggleThemeState extends State<ToggleTheme> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration:Duration(milliseconds: 1000),
      height: 30,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isDark ?
            Colors.black87:
            Colors.blue.shade50
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration:Duration(milliseconds: 1000),
            top: 3,
            left: isDark?30:0,
            right: isDark?0:30,
            curve: Curves.easeIn,
            child: InkWell(
              onTap:()=>setState(() {
                isDark=!isDark;
              }),
              child: AnimatedSwitcher(
                duration:Duration(milliseconds: 1000),
                transitionBuilder: (Widget child,Animation<double> animation){
                  return RotationTransition(
                    turns: animation,
                    child:child
                  );
                  },
                child: Center(
                  child: isDark?
                  Icon(
                      Icons.radio_button_on_rounded,
                      size: 26,
                      key: UniqueKey(),
                      color: Colors.grey,
                  ):
                  Icon(
                      Icons.radio_button_unchecked_rounded,
                      size: 26,
                      key: UniqueKey()
                  ),
                )
              ),
            ),
          )
        ],
      ),
    );
  }
}
