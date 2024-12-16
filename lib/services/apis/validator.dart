import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapa_bea/models/auths.dart';
import 'package:mapa_bea/screens/landing.dart';
import 'package:mapa_bea/screens/verify_login.dart';
import 'package:mapa_bea/screens/waiting_ticket.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/utils/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Validator{
  final SnackbarMessage _snackbarMessage = new SnackbarMessage();

  // GET THE RIDER DEVICE IMEI
  Future verifyPhone(context,{required String phone})async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trips/get/mobile"),
      body:{
        "mobile_number": phone,
        "device_fcm": deviceAuth.fcmToken
      },
      headers: {
        "Accept": "application/json"
      },
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("CHECKING ${data.toString()}");
      if (data["error"] == false){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('imei', data["result"]["imei"].toString());
        deviceAuth.myImei = data["result"]["imei"].toString();
        deviceAuth.hub_id = data["result"]["hub_id"].toString();
        prefs.setString('mobile', phone);
        return data;
      }else{
        return null;
      }
    });
  }

  // CHECK IF THE RIDER IS LOGGED IN
  Future checkStatus(context,{required String imei})async{
      return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/driver/status"),
        body: {
          "imei": imei
        },
        headers: {
          "Accept": "application/json"
        },
      ).then((respo) async {
        var data = json.decode(respo.body);
        print("STATUS ${data.toString()}");
        if(data!["error"] == false){
          if (data["result"]["is_login"].toString() == "1"){
            deviceAuth.loggedUser = data["result"];
            // routes.navigator_pushreplacement(context, Landing(isProcessing: false,));
            return data;
          }else{
            routes.navigator_pushreplacement(context, VerifyLogin());
            return null;
          }
        }else{
          routes.navigator_pushreplacement(context, VerifyLogin());
        }
      });
  }
}

Validator validator = new Validator();