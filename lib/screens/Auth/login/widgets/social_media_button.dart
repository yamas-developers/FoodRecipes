import 'package:flutter/material.dart';

class SocialMediaButton extends StatelessWidget {
  final String text;
  final Image image;
  final Color color;
  final Function function;

  SocialMediaButton({
    required this.text,
    required this.image,
    required this.color,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        backgroundColor: color,
        padding: EdgeInsets.all(6),
        elevation: 4,
        textStyle: TextStyle(color: Colors.white),
      ),
      onPressed: () => function(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            child: image,
            maxRadius: 15,
            backgroundColor: Colors.white,
          ),
          SizedBox(width: 20),
          Text(
            text.toUpperCase(),
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
