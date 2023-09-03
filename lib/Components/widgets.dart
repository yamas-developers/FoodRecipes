import 'package:flutter/material.dart';

AppBar appbar(BuildContext context, String title, [Widget? trailing]) {
  var theme = Theme.of(context).textTheme;
  return AppBar(
    titleSpacing: 0,
    leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          size: 35,
        ),
        onPressed: () {
          Navigator.pop(context);
        }),
    title: Text(
      title,
      style: theme.bodyText1!.copyWith(
          fontSize: 25, color: Colors.black, fontWeight: FontWeight.w500),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(child: trailing ?? SizedBox.shrink()),
      )
    ],
  );
}
