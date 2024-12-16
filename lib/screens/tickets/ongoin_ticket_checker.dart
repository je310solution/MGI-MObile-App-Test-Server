import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapa_bea/services/apis/tickets.dart';

import '../../services/routes.dart';
import '../../utils/palettes.dart';
import '../map/map_route.dart';
import '../transactions/choose_customer.dart';
import '../transactions/signature.dart';

class OngoingTicketChecker extends StatefulWidget {
  @override
  State<OngoingTicketChecker> createState() => _OngoingTicketCheckerState();
}

class _OngoingTicketCheckerState extends State<OngoingTicketChecker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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
      ),
    );
  }
}
