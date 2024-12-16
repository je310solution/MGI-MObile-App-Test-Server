import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class SnackbarMessage{
  Future<void> snackbarMessage(context,{String? message,bool is_error = false, int duration = 6})async{
    await Flushbar(
      flushbarStyle: FlushbarStyle.FLOATING,
      isDismissible: true,
      messageText: Text(message!,style: TextStyle(color: Colors.white,fontFamily: "AppFontStyle"),),
      icon: is_error ? Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.white,
      ) : Icon(Icons.check_circle,color: Colors.green,),
      duration: Duration(seconds: duration),
      leftBarIndicatorColor: is_error ? Colors.red : Colors.green,
      backgroundColor: is_error ? Colors.black.withOpacity(0.8) : Colors.blueGrey,
      margin: EdgeInsets.symmetric(vertical: 20,horizontal: 15),
      borderRadius: BorderRadius.circular(5),
    )..show(context);
  }
}

SnackbarMessage snackbarMessage = new SnackbarMessage();