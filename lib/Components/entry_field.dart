import 'package:flutter/material.dart';

import '../Theme/colors.dart';

class TextEntryField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? image;
  final String? initialValue;
  final bool? readOnly;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int? maxLines;
  final String? hint;
  final InputBorder? border;
  final Widget? prefix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function? onTap;
  final TextCapitalization? textCapitalization;

  TextEntryField({
    this.controller,
    this.label,
    this.image,
    this.initialValue,
    this.readOnly,
    this.keyboardType,
    this.maxLength,
    this.hint,
    this.border,
    this.prefix,
    this.maxLines,
    this.suffixIcon,
    this.onTap,
    this.textCapitalization,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: textCapitalization ?? TextCapitalization.sentences,
      cursorColor: primaryColor,
      onTap: onTap as void Function()?,
      autofocus: false,
      controller: controller,
      initialValue: initialValue ?? null,
      style: Theme.of(context)
          .textTheme
          .bodyText1!
          .copyWith(fontSize: 15, fontWeight: FontWeight.w500),
      readOnly: readOnly ?? false,
      keyboardType: keyboardType,
      minLines: 1,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(top: 7),
        isDense: true,
        prefix: prefix ?? null,
        suffixIcon: suffixIcon,
        labelText: label ?? null,
        hintText: hint,
        hintStyle: Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(color: fontSecondary, fontSize: 15),
        border: InputBorder.none,
        counter: Offstage(),
        icon: (image != null)
            ? ImageIcon(
                AssetImage(image!),
                color: primaryColor,
                size: 20.0,
              )
            : null,
      ),
    );
  }
}
