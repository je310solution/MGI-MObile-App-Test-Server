import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mapa_bea/functions/loaders.dart';
import 'package:mapa_bea/services/apis/tickets.dart';
import 'package:mapa_bea/services/stream/tickets.dart';
import 'package:mapa_bea/utils/snackbars.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../models/geofence.dart';
import '../../services/routes.dart';
import '../../services/stream/popup_checker.dart';
import '../../utils/palettes.dart';
import '../landing.dart';

class EnterCode extends StatefulWidget {
  final List customers,ticket_ids;
  EnterCode({required this.customers, required this.ticket_ids});
  @override
  State<EnterCode> createState() => _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
  final TextEditingController _code = new TextEditingController();
  final ScreenLoaders _screenLoaders = new ScreenLoaders();
  final MyTicketServices _myTicketServices = new MyTicketServices();
  final SnackbarMessage _snackbarMessage = new SnackbarMessage();
  String _checker = "";
  String _message = "";
  bool _keyboardVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    KeyboardVisibilityController().onChange.listen((event) {
      Future.delayed(Duration(milliseconds:  100), () {
        setState(() {
          _keyboardVisible = event;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _keyboardVisible ? 500 : 230,
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ENTER CODE",style: TextStyle(fontSize: 15,fontFamily: "AppFontStyle",fontWeight: FontWeight.w600),),
          SizedBox(
            height: 15,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(1000)
            ),
            child: TextField(
              controller: _code,
              style: TextStyle(fontFamily: "AppFontStyle"),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                border: InputBorder.none,
                hintText: "Enter code here",
                hintStyle: TextStyle(fontFamily: "AppFontStyle"),
              ),
              onChanged: (text){
                setState((){
                 _checker = text;
                });
              },
            ),
          ),
          Spacer(),
          MaterialButton(
            onPressed: ()async{
              print(myTicketStream.currentAssigned[0]["branch_id"].toString());
              _screenLoaders.functionLoader(context);
              _myTicketServices.chashierCode(context, code: _code.text, branch_id: myTicketStream.currentAssigned[0]["branch_id"].toString()).then((value)async{
                if(value != null){
                  _myTicketServices.storeIn(context, trip_ids: widget.ticket_ids, timestamp: DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()).toString()).whenComplete(()async{
                    print("STORE IN CODE");
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString('checkStatus', value.toString());
                    prefs.setString('chashierCode', _code.text.toString());
                    setState(() {
                      checkGeofence.hasCashier = true;
                    });
                    popupChecker.updateIsfirst(data: true);
                    routes.navigator_pushreplacement(context, Landing(isProcessing: false, ), transitionType: PageTransitionType.fade);
                  });
                }else{
                  Navigator.of(context).pop(null);
                  _snackbarMessage.snackbarMessage(context, message: "Invalid cashier code, Please check and try again !",is_error: true);
                }
              });
            },
            height: 55,
            minWidth: double.infinity,
            color: _checker == "" ? Colors.grey : Palettes.mainColor,
            shape: StadiumBorder(),
            child: Text("VALIDATE CODE",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.white,fontWeight: FontWeight.w600),),
          ),
        ],
      ),
    );
  }
}
