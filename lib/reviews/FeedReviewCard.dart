import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostr/providers/AuthProvider.dart';
import 'package:fostr/reviews/SingleReviewCard.dart';
import 'package:provider/provider.dart';

class FeedReviewCard extends StatefulWidget {
  final Map<String, dynamic> feed;
  final String? page;
  const FeedReviewCard({Key? key, required this.feed, this.page})
      : super(key: key);

  @override
  _FeedReviewCardState createState() => _FeedReviewCardState();
}

class _FeedReviewCardState extends State<FeedReviewCard> {
  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context).user!.id;
    return SingleReviewCard(
        id: widget.feed['id'], reviewData: widget.feed, uid: uid);
  }
}
