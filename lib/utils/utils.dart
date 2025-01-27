import 'dart:convert';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_recipes_app/widgets/checkbox_list_tile.dart';
import 'package:food_recipes_app/widgets/steps_list_tile.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../Theme/colors.dart';

// Convert minutes into hours
String getDuration(String value) {
  if (int.parse(value) > 60) {
    final int hour = int.parse(value) ~/ 60;
    final int minutes = int.parse(value) % 60;
    if (minutes != 0)
      return '${hour.toString().padLeft(2)}h ${minutes.toString().padLeft(2, "0")}m';
    else
      return '${hour.toString().padLeft(2)}h';
  } else {
    return '$value min';
  }
}

String formatDouble(double value) {
  if (value == value.truncate()) {
    return value.toStringAsFixed(0); // Remove decimal part if it's zero
  } else {
    return value.toStringAsFixed(2); // Round to 2 decimal places
  }
}

bool valdiateURL(String url) {
  bool valid = false;
  if (url.contains('http://') || url.contains('https://'))
    valid = true;
  else
    valid = false;
  return valid;
}

String getRandString(int len) {
  var random = Random.secure();
  var values = List<int>.generate(len, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

Widget swipeToRefresh(context,
    {Widget? child,
    refreshController,
    VoidCallback? onRefresh,
    VoidCallback? onLoading}) {
  return SmartRefresher(
    enablePullDown: true,
    enablePullUp: true,
    header: MaterialClassicHeader(color: primaryColor),
    controller: refreshController,
    onRefresh: onRefresh,
    onLoading: onLoading,
    physics: BouncingScrollPhysics(),
    footer: CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text("");
        } else if (mode == LoadStatus.loading) {
          body = CupertinoActivityIndicator();
        } else if (mode == LoadStatus.failed) {
          body = Text("Load Failed! Click retry!");
        } else if (mode == LoadStatus.canLoading) {
          body = Text("release to load more");
        } else {
          body = Text("No more products");
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    ),
    child: child,
  );
}

showAlertDialog(
  BuildContext context, {
  String title = '',
  String description = '',
  required Function onPressed,
}) {
  Alert(
    context: context,
    title: title,
    desc: description,
    onWillPopActive: true,
    buttons: [
      DialogButton(
        child: Text(
          "Retry",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => onPressed(),
        color: Theme.of(context).primaryColor,
        radius: BorderRadius.circular(10.0),
      ),
    ],
  ).show();
}

showPreviewDialog(BuildContext context, String label, List<String> list) {
  showDialog(
    useSafeArea: true,
    context: context,
    builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.only(bottom: 10),
      title: Text(
        label == 'steps'.tr()
            ? 'steps_preview'.tr()
            : 'ingredients_preview'.tr(),
        style: TextStyle(fontSize: 16),
      ),
      content: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (ctx, index) => (label == 'steps'.tr())
              ? StepsListTile(context: context, index: index, items: list)
              : CheckBoxListTile(context: context, index: index, items: list),
          itemCount: list.length,
        ),
      ),
    ),
  );
}

Future showCustomDialogWithTitle(
  BuildContext context, {
  String title = '',
  Widget? body,
  Function? onTapSubmit,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: title != '' ? Text(title) : Container(),
        content: SingleChildScrollView(child: body),
        actions: <Widget>[
          onTapSubmit != null
              ? TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'submit'.tr(),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => onTapSubmit(),
                )
              : Container(),
        ],
      );
    },
  );
}

Widget buildBackButton(context, {EdgeInsetsGeometry? padding, dynamic onTap}) {
  return Padding(
    padding: padding ?? const EdgeInsets.fromLTRB(15, 40, 15, 0),
    child: GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(right: 3),
          child:
              Icon(Icons.arrow_back_ios_new, /*color: Colors.black,*/ size: 24),
        ),
      ),
    ),
  );
}

buildSimpleBackArrow(context, {EdgeInsetsGeometry? padding, dynamic onTap}) {
  return GestureDetector(
    onTap: onTap ?? () => Navigator.pop(context),
    child: Icon(Icons.arrow_back_ios_new),
  );
}

buildAppBar(String title, context) {
  return AppBar(
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    // iconTheme: IconThemeData(color: Colors.black),
    leading: buildSimpleBackArrow(context),
    backgroundColor: Colors.transparent,
    centerTitle: true,
    title: Text(
      title,
      // style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
    ),
  );
}

String getGreeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'good_morning'.tr();
  } else if (hour < 17) {
    return 'good_afternoon'.tr();
  } else {
    return 'good_evening'.tr();
  }
}
