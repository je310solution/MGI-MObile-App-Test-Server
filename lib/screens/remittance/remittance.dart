import 'package:flutter/material.dart';
import 'package:mapa_bea/functions/loaders.dart';
import 'package:mapa_bea/models/geofence.dart';
import 'package:mapa_bea/services/apis/tickets.dart';
import 'package:mapa_bea/services/apis/transactions.dart';
import 'package:mapa_bea/services/stream/tickets.dart';
import 'package:mapa_bea/utils/palettes.dart';
import 'package:mapa_bea/utils/snackbars.dart';
import 'package:mapa_bea/widgets/shimmering_loader.dart';

class Remittance extends StatefulWidget {
  @override
  State<Remittance> createState() => _RemittanceState();
}

class _RemittanceState extends State<Remittance> {
  final ShimmeringLoader _shimmeringLoader = new ShimmeringLoader();
  final MyTicketServices _myTicketServices = new MyTicketServices();
  final TransactionServices _transactionServices = new TransactionServices();
  final ScreenLoaders _screenLoaders = new ScreenLoaders();
  final SnackbarMessage _snackbarMessage = new SnackbarMessage();
  String _gcash = "";
  String _code = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _myTicketServices.getRemittance();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      stream: myTicketStream.remittance,
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
                    for(int x = 0; x < 3; x++)...{
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
                  Icon(Icons.payment,size: 80,color: Colors.blueGrey.withOpacity(0.7)),
                  SizedBox(
                    height: 10,
                  ),
                  Text("NO REMIT TICKET FOUND",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 16,color: Colors.grey[700]),),
                  SizedBox(
                    height: 5,
                  ),
                  Text("You will see here all the ticket that in remittance process.",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey),textAlign: TextAlign.center,),
                ],
              ),
            ) :
            ListView(
              padding: EdgeInsets.symmetric(vertical: 20),
              children: [
                for(int x = 0; x < snapshot.data!.length; x++)...{
                  snapshot.data![snapshot.data!.length - x - 1]["payment_mode_name"] != "Cash on Delivery" ? Container() :
                  Padding(
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
                            Text(snapshot.data![snapshot.data!.length - x - 1]["trip_number"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["trip_number"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Customer Name: ",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                            Text(snapshot.data![snapshot.data!.length - x - 1]["trip_consignee_name"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["trip_consignee_name"].toString().toUpperCase(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
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
                                Text("Payment",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["payment_mode_name"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["payment_mode_name"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                              ],
                            ),
                            Spacer(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Amount",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["total_amount"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["total_amount"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
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
                            Text("Remittance Time",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                            SizedBox(
                              height: 5,
                            ),
                            Text(snapshot.data![snapshot.data!.length - x - 1]["time_stamp"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["time_stamp"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
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
                                Text("Store In Time",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["store_in_timestamp"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["store_in_timestamp"].toString(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                              ],
                            ),
                            Spacer(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Store Out Time",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["rider_out_timestamp"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["rider_out_timestamp"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                              ],
                            ),
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
                                Text("Vinicity Arrival Time",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["vicinity_in_timestamp"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["vicinity_in_timestamp"].toString(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                              ],
                            ),
                            Spacer(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Served Time",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["served_timestamp"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["served_timestamp"].toString(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("AMOUNT",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 13.5),),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: double.infinity,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(1000)
                              ),
                              child: Text(snapshot.data![snapshot.data!.length - x - 1]["total_amount"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["total_amount"],style: TextStyle(fontFamily: "AppFontStyle"),),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 18,
                        ),
                         Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("CODE",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 13.5),),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(1000)
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                    border: InputBorder.none,
                                    hintText: "Enter cashier code",
                                    hintStyle: TextStyle(fontFamily: "AppFontStyle")
                                ),
                                onChanged: (text){
                                  setState((){
                                    _code = text;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        MaterialButton(
                          onPressed: (){
                            if(_code != ""){
                              print(snapshot.data![snapshot.data!.length - x - 1].toString());
                              _screenLoaders.functionLoader(context);
                              _transactionServices.submitRemit(trip_id: snapshot.data![snapshot.data!.length - x - 1]["trip_id"].toString()).then((value){
                                if(value != null){
                                  _myTicketServices.getRemittance().whenComplete((){
                                    Navigator.of(context).pop(null);
                                    _myTicketServices.getArchived();
                                    _snackbarMessage.snackbarMessage(context, message: "Ticket has successfully remit.");
                                  });
                                }else{
                                  Navigator.of(context).pop(null);
                                  _snackbarMessage.snackbarMessage(context, message: "An error occured, Please try again.", is_error: true);
                                }
                              });
                            }
                          },
                          height: 50,
                          minWidth: double.infinity,
                          color:  _code == "" ? Colors.grey : Palettes.mainColor,
                          shape: StadiumBorder(),
                          child: Text("SUBMIT",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.white),),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  x == 0 ? Divider(
                    color: Colors.black54,
                  ) : Container()
                }
              ],
            ),
          ),
        );
      }
    );
  }
}
