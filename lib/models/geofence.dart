import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:mapa_bea/services/stream/rider_in_button.dart';

import '../services/stream/location_checker.dart';

class CheckGeofence{
  bool hasCashier = false;
  //
  // Future geofencing({required String latitude, required String longtitude})async{
  //   double meter = await Geolocator.distanceBetween(locationRealTime.current.latitude, locationRealTime.current.longitude, double.parse(latitude), double.parse(longtitude));
  //   print("DISTANCE ${meter}");
  //   riderButtonStream.update(data: meter < 100 ? true : false);
  // }
}

CheckGeofence checkGeofence = new CheckGeofence();