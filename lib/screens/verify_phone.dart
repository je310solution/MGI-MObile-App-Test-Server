import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mapa_bea/functions/loaders.dart';
import 'package:mapa_bea/models/auths.dart';
import 'package:mapa_bea/screens/transactions/credit_cards/credit_cards.dart';
import 'package:mapa_bea/screens/verify_login.dart';
import 'package:mapa_bea/services/apis/validator.dart';
import 'package:mapa_bea/services/push_notifications.dart';
import 'package:mapa_bea/utils/palettes.dart';
import 'package:mapa_bea/utils/snackbars.dart';

import '../services/routes.dart';

class VerifyPhone extends StatefulWidget {
  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  final ScreenLoaders _screenLoaders = new ScreenLoaders();
  final SnackbarMessage _snackbarMessage = new SnackbarMessage();
  final PushNotifications _notification = new PushNotifications();
  String _checker = "";
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: _keyboardVisible ? 20 : 50,
            ),
            _keyboardVisible ? Container() : Text("WELCOME BACK !",style: TextStyle(fontFamily: "AppFontStyle",fontSize: 20,fontWeight: FontWeight.w600),),
            Image(
              width: _keyboardVisible ? 200 : 320,
              image: AssetImage("assets/icons/delivery.png"),
            ),
            Text("Enter the phone number that currespond to \nyour account.",style: TextStyle(fontFamily: "AppFontStyle",fontSize: 14.5),textAlign: TextAlign.center,),
            SizedBox(
              height: 30,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(1000)
              ),
              child: TextField(
                style: TextStyle(fontFamily: "AppFontStyle"),
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  hintText: "Enter phone number",
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontFamily: "AppFontStyle"),
                  prefixIcon: Icon(Icons.phone_android,color: Colors.blueGrey,)
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
              onPressed: (){
                _screenLoaders.functionLoader(context);
                validator.verifyPhone(context, phone: _checker).then((value)async{
                  if(value != null){
                    routes.navigator_pushreplacement(context, VerifyLogin());
                  }else{
                    Navigator.of(context).pop(null);
                    _snackbarMessage.snackbarMessage(context, message: "No correspond account to the phone number you enter.", is_error: true);
                  }
                });
                print(deviceAuth.fcmToken);
                // routes.navigator_push(context, CreditCards());
              },
              height: 55,
              minWidth: double.infinity,
              color: _checker == "" ? Colors.grey : Palettes.mainColor ,
              shape: StadiumBorder(),
              child: Text("CONTINUE",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.white,fontWeight: FontWeight.w600),),
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
