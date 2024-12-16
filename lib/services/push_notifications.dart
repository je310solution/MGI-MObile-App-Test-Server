import 'dart:async';
import 'dart:convert';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mapa_bea/models/auths.dart';
import 'package:mapa_bea/models/geofence.dart';
import 'package:mapa_bea/services/apis/tickets.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/services/stream/location_checker.dart';
import 'package:mapa_bea/services/stream/rider_in_button.dart';
import 'package:mapa_bea/widgets/pop_up_message.dart';

import '../screens/landing.dart';
import 'apis/validator.dart';

class PushNotifications{
  final MyTicketServices _myTicketServices = new MyTicketServices();
  final String serverToken = 'AAAA11K1bLA:APA91bGR6wzPRd-AIp1DRfNe2MPyM9TwcjKgOFtGN39JmzxtsLY7hxv6QTQOvjW2ysoUXxuTRZOIPdeUUgyxYhxSochwpxeyu0q85ZdxDsO7aLh7ygaFF0-edV9b0-XyXSQU_2tqPbE4';
  FirebaseMessaging firebasemessaging = FirebaseMessaging.instance;
  Audio audio = Audio.load('assets/audios/notificaionTune.mp3',looping: false, playInBackground: false);

  Future<void> initialize(context)async{
    await firebasemessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await firebasemessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      RemoteNotification? notification = message!.notification;
      if (message != null) {
        print("FIRST RECIEVER :"+notification!.body.toString());
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      print("ON LISTEN TITLE${notification!.title.toString()}");
      print("ON LISTEN BODY${notification.body.toString()}");
      if(notification.title.toString() == "Login notification"){
        validator.checkStatus(context, imei: deviceAuth.myImei.toString());
      }else{
        print("FIRST RECIEVER ${notification.body}");
        _myTicketServices.getAssigned().then((tickets){
          if(notification.title.toString() == "Transfer Ticket" || notification.title.toString() == "Ticket Transfer" || notification.title.toString().contains("Payment")){
            audio.play();
            showDialog(
                context: context,
                builder: (_) => notification.title.toString().contains("Payment") ?
                FunkyOverlay(message: "This ticket has been changed the ${notification.title.toString()}".replaceAll("Payment", "payment"), ticketname: notification.body.toString(),) :
                FunkyOverlay(message: "You have received a new ticket", ticketname: notification.body.toString(),)
            ).whenComplete((){
              audio.pause();
            });
          }else{
            audio.play();
            showDialog(
              context: context,
              builder: (_) => FunkyOverlay(message:"You have ticket that has been removed from your device it maybe transfered to other rider, it is already complete, change delivey time or it has been cancelled.", ticketname: "cancel",),
            ).whenComplete((){
              audio.pause();
            });
          }
        });
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      print("onMessageOpenedApp"+notification!.body.toString());
      if(notification.title.toString() == "Login notification"){
        validator.checkStatus(context, imei: deviceAuth.myImei.toString());
      }else{
        // _myTicketServices.getAssignedTickets();
        _myTicketServices.getAssigned().then((tickets){
          showDialog(
            context: context,
            builder: (_) => notification.title.toString() == "Transfer Ticket" || notification.title.toString() == "Ticket Transfer" ?
            FunkyOverlay(message: "You have received a new ticket", ticketname: notification.body.toString(),) :
            notification.title.toString().contains("Payment") ?
            FunkyOverlay(message: "This ticket has been changed the ${notification.title.toString()}".replaceAll("Payment", "payment"), ticketname: notification.body.toString(),) :
            FunkyOverlay(message:"You have ticket that has been removed from your device it maybe transfered to other rider, it is already complete, change delivey time or it has been cancelled.", ticketname: "cancel",),
          );
        });
      }
    });
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      audio.play();
      _myTicketServices.getAssigned();
    });
  }
}
