import 'dart:async';
import 'dart:io';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapa_bea/models/auths.dart';
import 'package:mapa_bea/models/location.dart';
import 'package:mapa_bea/screens/landing.dart';
import 'package:mapa_bea/screens/verify_phone.dart';
import 'package:mapa_bea/services/apis/tickets.dart';
import 'package:mapa_bea/services/apis/validator.dart';
import 'package:mapa_bea/services/push_notifications.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/utils/palettes.dart';
import 'package:mapa_bea/widgets/pop_up_message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final MyTicketServices _myTicketServices = new MyTicketServices();
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  Audio audio = Audio.load('assets/audios/notificaionTune.mp3',looping: false, playInBackground: false);
  audio.play();
  _myTicketServices.getAssigned();
  if (message.notification != null) {
    print(message.notification!.title);
    print(message.notification!.body);
  }
}

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>  with WidgetsBindingObserver  {
  final MyTicketServices _myTicketServices = new MyTicketServices();
  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _localization.init(
      mapLocales: [
        const MapLocale('en', AppLocale.EN),
      ],
      initLanguageCode: 'en',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      print('app inactive, is lock screen: ');
      deviceAuth.isNotify = false;
    } else if (state == AppLifecycleState.resumed) {
      print('app active, is screen: ');
      _myTicketServices.getAssigned();
    }

  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MapaBea',
      supportedLocales: _localization.supportedLocales,
      localizationsDelegates: _localization.localizationsDelegates,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{
  final PushNotifications _notifications = new PushNotifications();
  var mobile;


  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  void setCurrentLocation(Position position) {
    setState(() {
      locationModel.latitude = position.latitude;
      locationModel.longitude = position.longitude;
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _deleteCacheDir().whenComplete((){
      _notifications.firebasemessaging.getToken().then((value){
        print("FCM TOKEN ${value}");
        setState(() {
          deviceAuth.fcmToken = value;
        });
        locationModel.determinePosition(context).then((position)async{
          setCurrentLocation(position);
        }).whenComplete(()async{
          SharedPreferences prefs = await SharedPreferences.getInstance();
          deviceAuth.myImei = prefs.getString('imei');
          mobile = prefs.getString('mobile');
          print("IMEI ${deviceAuth.myImei}");
          if(mobile.toString() == "null"){
            routes.navigator_pushreplacement(context, VerifyPhone());
          }else{
            validator.verifyPhone(context, phone: mobile).then((phone)async{
              if(phone != null){
                validator.checkStatus(context, imei: deviceAuth.myImei.toString()).then((status){
                  if(status != null){
                    routes.navigator_pushreplacement(context, Landing(isProcessing: false, startingUp: true,));
                  }
                });
              }else{
                routes.navigator_pushreplacement(context, VerifyPhone());
              }
            });
          }
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
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 130),
        color: Colors.white,
        child: Column(
          children: [
            Image(
              width: 70,
              height: 70,
              color: Palettes.textColor,
              image: AssetImage("assets/icons/location.png"),
            ),
            Image(
              width: 280,
              image: AssetImage("assets/logos/withname.png"),
            ),
            Spacer(),
            CircularProgressIndicator(
              color: Palettes.mainColor,
            )
          ],
        ),
      )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

mixin AppLocale {
  static const String title = 'title';

  static const Map<String, dynamic> EN = {title: 'Localization'};
}