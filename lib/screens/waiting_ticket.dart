// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:mapa_bea/screens/landing.dart';
// import 'package:mapa_bea/services/routes.dart';
// import 'package:mapa_bea/services/stream/login_checker.dart';
// import 'package:mapa_bea/utils/palettes.dart';
// import 'package:http/http.dart' as http;
// import '../models/auths.dart';
//
// class WaitingTicket extends StatefulWidget {
//   @override
//   State<WaitingTicket> createState() => _WaitingTicketState();
// }
//
// class _WaitingTicketState extends State<WaitingTicket> {
//   Future? _future;
//   final LoginChecker _loginChecker = new LoginChecker();
//   //
//   _checkTicket(){
//     Timer.periodic(Duration(seconds: 5), (timer)async {
//       await http.post(Uri.parse("http://115.84.243.189/mpb/public/api/m/trips/get"),
//           headers: {
//             "Accept": "application/json"
//           },
//           body: {
//             "imei": deviceAuth.myImei.toString(),
//             "driver_id": deviceAuth.loggedUser!["user_id"].toString()
//           }
//       ).then((respo) async {
//         var data = json.decode(respo.body);
//         print(data.toString());
//         if (respo.statusCode == 200 || respo.statusCode == 201){
//           routes.navigator_pushreplacement(context, Landing());
//           return data;
//         }else{
//           return null;
//         }
//       });
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _checkTicket();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _future,
//       builder: (context, snapshot) {
//         return Scaffold(
//           body: Container(
//             width: double.infinity,
//             height: double.infinity,
//             color: Colors.white,
//             padding: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
//             child: SafeArea(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     height: 45,
//                     decoration: BoxDecoration(
//                       color: Palettes.textColor,
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     child: Center(
//                       child: Text("You are now online",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.white,fontSize: 15),),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 50,
//                   ),
//                   Center(
//                     child: Image(
//                       width: 370,
//                       image: AssetImage("assets/icons/login_waiting.gif"),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 30,
//                   ),
//                   Text("WAITING FOR A NEW TICKET ...",textAlign: TextAlign.center,style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text("Please stanby for the maintime while you are waiting for a dispatcher to assign you a ticket, You will automatically recieved it !",textAlign: TextAlign.center,style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600],)),
//                   Spacer(),
//                   CircularProgressIndicator(
//                     color: Colors.blueGrey,
//                   ),
//                   SizedBox(
//                     height: 60,
//                   )
//                 ],
//               ),
//             ),
//           ),
//         );
//       }
//     );
//   }
// }
