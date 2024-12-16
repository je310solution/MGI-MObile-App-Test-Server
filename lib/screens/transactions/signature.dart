import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:mapa_bea/models/base64_to_file.dart';
import 'package:mapa_bea/screens/transactions/capture_image.dart';
import 'dart:ui' as ui;
import 'package:mapa_bea/utils/palettes.dart';
import 'package:mapa_bea/utils/snackbars.dart';

import '../../services/routes.dart';

class SignSignature extends StatefulWidget {
  final List customers;
  final Map details;
  final bool isProcessing;
  SignSignature({required this.details, required this.customers, required this.isProcessing});
  @override
  State<SignSignature> createState() => _SignSignatureState();
}

class _SignSignatureState extends State<SignSignature> {
  final SnackbarMessage _snackbarMessage = new SnackbarMessage();
  final ConvertBase64ToFile _convertBase64ToFile = new ConvertBase64ToFile();
  final _sign = GlobalKey<SignatureState>();
  String _rating = "";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palettes.mainColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(widget.isProcessing? widget.details["trip_number"].toString() : widget.details["order_number"].toString(),style: TextStyle(fontSize: 17,fontFamily: "AppMediumStyle"),),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name:",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[700]),),
                        Text(widget.isProcessing? widget.details["trip_consignee_name"] : widget.details["consignee_name"].toString(),style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black,fontSize: 15),),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Amount:",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[700]),),
                      Text(widget.isProcessing? "₱"+widget.details["total_amount"] : "₱"+widget.details["amount"].toString(),style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black,fontSize: 14.5),),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text("Give a feedback:",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[700],fontSize: 14.5),),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade400,
                          offset: Offset(0, 0),
                          blurRadius: 2,
                          spreadRadius: 0)
                    ]
                ),
                child: Center(
                  child: RatingBar.builder(
                    initialRating: 0,
                    itemCount: 5,
                    ignoreGestures: _rating == "" ? false : true,
                    glow: true,
                    wrapAlignment: WrapAlignment.spaceEvenly,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return Icon(
                            Icons.sentiment_very_dissatisfied,
                            color: Colors.red,
                          );
                        case 1:
                          return Icon(
                            Icons.sentiment_dissatisfied,
                            color: Colors.redAccent,
                          );
                        case 2:
                          return Icon(
                            Icons.sentiment_neutral,
                            color: Colors.amber,
                          );
                        case 3:
                          return Icon(
                            Icons.sentiment_satisfied,
                            color: Colors.lightGreen,
                          );
                        case 4:
                          return Icon(
                            Icons.sentiment_very_satisfied,
                            color: Colors.green,
                          );
                      }
                      return Container();
                    },
                    onRatingUpdate: (rating) {
                      setState((){
                        _rating = rating.floor().toString();
                        print(_rating);
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text("Sign your signature here:",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[700],fontSize: 14.5),),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade400,
                          offset: Offset(0, 0),
                          blurRadius: 2,
                          spreadRadius: 0)
                    ]
                ),
                child: Signature(
                  color: Colors.black,// Color of the drawing path
                  strokeWidth: 3.0, // with
                  backgroundPainter: null, // Additional custom painter to draw stuff like watermark
                  onSign: null, // Callback called on user pan drawing
                  key: _sign, // key that allow you to provide a GlobalKey that'll let you retrieve the image once user has signed
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: (){
                  final sign = _sign.currentState;
                  sign!.clear();
                },
                height: 40,
                minWidth: double.infinity,
                color: Colors.white,
                child: Text("CLEAR",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.black),),
              ),

              SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: ()async{
                  if(_rating == ""){
                    _snackbarMessage.snackbarMessage(context, message: "Please add a rating to continue!", is_error: true);
                  }else if(!_sign.currentState!.hasPoints){
                    _snackbarMessage.snackbarMessage(context, message: "Please enter your signature to continue!", is_error: true);
                  }else{
                    final sign = _sign.currentState;
                    final image = await sign!.getData();
                    var data = await image.toByteData(format: ui.ImageByteFormat.png);
                    final encoded = base64.encode(data!.buffer.asUint8List());
                    _convertBase64ToFile.createFileFromString(encoded: encoded).then((value){
                      print("FILE ${value}");
                      routes.navigator_pushreplacement(context, ImagePicker(details: widget.details,rating_id: _rating,customers: widget.customers, isProcessing: widget.isProcessing,signature: value,));
                    });
                  }
                },
                height: 50,
                minWidth: double.infinity,
                color: Palettes.mainColor,
                shape: StadiumBorder(),
                child: Text("DONE",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.white),),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
