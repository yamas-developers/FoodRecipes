import 'package:flutter/material.dart';

class SearchTextfield extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final Function? suffixIconOnTap;
  final Function? onChanged;

  const SearchTextfield(
      {Key? key,
      this.hintText,
      this.controller,
      this.suffixIconOnTap,
      this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).shadowColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 3),
            )
          ]),
      child: Center(
        child: TextFormField(
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          onFieldSubmitted: (_) => suffixIconOnTap!(),
          onChanged: (value) => onChanged!(),
          decoration: InputDecoration(
            // fillColor: Theme.of(context).shadowColor,
            // filled: true,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 15),
            hintStyle: TextStyle(fontSize: 14.5, color: Colors.grey.shade500),
            hintText: hintText,
            suffixIcon: IconButton(
              icon: Icon(Icons.search, color: Colors.grey.shade500),
              onPressed: () => suffixIconOnTap!(),
            ),
          ),
        ),
      ),
    );
  }
}
