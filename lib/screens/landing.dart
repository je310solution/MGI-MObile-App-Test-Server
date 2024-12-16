import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mapa_bea/functions/loaders.dart';
import 'package:mapa_bea/models/auths.dart';
import 'package:mapa_bea/models/geofence.dart';
import 'package:mapa_bea/models/location.dart';
import 'package:mapa_bea/screens/archive_ticket/archive_ticket.dart';
import 'package:mapa_bea/screens/chat/chat.dart';
import 'package:mapa_bea/screens/closed_ticket/closed_ticket.dart';
import 'package:mapa_bea/screens/remittance/remittance.dart';
import 'package:mapa_bea/screens/tickets/ongoin_ticket_checker.dart';
import 'package:mapa_bea/screens/tickets/tickets.dart';
import 'package:mapa_bea/screens/transactions/choose_customer.dart';
import 'package:mapa_bea/screens/transactions/signature.dart';
import 'package:mapa_bea/services/apis/chats.dart';
import 'package:mapa_bea/services/push_notifications.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/services/stream/popup_checker.dart';
import 'package:mapa_bea/services/stream/rider_in_button.dart';
import 'package:mapa_bea/utils/palettes.dart';
import 'package:mapa_bea/widgets/whats_new.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/apis/tickets.dart';
import '../services/stream/location_checker.dart';
import '../services/stream/tickets.dart';
import 'map/map_route.dart';

class Landing extends StatefulWidget {
  final bool isProcessing, startingUp;
  Landing({required this.isProcessing, this.startingUp = false});
  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  final PushNotifications _notifications = PushNotifications();
  PageController _controller = new PageController();
  final MyTicketServices _myTicketServices = new MyTicketServices();
  final ChatServices _chatServices = new ChatServices();
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isOngoingTicketChecking = true;
  List<String> _ongoingTicket = [];
  List<Map> _ongoingMapTicket = [];

  Future _checkOngoing({required List ongoing})async{
    for(int x = 0; x < ongoing.length; x++){
      _ongoingTicket.add(ongoing[x]["trip_id"].toString());
      _ongoingMapTicket.add(ongoing[x]);
    }
    if(_ongoingMapTicket[0]["store_in_timestamp"].toString() == "null"){
      setState(() {
        _isOngoingTicketChecking = false;
      });
    }
    else if(_ongoingMapTicket[0]["vicinity_in_timestamp"].toString() == "null"){
      _myTicketServices.riderOut(trip_ids: _ongoingTicket, timestamp:  DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()).toString(),).whenComplete((){
        if(mounted){
          routes.navigator_pushreplacement(context, MapRoutes(details: _ongoingMapTicket[0], customers: _ongoingMapTicket, isProcessing: true,));
        }
      });
    }else{
      _myTicketServices.vicinityIn(context, trip_ids: _ongoingTicket, timestamp: DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()).toString(), isMannual: false).then((value){
        if(_ongoingMapTicket.length > 1){
          routes.navigator_pushreplacement(context, ChooseCustomer(ticket:  _ongoingMapTicket[0], customers: _ongoingMapTicket,isProcessing: true,));
        }else{
          routes.navigator_pushreplacement(context, SignSignature(details: _ongoingMapTicket[0], customers: _ongoingMapTicket, isProcessing: true,));
        }
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.startingUp){
      _isLoading = true;
      _myTicketServices.getOngoing().then((value){
        if(value.toString() == "[]" || value.toString() == "null"){
          setState(() {
            _isOngoingTicketChecking = false;
          });
        }else{
          _checkOngoing(ongoing: value);
        }
      });
    }else{
      setState(() {
        _isOngoingTicketChecking = false;
        _isLoading = false;
      });
    }
    _controller = new PageController(initialPage: 0);
    try{
      _notifications.initialize(context);
    }catch(e){
      print("PUSH ERROR ${e.toString()}");
    }
    // locationModel.streamLocation();
    SchedulerBinding.instance.addPostFrameCallback((_)async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print(prefs.getBool("isRead"));
      if(prefs.getBool("isRead") == null){
        showDialog(
          context: context,
          builder: (_) => WhatsNew(),
        ).whenComplete((){
          prefs.setBool("isRead", true);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 4 ? null : AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        leadingWidth: 70,
        centerTitle: true,
        title: Text(_currentIndex == 0 ? "TICKETS" : _currentIndex == 1 ? "CLOSE REMITTANCE" : _currentIndex == 2 ? "TICKET REMITTANCE" : "ARCHIVED TICKET",style: TextStyle(color: Colors.black,fontFamily: "AppFontStyle",fontWeight: FontWeight.w600,fontSize: 16),),
        leading: Center(
          child: Image(
            width: 45,
            height: 45,
            color: Color.fromRGBO(4, 232, 8, 1),
            image: AssetImage("assets/logos/applogo.png"),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Text("v7.0.6",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black,fontSize: 15),),
          ),
        ],
      ),
      body:
      // _isLoading ?
      // Padding(
      //   padding: EdgeInsets.symmetric(horizontal: 40),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       CircularProgressIndicator(color: Palettes.mainColor,),
      //       SizedBox(
      //         height: 15,
      //       ),
      //       Text("Checking for ongoing ticket(s), please wait a moment ...",textAlign: TextAlign.center,style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15))
      //     ],
      //   ),
      // ) :
      PageView(
        children: [
          _isOngoingTicketChecking ?
          OngoingTicketChecker() :
          Tickets(isProcessing: widget.isProcessing,),
          ClosedTicket(),
          Remittance(),
          ArchiveTicket(),
          Chat()
        ],
        controller: _controller,
        onPageChanged: (int index){
          setState(() {
            _currentIndex = index;
            popupChecker.updateIsfirst(data: true);
          });
        },
      ),
      bottomNavigationBar: _isLoading ?
      null :
      BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.local_activity),
              label: "Tickets"),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num_rounded),
              label: "Close Ticket"),
          BottomNavigationBarItem(
              icon: Icon(Icons.payment),
              label: "Remittance"),
          BottomNavigationBarItem(
              icon: Icon(Icons.archive),
              label: "Archive Ticket"),
          BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: "Messages"),
        ],
        onTap: (index){
          _controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease);
        },
        currentIndex: _currentIndex,
        unselectedItemColor: Colors.grey[600],
        selectedItemColor: Palettes.mainColor,
      ),
    );
  }
}
