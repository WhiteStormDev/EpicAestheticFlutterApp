import 'package:flutter/cupertino.dart';

class SliderTile extends StatelessWidget {
  SliderTile({
    Key key,
    this.imageAssetPath,
    this.title,
    this.desc
  }) : super(key: key);

  String imageAssetPath, title, desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(imageAssetPath),
          SizedBox(height: 20,),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 12,),
          Text(desc),
        ],
      ),
    );
  }
}
