import 'package:flutter/material.dart';
import 'package:mapa_bea/utils/palettes.dart';

class FunkyOverlay extends StatefulWidget {
  final String message,ticketname;
  FunkyOverlay({required this.message, required this.ticketname});
  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay>
    with SingleTickerProviderStateMixin {
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.2),
      child: Center(
        child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
        scale: scaleAnimation!,
        child: Container(
        width: double.infinity,
        height: widget.ticketname == "cancel" ? 200 : 170,
        margin: EdgeInsets.symmetric(horizontal: 25),
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.message,style: TextStyle(fontFamily: "AppFontStyle",fontSize: 15),textAlign: TextAlign.center,),
              widget.ticketname == "cancel" ? Container() : SizedBox(
                height: 5,
              ),
              widget.ticketname == "cancel" ? Container() :  Text(widget.ticketname,style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15,color: Palettes.mainColor)),
              SizedBox(
                height: 20,
              ),
              InkWell(
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    color:Palettes.mainColor.withOpacity(0.8),
                  ),
                  child: Center(
                    child: Text("OK",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.white,fontWeight: FontWeight.w600),),
                  ),
                ),
                onTap: (){
                  Navigator.of(context).pop(null);
                },
              ),
            ],
          ),
        ),
        ),
        ),
      ),
    );
  }
}
