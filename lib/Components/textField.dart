import 'package:flutter/material.dart';

import '../Theme/colors.dart';

class EntryField extends StatelessWidget {
  final String? labelText;
  final String hintText;
  final bool showSuffixIcon;
  final TextEditingController? textEditingController;
  EntryField(this.labelText, this.hintText, this.showSuffixIcon,
      [this.textEditingController]);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          labelText!,
          textAlign: TextAlign.start,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: fontSecondary, fontSize: 12),
        ),
        SizedBox(
          height: 5,
        ),
        TextFormField(
          controller: textEditingController,
          style: Theme.of(context).textTheme.bodyText2!.copyWith(
                fontSize: 16,
              ),
          decoration: InputDecoration(
            isDense: true,
            suffixIcon: showSuffixIcon
                ? Icon(Icons.keyboard_arrow_down, color: Colors.grey)
                : null,
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor)),
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 16,
                ),
          ),
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }
}

class EntryFieldR extends StatelessWidget {
  final String labelText;
  final String hintText;
  final Icon? icon;
  EntryFieldR(this.labelText, this.hintText, [this.icon]);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          labelText,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 13.5),
        ),
        SizedBox(
          height: 5,
        ),
        TextFormField(
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Colors.grey, fontSize: 13.5),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 17),
            isDense: true,
            suffixIcon: icon ?? null,
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[200]!)),
            hintText: hintText,
            hintStyle:
                Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 13.5),
          ),
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }
}
