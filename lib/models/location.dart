import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapa_bea/open_location.dart';
import 'package:mapa_bea/services/apis/location_checker.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/services/stream/location_checker.dart';
import 'package:mapa_bea/utils/snackbars.dart';

import 'auths.dart';

class LocationModel{
  final SnackbarMessage _snackbarMessage = new SnackbarMessage();
  double latitude;
  double longitude;
  String address;

  LocationModel({this.latitude = 0, this.longitude = 0, this.address = ""});

  Future<Position> determinePosition(context) async {
    bool serviceEnabled;
    LocationPermission permission;
    try{
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        routes.navigator_pushreplacement(context, OpenLocation());
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

    }catch(e){
      _snackbarMessage.snackbarMessage(context, message: e.toString(), is_error: true);
    }
    return await Geolocator.getCurrentPosition();
  }
}

LocationModel locationModel = new LocationModel();