import 'dart:io';

import 'package:epic_aesthetic/shared/globals.dart';
import 'package:epic_aesthetic/view_models/slider_model.dart';
import 'package:epic_aesthetic/widgets/slider_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class OnBoardingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoardingPage> {
  // ignore: deprecated_member_use
  List<SliderModel> slides = new List<SliderModel>();
  var currentIndex = 0;
  var pageController = new PageController();

  @override
  void initState() {
    super.initState();
    slides = getSlides();
  }

  void ratePage(){
    Navigator.of(context).popAndPushNamed("/RatePageFake");
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      body: PageView.builder(
        controller: pageController,
        onPageChanged: (val) {
          setState(() {
            currentIndex = val;
          });
        },
        itemCount: slides.length,
        itemBuilder: (context, index){
          return SliderTile(
            imageAssetPath: slides[index].getImageAssetPath(),
            title: slides[index].getTitle(),
            desc: slides[index].getDesc(),
          );
        }),

      bottomSheet: currentIndex != slides.length - 1 ? Container(
        height: Platform.isIOS ? 70 : 60,
        padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                  onTap: () {
                     pageController.animateToPage(slides.length - 1, duration: Duration(milliseconds: 400), curve: Curves.linear);
                  },
                  child: Text("SKIP")
              ),
              Row(
                children: [
                  for(var i = 0; i < slides.length; i++)
                    currentIndex == i
                        ? pageIndexIndicator(true)
                        : pageIndexIndicator(false)
                ],
              ),
              InkWell(
                  onTap: () {
                    pageController.animateToPage(currentIndex + 1, duration: Duration(milliseconds: 400), curve: Curves.linear);
                  },
                  child: Text("NEXT")
              ),
            ],
          ),
        )
          :
        Container(
          alignment: Alignment.center,
          height: Platform.isIOS ? 70 : 60,
          color: Global.purple,
          child: InkWell(
              onTap: () {
                ratePage();
              },
              child: Text("GET STARTED NOW", style: TextStyle(
                color: Global.white,
                fontWeight: FontWeight.w600,
              ),),
          ),
        ),
    );
  }

  Widget pageIndexIndicator (bool isCurrentPage) {
     return Container(
       margin: EdgeInsets.symmetric(horizontal: 2.0),
       height: isCurrentPage ? 10.0 : 6.0,
       width: isCurrentPage ? 10.0 : 6.0,
       decoration: BoxDecoration(
         color: isCurrentPage ? Global.lightGrey : Global.superLightGrey,
         borderRadius: BorderRadius.circular(12),
       ),
     );
  }
}

