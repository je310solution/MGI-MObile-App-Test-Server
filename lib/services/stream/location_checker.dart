// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:rxdart/subjects.dart';
//
// class LocationRealTime{
//   BehaviorSubject<LatLng> subject = new BehaviorSubject.seeded(LatLng(0,0));
//   Stream get stream => subject.stream;
//   LatLng get current => subject.value;
//
//   update({required LatLng data}){
//     subject.add(data);
//   }
// }
//
// LocationRealTime locationRealTime = new LocationRealTime();