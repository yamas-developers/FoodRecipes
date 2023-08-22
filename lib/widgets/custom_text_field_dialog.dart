import 'package:flutter/material.dart';

class CustomTextFieldDialog extends StatelessWidget {
  final String label;
  final Function function;
  final TextEditingController controller;

  const CustomTextFieldDialog({
    Key? key,
    this.label = '',
    required this.function,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      showCursor: false,
      controller: controller,
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'Raleway',
        fontSize: 17,
      ),
      onTap: () => function(),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13, fontFamily: 'Raleway')),
    );
  }
}
