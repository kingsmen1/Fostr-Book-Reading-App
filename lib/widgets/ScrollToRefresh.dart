import 'package:flutter/material.dart';
import 'package:fostr/utils/widget_constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScrollToRefresh extends StatefulWidget {
  final Widget child;
  final Function onRefresh;
  const ScrollToRefresh(
      {Key? key, required this.child, required this.onRefresh})
      : super(key: key);

  @override
  State<ScrollToRefresh> createState() => _ScrollToRefreshState();
}

class _ScrollToRefreshState extends State<ScrollToRefresh> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      child: SmartRefresher(
        header: WaterDropMaterialHeader(
          color: Colors.white,
          backgroundColor: GlobalColors.signUpSignInButton,
        ),
        controller: _refreshController,
        onRefresh: () async {
          await widget.onRefresh();
          _refreshController.refreshCompleted();
        },
        enablePullDown: true,
        child: widget.child,
      ),
    );
  }
}
