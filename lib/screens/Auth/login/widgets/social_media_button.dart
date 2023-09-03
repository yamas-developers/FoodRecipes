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
    return false
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              backgroundColor: color,
              padding: EdgeInsets.all(6),
              elevation: 4,
              textStyle: TextStyle(color: Colors.white),
            ),
            onPressed: () => function(),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  child: image,
                  maxRadius: 15,
                  backgroundColor: Colors.white,
                ),
                // SizedBox(width: 20),
                Spacer(
                  flex: 3,
                ),
                Text(
                  text,
                  style: TextStyle(fontSize: 14),
                ),
                Spacer(
                  flex: 4,
                ),
              ],
            ),
          )
        : GestureDetector(
            onTap: () => function(),
            child: Container(
              padding: EdgeInsetsDirectional.only(start: 10),
              height: 55,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).highlightColor, width: 1),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: image,
                  ),
                  Spacer(),
                  Text(text,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
                  Spacer(flex: 2),
                ],
              ),
            ),
          );
  }
}
