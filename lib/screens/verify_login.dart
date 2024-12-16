import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapa_bea/models/geofence.dart';
import 'package:mapa_bea/services/apis/tickets.dart';
import 'package:mapa_bea/services/stream/location_checker.dart';
import 'package:mapa_bea/services/stream/login_checker.dart';
import 'package:mapa_bea/utils/palettes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapa_bea/models/auths.dart';
import 'package:mapa_bea/screens/landing.dart';
import 'package:mapa_bea/screens/waiting_ticket.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/utils/snackbars.dart';
import '../models/location.dart';
import '../services/apis/validator.dart';
import '../services/stream/rider_in_button.dart';
import '../services/stream/tickets.dart';

class VerifyLogin extends StatefulWidget {
  @override
  State<VerifyLogin> createState() => _VerifyLoginState();
}

class _VerifyLoginState extends State<VerifyLogin> {
  final SnackbarMessage _snackbarMessage = new SnackbarMessage();
  final MyTicketServices _myTicketServices = new MyTicketServices();
  Timer? timer;

  Future checkStatus()async{
    await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/driver/status"),
      body: {
        "imei": deviceAuth.myImei.toString()
      },
      headers: {
        "Accept": "application/json"
      },
    ).then((respo) async {
      var data = json.decode(respo.body);
      if(data!["error"] == false){
        if (data["result"]["is_login"].toString() == "1"){
          deviceAuth.loggedUser = data["result"];
          _myTicketServices.getAssigned().whenComplete((){
            if(myTicketStream.currentAssigned.isNotEmpty){
              _geofencing(latitude: myTicketStream.currentAssigned[0]["branch_lat"].toString(), longtitude: myTicketStream.currentAssigned[0]["branch_lng"].toString());
            }
            routes.navigator_pushreplacement(context, Landing(isProcessing: false,startingUp: true));
          });
        }
      }
    });
  }

  Future _geofencing({required String latitude, required String longtitude})async{
    if(myTicketStream.currentAssigned.isNotEmpty){
      double meter = await Geolocator.distanceBetween(locationModel.latitude, locationModel.longitude, double.parse(latitude), double.parse(longtitude));
      riderButtonStream.update(data: meter < 100 ? true : false);
    }
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 15), (Timer t){
      checkStatus();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text("You are currently offline",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.white,fontSize: 15),),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Center(
                child: Image(
                  image: NetworkImage("https://static.vecteezy.com/system/resources/thumbnails/012/024/319/small_2x/registration-or-sign-up-user-interface-users-use-secure-login-and-password-collection-of-online-registration-sign-up-user-interface-modern-flat-illustration-vector.jpg"),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text("DISPATCHER IS LOGGING YOU IN ...",textAlign: TextAlign.center,style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
              SizedBox(
                height: 10,
              ),
              Text("Please wait for a moment while dispatcher logging you in, it will not take long. thank you !",textAlign: TextAlign.center,style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600],)),
              Spacer(),
              CircularProgressIndicator(
                color: Palettes.mainColor,
              ),
              SizedBox(
                height: 60,
              )
            ],
          ),
        ),
      ),
    );
  }
}
