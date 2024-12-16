import 'dart:async';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:intl/intl.dart';
import 'package:mapa_bea/functions/loaders.dart';
import 'package:mapa_bea/models/geofence.dart';
import 'package:mapa_bea/models/location.dart';
import 'package:mapa_bea/screens/map/components/open_location.dart';
import 'package:mapa_bea/screens/transactions/choose_customer.dart';
import 'package:mapa_bea/screens/transactions/signature.dart';
import 'package:mapa_bea/services/apis/tickets.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/services/stream/location_checker.dart';
import 'package:mapa_bea/services/stream/popup_checker.dart';
import 'package:mapa_bea/services/stream/rider_in_button.dart';
import 'package:mapa_bea/utils/palettes.dart';

class MapRoutes extends StatefulWidget {
  final Map details;
  final List customers;
  final bool isProcessing;
  MapRoutes({required this.details, required this.customers, required this.isProcessing});
  @override
  State<MapRoutes> createState() => _MapRoutesState();
}

class _MapRoutesState extends State<MapRoutes> {
  Completer<GoogleMapController> _controller = Completer();
  MapsRoutes route = new MapsRoutes();
  final MyTicketServices _myTicketServices = new MyTicketServices();
  final ScreenLoaders _screenLoaders = new ScreenLoaders();
  DistanceCalculator distanceCalculator = new DistanceCalculator();
  String googleApiKey = 'AIzaSyCqD-22-Ddf2HJ9zeUlc4m-Xs_q-_zYA9o';
  String totalDistance = 'No route';
  MapType _mapType = MapType.normal;
  BitmapDescriptor? markerbitmap;
  List<MapType> _mapTypes = [MapType.terrain,MapType.hybrid,MapType.satellite,MapType.normal];
  List _mapImages = ["https://preview.redd.it/d95pawsxrdt21.png?width=1219&format=png&auto=webp&s=0e9fddc6ce35c67a4584b6e506565a72f62d5643","https://preview.redd.it/vpb5i5fr8mt61.png?width=888&format=png&auto=webp&s=346b88c16abf56f1438266a95a79dbee9694d65d","https://scx2.b-cdn.net/gfx/news/hires/2012/howcanyousee.png","https://www.google.com/maps/d/thumbnail?mid=1Z-LzbAsUlQxXkKaDbmrv_mpbu7Q&hl=en_US"];
  Future? _future;
  bool _isVicinity = false;
  bool _isLocationOpen = false;
  Timer? _timer;

