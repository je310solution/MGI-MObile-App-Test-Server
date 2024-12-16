import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapa_bea/functions/loaders.dart';
import 'package:mapa_bea/screens/transactions/choose_customer.dart';
import 'package:mapa_bea/screens/transactions/signature.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../../models/geofence.dart';
import '../../models/location.dart';
import '../../services/apis/tickets.dart';
import '../../services/routes.dart';
import '../../services/stream/tickets.dart';
import '../../utils/palettes.dart';
import '../../widgets/shimmering_loader.dart';
import '../map/map_route.dart';

class OnProcessTickets extends StatefulWidget {
  @override
  State<OnProcessTickets> createState() => _OnProcessTicketsState();
}

class _OnProcessTicketsState extends State<OnProcessTickets> {
  final ShimmeringLoader _shimmeringLoader = new ShimmeringLoader();
  final MyTicketServices _myTicketServices = new MyTicketServices();
  List<String> _selectedTicket = [];
  List<Map> _selectedMapTicket = [];
  Timer? _timer;
  int _start = 5;
  final ScreenLoaders _screenLoaders = new ScreenLoaders();

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
              if(_selectedMapTicket[_selectedMapTicket.length - 1]["vicinity_in_timestamp"] == null){
                _screenLoaders.functionLoader(context);
                _myTicketServices.riderOut(trip_ids: _selectedTicket, timestamp:  DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()).toString(),).whenComplete((){
                  print("RIDEROUT ${_selectedTicket.toString()}");
                  if(mounted)
                    // locationModel.positionStream;
                  routes.navigator_pushreplacement(context, MapRoutes(details: _selectedMapTicket[_selectedMapTicket.length - 1], customers: _selectedMapTicket, isProcessing: true,));
                });
              }else{
                _myTicketServices.vicinityIn(context, trip_ids: _selectedTicket, timestamp: DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()).toString(), isMannual: false).then((value){
                  if(_selectedMapTicket.length > 1){
                    routes.navigator_pushreplacement(context, ChooseCustomer(ticket:  _selectedMapTicket[_selectedMapTicket.length - 1], customers: _selectedMapTicket,isProcessing: true,));
                  }else{
                    routes.navigator_pushreplacement(context, SignSignature(details: _selectedMapTicket[_selectedMapTicket.length - 1], customers: _selectedMapTicket, isProcessing: true,));
                  }
                });
              }
            }
          });
        }
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _myTicketServices.getOngoing();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
        stream: myTicketStream.ongoing,
        builder: (context, snapshot) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: !snapshot.hasData ?
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for(int x = 0; x < 2; x++)...{
                      Center(child: _shimmeringLoader.pageLoader(radius: 5, width: 200, height: 20)),
                      SizedBox(
                        height: 5,
                      ),
                      Center(child: _shimmeringLoader.pageLoader(radius: 5, width: 200, height: 20)),
                      for(int x = 0; x < 4; x++)...{
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmeringLoader.pageLoader(radius: 5, width: 300, height: 20),
                            SizedBox(
                              height: 5,
                            ),
                            _shimmeringLoader.pageLoader(radius: 5, width: 220, height: 20),
                          ],
                        ),
                      },
                      SizedBox(
                        height: 10,
                      ),
                      Divider(),
                      SizedBox(
                        height: 10,
                      )
                    }
                  ],
                ),
              ) : snapshot.data!.isEmpty ?
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.moped,size: 80,color: Colors.blueGrey.withOpacity(0.7)),
                    SizedBox(
                      height: 10,
                    ),
                    Text("NO ONGOING TICKET FOUND",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 16,color: Colors.grey[700]),),
                    SizedBox(
                      height: 5,
                    ),
                    Text("You will see here all the tickets that onprocess status.",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey),textAlign: TextAlign.center,),
                  ],
                ),
              ) :  ListView(
                children: [
                  for(int x = 0 ; x < snapshot.data!.length; x++)...{
                    ZoomTapAnimation(
                      end: 0.99,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                        color:  _selectedTicket.toString().contains(snapshot.data![snapshot.data!.length - x -1]["trip_id"].toString()) ? Palettes.mainColor.withOpacity(0.1) : Colors.white,
                        child: Column(
                          children: [
                            SizedBox(
                              height: x == 0 ? 0 : 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Ticket No.: ",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["trip_number"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["trip_number"].toUpperCase(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Amount",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(snapshot.data![snapshot.data!.length - x - 1]["total_amount"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["total_amount"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Assigned Time",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(snapshot.data![snapshot.data!.length - x - 1]["assigned_time"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["assigned_time"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Store In Time",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["store_in_timestamp"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["store_in_timestamp"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            snapshot.data![snapshot.data!.length - x - 1]["rider_out_timestamp"] == null ? Container() : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Store Out Time",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["rider_out_timestamp"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            snapshot.data![snapshot.data!.length - x - 1]["vicinity_in_timestamp"] == null ? Container() :
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Vicinity Arrival Time",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["vicinity_in_timestamp"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                              ],
                            ),
                            snapshot.data![snapshot.data!.length - x - 1]["vicinity_in_timestamp"] != null ? SizedBox(
                              height: 10,
                            ) : Container(),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("CURRENT STATUS: ",style: TextStyle(fontFamily: "AppFontStyle",fontSize: 15,color: Colors.grey[700]),),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["vicinity_in_timestamp"] == null ? "STORE OUT" : "VICINITY IN",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                      onTap: (){
                        setState((){
                          print("asdasd");
                          if(!_selectedTicket.toString().contains(snapshot.data![snapshot.data!.length - x -1]["trip_id"].toString())){
                            _selectedTicket.add(snapshot.data![snapshot.data!.length - x -1]["trip_id"].toString());
                            _selectedMapTicket.add(snapshot.data![snapshot.data!.length - x -1]);
                          }else{
                            _selectedTicket.remove(snapshot.data![snapshot.data!.length - x -1]["trip_id"].toString());
                            _selectedMapTicket.remove(snapshot.data![snapshot.data!.length - x -1]);
                          }
                          _start = 5;
                          startTimer();
                        });
                      },
                    ),
                    Divider(
                      color: Colors.black54,
                    )
                  }
                ],
              ),
            ),
          );
        }
    );
  }
}