import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/auths.dart';
import '../stream/tickets.dart';


class MyTicketServices{
  List<String> _ids = [];

  Future getAssignedTickets()async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trips/find"),
      headers: {
        "Accept": "application/json"
      },
      body: {
        "imei": deviceAuth.myImei,
        "driver_id": deviceAuth.loggedUser!["user_id"].toString()
      }
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("FIND ${data.toString()}");
      if (respo.statusCode == 200 || respo.statusCode == 201){
        var seen = Set();
        List uniquelist = data["result"].where((student) => seen.add(student["id"].toString())).toList();
        myTicketStream.updateAssigend(data: uniquelist);
        return uniquelist;
      }else{
        myTicketStream.updateAssigend(data: []);
        return null;
      }
    });
  }

  // http://115.84.243.189*******/mpb/public/api/m/trips/assigned_ticket
  Future getAssigned()async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trips/assigned_ticket"),
        headers: {
          "Accept": "application/json"
        },
        body: {
          "imei": deviceAuth.myImei,
        }
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("ASSIGN ${data.toString()}");
      if (respo.statusCode == 200 || respo.statusCode == 201){
        var seen = Set();
        List uniquelist = data["result"].where((student) => seen.add(student["id"].toString())).toList();
        myTicketStream.updateAssigend(data: uniquelist);
        return uniquelist;
      }else{
        myTicketStream.updateAssigend(data: []);
        return null;
      }
    });
  }

  Future chashierCode(context,{required String code,required String branch_id})async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/cashier/check_code"),
        headers: {
          "Accept": "application/json"
        },
        body: {
          "code": code,
          "branch_id": branch_id
        }
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("CODE ${data.toString()}");
      if (data["result"].toString() == "1"){
        return code;
      }else{
        return null;
      }
    });
  }

  Future storeIn(context,{required List trip_ids,required String timestamp})async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trip/store_in"),
        headers:<String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {
              "trip_id": trip_ids,
              "timestamp": timestamp,
              "driver_id": deviceAuth.loggedUser!["user_id"].toString()
            }
        )
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("STORE IN ${data.toString()}");
      if (data["error"].toString() == "false"){
        return data;
      }else{
        return null;
      }
    });
  }

  Future riderOut({required List trip_ids,required String timestamp})async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trip/rider_out"),
        headers:<String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {
              "trip_id": trip_ids,
              "timestamp": timestamp,
              "driver_id": deviceAuth.loggedUser!["user_id"].toString()
            }
        )
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("RIDER OUT ${data.toString()}");
      if (data["error"].toString() == "false"){
        return data;
      }else{
        return null;
      }
    });
  }

  Future vicinityIn(context,{required List trip_ids,required String timestamp,required bool isMannual})async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trip/vicinity_in"),
        headers:<String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {
              "trip_id": trip_ids,
              "timestamp": timestamp,
              "driver_id": deviceAuth.loggedUser!["user_id"].toString(),
              "manual_encode": isMannual.toString()
            }
        )
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("VICINITY IN ${data.toString()}");
      if (data["error"] == false){
        return data;
      }else{
        return null;
      }
    });
  }

  Future getOngoing()async{
    try{
      return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trip/getUndone/ticket"),
          headers: {
            "Accept": "application/json"
          },
          body: {
            "imei": deviceAuth.myImei,
          }
      ).then((respo) async {
        var data = json.decode(respo.body);
        print("ONGOING $data");
        if (data["error"] == false){
          if(data["result"].toString() != "[]"){
            myTicketStream.updateOngoing(data: data["result"]);
          }else{
            myTicketStream.updateOngoing(data: []);
          }
          return data["result"];
        }else{
          myTicketStream.updateOngoing(data: []);
          return null;
        }
      });
    }catch(e){
      print("ERROR ONGOING $e");
    }
  }

  Future getRemittance()async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trips/history/forRemittance"),
        headers: {
          "Accept": "application/json"
        },
        body: {
          "imei": deviceAuth.myImei,
        }
    ).then((respo) async {
      var data = json.decode(respo.body);
      if (data["error"] == false){
        if(data["result"].toString() != "[]"){
          myTicketStream.updateRemittance(data: data["result"]);
        }else{
          myTicketStream.updateRemittance(data: []);
        }
        return data;
      }else{
        myTicketStream.updateRemittance(data: []);
        return null;
      }
    });
  }

  Future getArchived()async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trips/history/archived"),
        headers: {
          "Accept": "application/json"
        },
        body: {
          "imei": deviceAuth.myImei,
        }
    ).then((respo) async {
      var data = json.decode(respo.body);
      if (data["error"] == false){
        if(data["result"].toString() != "[]"){
          myTicketStream.updateArchive(data: data["result"]);
        }else{
          myTicketStream.updateArchive(data: []);
        }
        return data;
      }else{
        myTicketStream.updateArchive(data: []);
        return null;
      }
    });
  }

  Future getClosed()async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trips/history/closed"),
        headers: {
          "Accept": "application/json"
        },
        body: {
          "imei": deviceAuth.myImei,
        }
    ).then((respo) async {
      print("CLOSE TICKET"+respo.body);
      var data = json.decode(respo.body);
      if (data["error"] == false){
        if(data["result"].toString() != "[]"){
          myTicketStream.updateClose(data: data["result"]);
        }else{
          myTicketStream.updateClose(data: []);
        }
        return data;
      }else{
        myTicketStream.updateClose(data: []);
        return null;
      }
    });
  }
}