import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapa_bea/utils/palettes.dart';
import 'package:restart_app/restart_app.dart';

class OpenLocation extends StatefulWidget {
  @override
  State<OpenLocation> createState() => _OpenLocationState();
}

class _OpenLocationState extends State<OpenLocation> {
  bool _isLocationOpen = false;
  Timer? _timer;

  Future _locationServiceStatus()async{
    await Geolocator.isLocationServiceEnabled().then((value) => {
      setState(() {
        _isLocationOpen = value;
      })});
  }

  @override
  void initState() {
    // TODO: implement initState
    _timer = Timer.periodic(Duration(milliseconds: 100), (result) {
      _locationServiceStatus();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image(
                      width: 180,
                      image: NetworkImage("https://cdn-icons-gif.flaticon.com/6844/6844458.gif"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Enable you location",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(
                      height: 10,
                    ),
                    Text("We will need your location to give you better \nexperience and give access to all features.",style: TextStyle(fontFamily: "AppMediumStyle"),textAlign: TextAlign.center,),
                  ],
                ),
                Column(
                  children: [
                    MaterialButton(
                      onPressed: ()async{
                        await Geolocator.openLocationSettings();
                      },
                      height: 50,
                      minWidth: double.infinity,
                      color: _isLocationOpen ? Colors.grey : Colors.blueGrey,
                      shape: StadiumBorder(),
                      child: Text("Location Enabled",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.white),),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    MaterialButton(
                      onPressed: ()async{
                       await Restart.restartApp();
                      },
                      height: 50,
                      minWidth: double.infinity,
                      color: Palettes.mainColor,
                      shape: StadiumBorder(),
                      child: Text("Continue to app",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.white),),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}
