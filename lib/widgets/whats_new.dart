import 'package:flutter/material.dart';
import 'package:mapa_bea/utils/palettes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WhatsNew extends StatefulWidget {
  @override
  State<WhatsNew> createState() => _WhatsNewState();
}

class _WhatsNewState extends State<WhatsNew>  with SingleTickerProviderStateMixin{
  AnimationController? controller;
  Animation<double>? scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller!, curve: Curves.elasticInOut);

    controller!.addListener(() {
      setState(() {});
    });

    controller!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          filterQuality: FilterQuality.high,
          scale: scaleAnimation!,
          child: Container(
            width: double.infinity,
            height: 300,
            padding: EdgeInsets.symmetric(vertical: 20,horizontal: 30),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0))),
            child: Column(
              children: [
                Text("Whats new on version 7.0.6?",style: TextStyle(fontFamily: "AppFontStyle",fontSize: 16,fontWeight: FontWeight.w600),),
                SizedBox(
                  height: 15,
                ),
                Image(
                  width: 80,
                  color: Colors.blueGrey,
                  image: AssetImage("assets/icons/fix-bug.png"),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Fix some minor bugs and ui enhancement!",style: TextStyle(),textAlign: TextAlign.center,),
                Spacer(),
                GestureDetector(
                  onTap: ()async{
                    Navigator.of(context).pop(null);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Palettes.mainColor,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: Text("Close",style: TextStyle(color: Colors.white,fontSize: 15),),
                    ),
                  ),
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}
