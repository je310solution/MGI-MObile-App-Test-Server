import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/auths.dart';

class LocationServices{
  Future changeLocation({required String latitude, required String longitude})async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/updateRiderLocation"),
        headers:{
          "Accept": "application/json",
        },
        body: {
          "rider_id": deviceAuth.loggedUser!["rider_info_id"].toString(),
          "rider_lat": latitude,
          "rider_lng": longitude,
        }
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("CURRENT LOCATION RIDER${latitude},${longitude}");
      if (respo.statusCode == 200 || respo.statusCode == 201){
        return data;
      }else{
        return null;
      }
    });
  }
}

LocationServices locationServices = new LocationServices();