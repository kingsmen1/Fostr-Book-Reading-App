import 'package:flutter/material.dart';

class PodcastComments extends StatefulWidget {
  final String sid;
  final String title;
  const PodcastComments({
    required this.sid,
    required this.title,
    Key? key
  }) : super(key: key);

  @override
  State<PodcastComments> createState() => _PodcastCommentsState();
}

class _PodcastCommentsState extends State<PodcastComments> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
        child: Scaffold(
          backgroundColor: theme.colorScheme.primary,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_ios,
              ),
            ),
            title: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "drawerbody"),
            ),
          ),
        )
    );
  }
}
