import 'package:epic_aesthetic/shared/globals.dart';
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String title;
  final bool hasBorder;
  final Function onPress;

  ButtonWidget({
    this.title,
    this.hasBorder,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {

    return RaisedButton(
      splashColor: Theme.of(context).primaryColor,
      highlightColor: Theme.of(context).primaryColor,
      color: hasBorder ? Global.white : Global.mediumBlue,
      child: Text(
          title,
          style: TextStyle(
            color: hasBorder ? Global.mediumBlue : Global.white,
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          )
      ),
      onPressed: () => {
        onPress()
      },
    );
    return Material(

      child: Ink(
        decoration: BoxDecoration(
          color: hasBorder ? Global.white : Global.mediumBlue,
          borderRadius: BorderRadius.circular(10),
          border: hasBorder
              ? Border.all(
            color: Global.mediumBlue,
            width: 1.0,
          )
              : Border.fromBorderSide(BorderSide.none),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 60.0,
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: hasBorder ? Global.mediumBlue : Global.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}