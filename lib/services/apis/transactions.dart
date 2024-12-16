import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/auths.dart';
import '../stream/tickets.dart';
import 'package:intl/intl.dart';

class TransactionServices{
  Future addrating(context,{required Map ticket,required String rating_id,File? image, File? signature,required bool isProcessing})async{
    try{
      var request = http.MultipartRequest("POST",Uri.parse("http://115.84.243.189/mpb/public/api/m/trip/complete"));
      request.fields['trip_id'] = isProcessing ? ticket["trip_id"].toString() : ticket["id"].toString();
      request.fields['remarks'] = "test";
      request.fields['rating_id'] = rating_id.toString();
      request.fields['trip_actual_end_time'] = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()).toString();
      request.fields['driver_id'] = deviceAuth.loggedUser!["user_id"].toString();

      var _photo = await http.MultipartFile.fromPath("photo", image!.path);
      var _signature = await http.MultipartFile.fromPath("signature", signature!.path);

      request.files.add(_photo);
      request.files.add(_signature);
      var response = await request.send();
      final res = await http.Response.fromStream((response));
      var data = json.decode(res.body);
      print("RETURN COMPLETE ${res.body.toString()}");
      if (res.statusCode == 200 || res.statusCode == 201){
        myTicketStream.currentAssigned.removeWhere((s) => isProcessing ? s["trip_id"].toString() == ticket["trip_id"].toString() : s["id"].toString() == ticket["id"].toString());
        return data;
      }else{
        return null;
      }
    }catch(e){
      print("ERROR COMPLETE ${e}");
    }
  }
  // riderapp.maxsgroupinc.com:8000
  Future gcashCreateOrder(context,{required String order_number, required String amount})async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/gcash_create_order"),
        headers:<String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "ticketno": order_number.toString(),
          "rider_id": deviceAuth.loggedUser!["rider_info_id"].toString(),
          "amount": amount.toString()
        })
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("RETURN GCASH ${data.toString()}");
      if (respo.statusCode == 200 || respo.statusCode == 201){
        return data;
      }else{
        return null;
      }
    });
  }

  Future gcashQuery(context,{required String order_number, required Map details})async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/gcash_order_query"),
        headers:{
          "Accept": "application/json"
        },
        body: {
          "ticketno": order_number,
          "reqMsgId": details["regMsgId"],
          "merchantTransId": details["merchantTransId"],
          "acquirementId": details["acquirementId"]
        }
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("GCASH QUERY ${data.toString()}");
      if (respo.statusCode == 200 || respo.statusCode == 201){
        return data;
      }else{
        return null;
      }
    });
  }

  Future changePaymentMethod({required String order_number})async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/changePaymentMode"),
        headers:{
          "Accept": "application/json",
          "Authorization": "DC3sCYgxUqCbKbAy65em"
        },
        body: {
          "ticketno": order_number,
          "payment_mode": "1",
        }
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("CHANGE PAYMENT METHOD${data.toString()}");
      if (respo.statusCode == 200 || respo.statusCode == 201){
        return data;
      }else{
        return null;
      }
    });
  }

  Future cancel_order(context,{required String order_number, required Map details})async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/gcash_cancel_order"),
        headers:{
          "Accept": "application/json"
        },
        body: {
          "ticketno": order_number,
          "reqMsgId": details["regMsgId"],
          "merchantTransId": details["merchantTransId"],
          "acquirementId": details["acquirementId"]
        }
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("CANCEL GCASH${data.toString()}");
      if (respo.statusCode == 200 || respo.statusCode == 201){
        return data;
      }else{
        return null;
      }
    });
  }

  Future submitRemit({required String trip_id})async{
    return await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trip/remit"),
        headers: {
          "Accept": "application/json"
        },
        body: {
          "trip_id": trip_id.toString(),
          "timestamp": DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()).toString(),
          "driver_id": deviceAuth.loggedUser!["user_id"].toString(),
        }
    ).then((respo) async {
      var data = json.decode(respo.body);
      print("REMIT TICKET ${data.toString()}");
      if (data["error"] == false){
        return data;
      }else{
        return null;
      }
    });
  }
}