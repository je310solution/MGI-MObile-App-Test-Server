// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:mapa_bea/models/auths.dart';
// import 'package:mapa_bea/screens/verify_login.dart';
// import 'package:mapa_bea/screens/waiting_ticket.dart';
// import 'package:mapa_bea/services/routes.dart';
//
// class LoginChecker{
//   Future loginchecker(context)async{
//     await Timer.periodic(Duration(seconds: 5), (timer)async {
//       await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/driver/status"),
//         body: {
//           "imei": deviceAuth.myImei.toString(),
//         },
//         headers: {
//           "Accept": "application/json"
//         },
//       ).then((respo) async {
//         var data = json.decode(respo.body);
//         if(data!["error"] == true){
//           routes.navigator_pushreplacement(context, VerifyLogin());
//         }
//       });
//     });
//   }
// }