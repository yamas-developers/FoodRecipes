import 'package:flutter/material.dart';

import '../Theme/colors.dart';

class ColorButton extends StatelessWidget {
  final String title;
  final Function? onTap;

  ColorButton(this.title, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
        height: 56,
        margin: EdgeInsets.only(bottom: 20),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: primaryColor,
        ),
        child: Center(
            child: Text(
          title.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontSize: 15, letterSpacing: 1.5, color: Colors.white),
        )),
      ),
    );
  }
}

class ColorButtonsmall extends StatelessWidget {
  final String? title;

  ColorButtonsmall(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: primaryColor,
      ),
      child: Center(
          child: Text(
        title!.toUpperCase(),
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
            fontSize: 14,
            color: Theme.of(context).scaffoldBackgroundColor,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500),
      )),
    );
  }
}
