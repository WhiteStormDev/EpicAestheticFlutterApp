import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter_swipable/flutter_swipable.dart';

class CardWidget extends StatelessWidget {
  // Made to distinguish cards
  // Add your own applicable data here
  Function(Direction, String) onSwipe;
  Function(DragStartDetails) onStartSwipe;
  Function(DragUpdateDetails) onUpdateSwipe;
  Function(Offset, DragEndDetails) onCancelSwipe;

  final Color color;
  final String imageUrl;
  final String id;

  CardWidget({
    this.imageUrl,
    this.id,
    this.color, this.onSwipe, this.onStartSwipe, this.onUpdateSwipe, this.onCancelSwipe
  });

  @override
  Widget build(BuildContext context) {
    return Swipable(
      onSwipeStart: onStartSwipe,
      onPositionChanged: onUpdateSwipe,
      onSwipeCancel: onCancelSwipe,
      onSwipeLeft: (offset) { if (onSwipe != null) onSwipe(Direction.Left, id); },
      onSwipeRight: (offset) { if (onSwipe != null) onSwipe(Direction.Right, id); },
      onSwipeUp: (offset) { if (onSwipe != null) onSwipe(Direction.Up, id); },
      onSwipeDown: (offset) { if (onSwipe != null) onSwipe(Direction.Down, id); },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: color,
        ),
        child:
            imageUrl.isNotEmpty ?
                Container(
                  margin: EdgeInsets.only(left: 25),
                  child:
                    CachedNetworkImage(
                      alignment: Alignment.center,
                      imageUrl: imageUrl,
                      placeholder: (context, url) => loadingPlaceHolder,
                      errorWidget: (context, url, error) => Icon(Icons.error),)
                )
             :
            Container(),
      ),
      // onSwipeRight, left, up, down, cancel, etc...
    );
  }

  Container loadingPlaceHolder = Container(
    height: 400.0,
    child: Center(child: CircularProgressIndicator()),
  );
}

// import 'package:epic_aesthetic/views/image_view.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_swipable/flutter_swipable.dart';
//
// class CardWidget extends StatelessWidget {
//   // Made to distinguish cards
//   // Add your own applicable data here
//   String imageUrl;
//   String imageId;
//
//   Color color;
//
//   //Card(this.imageUrl, this.imageId);
//   CardWidget(Color red, {
//     this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Swipable(
//       // Set the swipable widget
//
//       // onSwipeLeft: (offset) { if (onSwipe != null) onSwipe(Direction.Left); },
//       // onSwipeRight: (offset) { if (onSwipe != null) onSwipe(Direction.Right); },
//       // onSwipeUp: (offset) { if (onSwipe != null) onSwipe(Direction.Up); },
//       // onSwipeDown: (offset) { if (onSwipe != null) onSwipe(Direction.Down); },
//
//       child: Container(
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16.0),
//             color: color,
//             // image: DecorationImage(
//             //   fit: BoxFit.fill,
//             //   alignment: FractionalOffset.topCenter,
//             //   image: NetworkImage(imageUrl),
//             // )
//           ),
//         ),
//       );
//   }
// }
//
enum Direction{
  Left,
  Right,
  Up,
  Down
}