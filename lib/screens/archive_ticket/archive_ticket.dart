import 'package:flutter/material.dart';
import 'package:mapa_bea/services/stream/tickets.dart';
import 'package:mapa_bea/widgets/shimmering_loader.dart';

import '../../services/apis/tickets.dart';

class ArchiveTicket extends StatefulWidget {
  @override
  State<ArchiveTicket> createState() => _ArchiveTicketState();
}

class _ArchiveTicketState extends State<ArchiveTicket> {
  final ShimmeringLoader _shimmeringLoader = new ShimmeringLoader();
  final MyTicketServices _myTicketServices = new MyTicketServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _myTicketServices.getArchived();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      stream: myTicketStream.archive,
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
                    Center(child: _shimmeringLoader.pageLoader(radius: 1000, width: 200, height: 20)),
                    SizedBox(
                      height: 5,
                    ),
                    Center(child: _shimmeringLoader.pageLoader(radius: 1000, width: 200, height: 20)),
                    for(int x = 0; x < 4; x++)...{
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmeringLoader.pageLoader(radius: 1000, width: 300, height: 20),
                          SizedBox(
                            height: 5,
                          ),
                          _shimmeringLoader.pageLoader(radius: 1000, width: 220, height: 20),
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
                  Icon(Icons.archive,size: 80,color: Colors.blueGrey.withOpacity(0.7)),
                  SizedBox(
                    height: 10,
                  ),
                  Text("NO ARCHIVE TICKET FOUND",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 16,color: Colors.grey[700]),),
                  SizedBox(
                    height: 5,
                  ),
                  Text("You will see here all the you're archived tickets.",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey),textAlign: TextAlign.center,),
                ],
              ),
            ) : ListView(
              padding: EdgeInsets.symmetric(vertical: 20),
              children: [
                for(int x = 0 ; x < snapshot.data!.length; x++)...{
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
                            Text(snapshot.data![snapshot.data!.length - x - 1]["ticket"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["ticket"].toUpperCase(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
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
                            Text(snapshot.data![snapshot.data!.length - x - 1]["timestamp"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["timestamp"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
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
                                Text(snapshot.data![snapshot.data!.length - x - 1]["store_in_timestamp"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["store_in_timestamp"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
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
                                Text("Vicinity Arrival Time",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(snapshot.data![snapshot.data!.length - x - 1]["vicinity_in_timestamp"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["vicinity_in_timestamp"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
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
                                Text(snapshot.data![snapshot.data!.length - x - 1]["remit_timestamp"] == null ? "N/a" : snapshot.data![snapshot.data!.length - x - 1]["remit_timestamp"],style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
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
