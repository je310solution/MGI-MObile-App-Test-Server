import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapa_bea/functions/loaders.dart';
import 'package:mapa_bea/models/geofence.dart';
import 'package:mapa_bea/models/location.dart';
import 'package:mapa_bea/screens/map/map_route.dart';
import 'package:mapa_bea/screens/tickets/data_loader.dart';
import 'package:mapa_bea/screens/tickets/enter_code.dart';
import 'package:mapa_bea/screens/verify_phone.dart';
import 'package:mapa_bea/services/apis/tickets.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/services/stream/location_checker.dart';
import 'package:mapa_bea/services/stream/popup_checker.dart';
import 'package:mapa_bea/services/stream/rider_in_button.dart';
import 'package:mapa_bea/services/stream/tickets.dart';
import 'package:mapa_bea/utils/palettes.dart';
import 'package:mapa_bea/utils/snackbars.dart';
import 'package:intl/intl.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:page_transition/page_transition.dart';
import 'package:telephony/telephony.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../models/auths.dart';
import '../../widgets/pop_up_message.dart';
import 'package:http/http.dart' as http;

import '../transactions/choose_customer.dart';
import '../transactions/signature.dart';
import '../verify_login.dart';

class Tickets extends StatefulWidget {
  final bool isProcessing;
  Tickets({required this.isProcessing});
  @override
  State<Tickets> createState() => _TicketsState();
}

class _TicketsState extends State<Tickets>{
  final ScreenLoaders _screenLoaders = new ScreenLoaders();
  final MyTicketServices _myTicketServices = new MyTicketServices();
  final SnackbarMessage _snackbarMessage = new SnackbarMessage();
  Audio audio = Audio.load('assets/audios/notificaionTune.mp3',looping: false, playInBackground: false);
  List? _selectedTicket;
  List? _selectedMapTicket;
  bool _isVicinitySubmit = false;
  Timer? _timer;
  int _start = 5;
  String _message = "";
  final telephony = Telephony.instance;
  String _smsMobile = "";
  // static const platform = const MethodChannel('sendSms');
  //
  // Future<Null> sendSms()async {
  //   print("SendSMS");
  //   try {
  //     final String result = await platform.invokeMethod('send',<String,dynamic>{"phone":"+639265062789","msg":"Hello! I'm sent programatically."}); //Replace a 'X' with 10 digit phone number
  //     print(result);
  //   } on PlatformException catch (e) {
  //     print(e.toString());
  //   }
  // }

