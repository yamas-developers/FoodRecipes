import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';

import '../Theme/colors.dart';

class NumberKeyboard extends StatelessWidget {
  final Function(String) onNumberTap;
  final Function onErase;

  NumberKeyboard(this.onNumberTap, this.onErase);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return FadedSlideAnimation(
      Container(
        height: 255,
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            GridView.builder(
                shrinkWrap: true,
                itemCount: 9,
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 60, crossAxisCount: 3),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      onNumberTap((index + 1).toString());
                    },
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: theme.bodyText1!.copyWith(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }),
            Padding(
              padding: EdgeInsetsDirectional.only(
                  end: MediaQuery.of(context).size.width * 0.145,
                  top: 12,
                  bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      onNumberTap('0');
                    },
                    child: Text(
                      "0",
                      style: theme.bodyText1!
                          .copyWith(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.29),
                  InkWell(
                    onTap: onErase as void Function()?,
                    child: Icon(Icons.backspace_outlined, size: 17),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      beginOffset: Offset(0, 0.4),
      endOffset: Offset(0, 0),
      slideCurve: Curves.linearToEaseOut,
    );
  }
}
