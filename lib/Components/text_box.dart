import 'package:flutter/material.dart';

import '../Theme/colors.dart';

class TextBox extends StatefulWidget {
  final String? title;
  TextBox(this.title);

  @override
  _TextBoxState createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 5, top: 10),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).cardColor
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected
                    ? primaryColor
                    : Theme.of(context).highlightColor)),
        child: Text(
          widget.title!,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontSize: 12, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}