  onBackgroundMessage(SmsMessage message) {
    debugPrint("onBackgroundMessage called");
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
            if(_start == 0 && _selectedTicket.toString() != "[]"){
              _screenLoaders.functionLoader(context);
              _myTicketServices.storeIn(context, trip_ids: _selectedTicket!, timestamp: DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()).toString()).whenComplete((){
                _myTicketServices.riderOut(trip_ids: _selectedTicket!, timestamp:  DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()).toString(),).whenComplete(()async{
                  print("RIDEROUT ${_selectedTicket.toString()}");
                  if(_smsMobile != ""){
                    await telephony.sendSms(to: _smsMobile, message: "Hi there! This is Max's Group Delivery and your order is on its way. I'm heading over to bring it right to your doorstep. Get ready to enjoy your meal!");
                  }
                  routes.navigator_pushreplacement(context, MapRoutes(details: _selectedMapTicket![0], customers: _selectedMapTicket!, isProcessing: false,));
                });
              });
            }
          });
        }
      },
    );
  }

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
        if (data["result"]["is_login"].toString() == "0"){
          routes.navigator_pushreplacement(context, VerifyLogin(), transitionType: PageTransitionType.leftToRightWithFade);
        }
      }
    });
  }

  Future _geofencing({required String latitude, required String longtitude})async{
    double meter = await Geolocator.distanceBetween(locationModel.latitude, locationModel.longitude, double.parse(latitude), double.parse(longtitude));
    riderButtonStream.update(data: meter < 100 ? true : false);
    print("DISTANCE ${meter}");
  }

  Future _checkLocation()async{
   await Timer.periodic(Duration(seconds: 1), (timer){
      if(myTicketStream.currentAssigned.isNotEmpty){
        _geofencing(latitude: myTicketStream.currentAssigned[myTicketStream.currentAssigned.length - 1]["branch_lat"].toString(), longtitude: myTicketStream.currentAssigned[myTicketStream.currentAssigned.length - 1]["branch_lng"].toString());
      }
    });
  }

  void _getTickets(){
    Timer.periodic(Duration(seconds: 20), (timer)async {
       if(myTicketStream.currentAssigned.isEmpty){
         _myTicketServices.getAssignedTickets().then((value){
           if(value.toString() != "[]"){
             audio.play();
             showDialog(
               context: context,
               builder: (_) => FunkyOverlay(message: "You have received a new ticket", ticketname: value[value.length - 1]["order_number"],),
             ).whenComplete((){
               audio.pause();
             });
           }
         });
       }
       checkStatus();
    });

    _checkLocation();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _isLocationOpen();
    _getTickets();
    _myTicketServices.getAssigned();
    initPlatformState();
    deviceAuth.isNotify = true;
    popupChecker.update(data: false);
  }

  @override
  void dispose() {
    _timer!.cancel();
    audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      stream: myTicketStream.assigned,
      builder: (context, snapshot) {
        return StreamBuilder<bool>(
          stream: riderButtonStream.subject,
          builder: (context, riderSnapshot) {
            return Scaffold(
                backgroundColor: Colors.white,
                body: !snapshot.hasData ?
                DataLoader() :
                snapshot.data!.isEmpty ?
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Image(
                          width: 300,
                          image: AssetImage("assets/icons/waiting.png"),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text("WAITING FOR A NEW TICKET ...",textAlign: TextAlign.center,style: TextStyle(fontFamily: "AppMediumStyle",),),
                      SizedBox(
                        height: 30,
                      ),
                      CircularProgressIndicator(color: Palettes.mainColor,)
                    ],
                  ),
                ) :
                ListView.builder(
                  padding: EdgeInsets.only(bottom: 20),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context ,index){
                    return GestureDetector(
                      onTap: ()async{
                        setState((){
                          if(riderSnapshot.data!){
                            _selectedTicket = snapshot.data!.map((e) => e['id']).toList();
                            _selectedMapTicket = snapshot.data;
                            _start = 5;
                            startTimer();
                          }
                          else if(checkGeofence.hasCashier){
                            print("2222");
                            _selectedTicket = snapshot.data!.map((e) => e['id']).toList();
                            _selectedMapTicket = snapshot.data;
                            _start = 5;
                            startTimer();
                          }
                          if(snapshot.data![snapshot.data!.length - index -1]["contact_number"].toString() != "null"){
                            _smsMobile = snapshot.data![snapshot.data!.length - index -1]["contact_number"].toString();
                          }
                        });
                      },
                      child: Container(
                        color: _selectedTicket.toString().contains(snapshot.data![snapshot.data!.length - index -1]["id"].toString()) ? Palettes.mainColor.withOpacity(0.1) : Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data![snapshot.data!.length - index -1]["order_number"] == null ? "N/a" : snapshot.data![snapshot.data!.length - index -1]["order_number"],style: TextStyle(color: Palettes.textColor,fontSize: 17,fontFamily: "AppMediumStyle"),),
                            SizedBox(
                              height: 15,
                            ),
                            Text("Store Location:",style: TextStyle(color: Colors.black,fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 5,
                            ),
                            Text(snapshot.data![snapshot.data!.length - index -1]["branch_name"] == null ? "N/a" : snapshot.data![snapshot.data!.length - index -1]["branch_name"],style: TextStyle(color: Colors.grey[600],fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Customer Name:",style: TextStyle(color: Colors.black,fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 5,
                            ),
                            Text(snapshot.data![snapshot.data!.length - index -1]["consignee_name"] == null ? "N/a" : snapshot.data![snapshot.data!.length - index -1]["consignee_name"],style: TextStyle(color: Colors.grey[600],fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Customer Address:",style: TextStyle(color: Colors.black,fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 5,
                            ),
                            Text(snapshot.data![snapshot.data!.length - index -1]["address"] == null ? "N/a" : snapshot.data![snapshot.data!.length - index -1]["address"],style: TextStyle(color: Colors.grey[600],fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Order Amount:",style: TextStyle(color: Colors.black,fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 5,
                            ),
                            Text(snapshot.data![snapshot.data!.length - index -1]["amount"] == null ? "N/a" : "₱${snapshot.data![snapshot.data!.length - index -1]["amount"]}",style: TextStyle(color: Colors.grey[600],fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Order Time:",style: TextStyle(color: Colors.black,fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 5,
                            ),
                            Text(snapshot.data![snapshot.data!.length - index -1]["delivery_time"] == null ? "N/a" : snapshot.data![snapshot.data!.length - index -1]["delivery_time"],style: TextStyle(color: Colors.grey[600],fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Payment Option:",style: TextStyle(color: Colors.black,fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 5,
                            ),
                            Text(snapshot.data![snapshot.data!.length - index -1]["payment_mode_name"] == null ? "N/a" : snapshot.data![snapshot.data!.length - index -1]["payment_mode_name"],style: TextStyle(color: Colors.grey[600],fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Remarks:",style: TextStyle(color: Colors.black,fontFamily: "AppFontStyle"),),
                            SizedBox(
                              height: 5,
                            ),
                            Text(snapshot.data![snapshot.data!.length - index -1]["remarks"] == null ? "N/a" : snapshot.data![snapshot.data!.length - index -1]["remarks"],style: TextStyle(color: Colors.grey[600],fontFamily: "AppFontStyle"),),
                          ],
                        ),
                      ),
                    );
                    // );
                  },
                ),
                floatingActionButton:
                !snapshot.hasData ? null : snapshot.data!.isEmpty ? null :
                !riderSnapshot.hasData ?
                FloatingActionButton.extended(
                  onPressed: () {},
                  label: Text("Checking Vicinity",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.white),),
                  icon: SizedBox(child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2.5,),width: 25,height: 25,),
                  backgroundColor: Colors.blueGrey,
                ) :
                riderSnapshot.data! ? null :
                !checkGeofence.hasCashier ?
                FloatingActionButton.extended(
                  onPressed: ()async {
                    List _ids = [];
                    for(int  x = 0; x < myTicketStream.currentAssigned.length; x++){
                      if(!_ids.toString().contains(myTicketStream.currentAssigned[x]["id"].toString())){
                        _ids.add(myTicketStream.currentAssigned[x]["id"].toString());
                      }
                    }
                   showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        context: context, builder: (context){
                      return EnterCode(customers: myTicketStream.currentAssigned, ticket_ids: _ids,);
                    });
                  },
                  label: Text("STORE IN",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.white),),
                  icon: Icon(Icons.store,size: 24,color: Colors.white),
                  backgroundColor: Colors.blueGrey,
                )
                    : null
            );
          }
        );
      }
    );
  }
}