  Future _getLocation() async {
    Geolocator.getPositionStream().listen((Position _newLocation) async{
      double meter = await Geolocator.distanceBetween(_newLocation.latitude, _newLocation.longitude, double.parse(widget.isProcessing? widget.details["trip_destination_latitude"].toString() : widget.details["lat"].toString()), double.parse(widget.isProcessing?  widget.details["trip_destination_longitude"].toString() : widget.details["lng"].toString()));
      setState(() {
        locationModel.latitude = _newLocation.latitude;
        locationModel.longitude = _newLocation.longitude;
        _drawRoutes(latLng: LatLng(_newLocation.latitude, _newLocation.longitude));
        // SUBMIT VICINITY
        if(meter < 100){
          _isVicinity = true;
          List _ids = [];
          for(int  x = 0; x < widget.customers.length; x++){
            if(widget.isProcessing){
              _ids.add(widget.customers[x]["trip_id"].toString());
            }else{
              _ids.add(widget.customers[x]["id"].toString());
            }
          }
          _myTicketServices.vicinityIn(context, trip_ids: _ids, timestamp: DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()).toString(), isMannual: false).then((value){
            if(widget.customers.length > 1){
              routes.navigator_pushreplacement(context, ChooseCustomer(ticket: widget.details, customers: widget.customers, isProcessing: widget.isProcessing,));
            }else{
              routes.navigator_pushreplacement(context, SignSignature(details: widget.details, customers: widget.customers, isProcessing: widget.isProcessing,));
            }
          });
        }else{
          _isVicinity = false;
        }
      });
    });
  }


  Future _drawRoutes({required LatLng latLng})async{
    await route.drawRoute(
      [
        LatLng(double.parse(widget.isProcessing? widget.details["trip_destination_latitude"].toString() : widget.details["lat"].toString()), double.parse(widget.isProcessing?  widget.details["trip_destination_longitude"].toString() : widget.details["lng"].toString())),
        LatLng(latLng.latitude, latLng.longitude)
      ],
      'Test routes',
      Palettes.textColor,
      googleApiKey,
      travelMode: TravelModes.driving,);
      markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/icons/deliverymarker.png",
    );
  }

 Future _locationServiceStatus()async{
   await Geolocator.isLocationServiceEnabled().then((value) => {
     setState(() {
       _isLocationOpen = value;
     })});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 100), (result) {
      _locationServiceStatus();
    });
    _getLocation();
    popupChecker.update(data: true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: locationModel.latitude == 0 && locationModel.longitude == 0 ?
        Center(
          child: CircularProgressIndicator(),
        ) :
        Stack(
          children: [
            GoogleMap(
              compassEnabled: false,
              zoomControlsEnabled: false,
              mapType: _mapType,
              mapToolbarEnabled: true,
              polylines: route.routes,
              initialCameraPosition: CameraPosition(
                zoom: 10.0,
                bearing: 8,
                tilt: 0,
                target: LatLng(locationModel.latitude, locationModel.longitude),
              ),
              markers: Set<Marker>.of([
                Marker(
                    markerId: MarkerId('SomeId'),
                    position:  LatLng(double.parse(widget.isProcessing ? widget.details["trip_destination_latitude"] : widget.details["lat"]), double.parse(widget.isProcessing ? widget.details["trip_destination_longitude"] : widget.details["lng"])),
                    infoWindow: InfoWindow(
                        title: widget.details["consignee_name"]
                    ),
                    onTap: (){
                      print("asdadasdad");
                    }
                ),
                Marker(
                    // icon: BitmapDescriptor.defaultMarkerWithHue(40),
                    markerId: MarkerId('SomeId'),
                    position: LatLng(locationModel.latitude, locationModel.longitude),
                    infoWindow: InfoWindow(
                        title: 'My Location'
                    ),
                    onTap: (){
                      print("asdadasdad");
                    }
                )
              ]),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  for(int x = 0; x < _mapTypes.length; x++)...{
                    InkWell(
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            border: Border.all(color: Palettes.mainColor),
                            borderRadius: BorderRadius.circular(1000),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(_mapImages[x])
                            )
                        ),
                      ),
                      onTap: (){
                        setState((){
                          _mapType = _mapTypes[x];
                        });
                      },
                    ),
                    SizedBox(
                      height: 10,
                    )
                  }
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20,right: 20,bottom: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _isVicinity ?
                  Container() : FutureBuilder(
                      future: _future,
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            _isLocationOpen ? Container() :
                            MaterialButton(
                              onPressed: (){
                                showModalBottomSheet(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    context: context, builder: (context){
                                  return OpenLocationPopUp(details: widget.details, customers: widget.customers, isProcessing: widget.isProcessing,);
                                });
                              },
                              height: 50,
                              minWidth: double.infinity,
                              color: Colors.blueGrey,
                              shape: StadiumBorder(),
                              child: Text("SUBMIT",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.white),),
                            ),
                            _isLocationOpen ? Container() : SizedBox(
                              height: 15,
                            ),
                          ],
                        );
                      }
                  ),
                  MaterialButton(
                    onPressed: (){
                      AndroidIntent mapIntent = AndroidIntent(
                          action:'action_view',
                          package: 'com.google.android.apps.maps',
                          data: 'google.navigation:q=${widget.details["lat"]},${widget.details["lng"]}'
                      );
                      mapIntent.launch();
                    },
                    height: 50,
                    color: Colors.blueGrey,
                    shape: StadiumBorder(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.route,color: Colors.white,),
                        SizedBox(
                          width: 5,
                        ),
                        Text("Find best route",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.white,fontWeight: FontWeight.w600,fontSize: 15),),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
  // Future<void> _goToTheLake({required LatLng coordinates}) async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //       bearing: 192.8334901395799,
  //       target: coordinates,
  //       tilt: 59.440717697143555,
  //       zoom: 19.151926040649414)));
  // }
}