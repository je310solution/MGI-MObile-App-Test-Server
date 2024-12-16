import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera_gallery_image_picker/camera_gallery_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:mapa_bea/functions/loaders.dart';
import 'package:mapa_bea/screens/landing.dart';
import 'package:mapa_bea/screens/transactions/choose_customer.dart';
import 'package:mapa_bea/screens/transactions/gcash/gcash.dart';
import 'package:mapa_bea/services/apis/transactions.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/services/stream/popup_checker.dart';
import 'package:mapa_bea/utils/palettes.dart';
import 'package:mapa_bea/utils/snackbars.dart';
import 'package:page_transition/page_transition.dart';
import 'package:restart_app/restart_app.dart';

import '../../models/auths.dart';
import '../../models/geofence.dart';

class ImagePicker extends StatefulWidget {
  final Map details;
  final List customers;
  final String rating_id;
  final bool isProcessing;
  final File signature;
  ImagePicker({required this.details,required this.rating_id,required this.customers, required this.isProcessing,required this.signature});
  @override
  _ImagePickerState createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> {
  File? _images;
  final ScreenLoaders _screenLoaders = new ScreenLoaders();
  final SnackbarMessage _snackbarMessage = new SnackbarMessage();
  final TransactionServices _transactionServices = new TransactionServices();

  Future _captureImage(ImagePickerSource source) async {
    var image = await CameraGalleryImagePicker.pickImage(
      context: context,
      source: source,
    );
    setState(() {
      _images = File(image.path);
    });
    return image;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _captureImage(ImagePickerSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
          child: Column(
            children: [
              _images == null ?
              Column(
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  Image(
                    width: 170,
                    height: 170,
                    color: Colors.grey[400],
                    image: AssetImage("assets/icons/addphoto.png"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("NO PHOTO FOUND",style: TextStyle(fontFamily: "AppMediumStyle",fontSize: 15,color: Colors.grey[700]),),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Click the add button below to add more photos.",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
                ],
              ) :
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(_images!),
                    )
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Palettes.mainColor,
                      borderRadius: BorderRadius.circular(50)
                  ),
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined,color: Colors.white,),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Change Photo",style: TextStyle(fontFamily: "OpenSans-medium",color: Colors.white,fontSize: 15.5),)
                    ],
                  ),
                ),
                onTap: (){
                  _captureImage(ImagePickerSource.camera);
                },
              ),
             _images == null ? Container() :
             MaterialButton(
                onPressed: (){
                  print(widget.signature);
                  print(_images);
                  setState(() {
                    checkGeofence.hasCashier = false;
                  });
                  if(widget.details["payment_mode"] == 72){
                    _screenLoaders.functionLoader(context);
                    _transactionServices.gcashCreateOrder(context, order_number: widget.isProcessing ? widget.details["trip_number"].toString() : widget.details["order_number"].toString(), amount: widget.isProcessing ? widget.details["total_amount"].toString() : widget.details["amount"].toString()).then((value){
                      Navigator.of(context).pop(null);
                      print(deviceAuth.loggedUser!["user_id"].toString());
                      if(value!["error"] == false){
                        routes.navigator_pushreplacement(context, GcashTransaction(details: widget.details, qrCode: value, customers: widget.customers,rating: widget.rating_id,isProcessing: widget.isProcessing,image: _images!, signature: widget.signature));
                      }else{
                        if(value["message"] == "PARAM_ILLEGAL"){
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  margin: EdgeInsets.symmetric(horizontal: 30),
                                  width: double.infinity,
                                  height: 470,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Image(
                                        image: NetworkImage("https://cdn-icons-png.flaticon.com/512/6134/6134065.png"),
                                        width: 120,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text("TRANSACTION FAIL!",style: TextStyle(decoration: TextDecoration.none,fontSize: 18,fontFamily: "AppFontStyle",color: Palettes.mainColor),),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("You cannot proceed to this transaction , you are not yet registered to the gcash list. You can continue via Cash on delivery instead?",style: TextStyle(decoration: TextDecoration.none,fontSize: 16,fontFamily: "AppFontStyle",color: Colors.grey[800]),textAlign: TextAlign.center,),
                                      Spacer(),
                                      MaterialButton(
                                        onPressed: (){
                                          _screenLoaders.functionLoader(context);
                                          _transactionServices.changePaymentMethod(order_number: widget.isProcessing ? widget.details["trip_number"].toString() : widget.details["order_number"].toString()).whenComplete((){
                                            _transactionServices.cancel_order(context, order_number: widget.isProcessing ? widget.details["trip_number"].toString() : widget.details["order_number"].toString(), details: value).whenComplete((){
                                              _transactionServices.addrating(context,ticket: widget.details, rating_id:widget.rating_id, image: _images!, isProcessing: widget.isProcessing, signature: widget.signature).then((value){
                                                setState((){
                                                  widget.customers.remove(widget.details);
                                                });
                                                if(value != null){
                                                  if(widget.customers.length == 0){
                                                    popupChecker.updateIsfirst(data: true);
                                                    routes.navigator_pushreplacement(context, Landing(isProcessing: false,), transitionType: PageTransitionType.leftToRightWithFade);
                                                  }else{
                                                    routes.navigator_pushreplacement(context, ChooseCustomer(ticket: widget.details, customers: widget.customers,isProcessing: widget.isProcessing,),transitionType: PageTransitionType.leftToRightWithFade);
                                                  }
                                                }else{
                                                  Navigator.of(context).pop(null);
                                                }
                                              });
                                            });
                                          });
                                        },
                                        height: 50,
                                        minWidth: double.infinity,
                                        color: Palettes.mainColor,
                                        shape: StadiumBorder(),
                                        child: Text("CASH ON DELIVERY",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.white),),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      MaterialButton(
                                        onPressed: (){
                                          Navigator.of(context).pop(null);
                                        },
                                        height: 50,
                                        minWidth: double.infinity,
                                        color: Colors.white,
                                        shape: StadiumBorder(),
                                        child: Text("CANCEL TRANSACTION",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black),),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                          // _snackbarMessage.snackbarMessage(context, message: "You cannot proceed to this transaction , you are not yet registered to the gcash list!", is_error: true);
                        }else{
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  margin: EdgeInsets.symmetric(horizontal: 30),
                                  width: double.infinity,
                                  height: 470,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Column(
                                    children: [
                                      Image(
                                        image: NetworkImage("https://www.gcash.com/wp-content/uploads/2020/04/gcash-pay-bills.png"),
                                        width: 200,
                                      ),
                                      Text("INSUFFICIENT FUND",style: TextStyle(decoration: TextDecoration.none,fontSize: 18,fontFamily: "AppFontStyle",color: Palettes.mainColor),),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Sorry you don't have enough fund to proceed on this transaction. Continue via Cash on delivery instead?",style: TextStyle(decoration: TextDecoration.none,fontSize: 16,fontFamily: "AppFontStyle",color: Colors.grey[800]),textAlign: TextAlign.center,),
                                      Spacer(),
                                      MaterialButton(
                                        onPressed: (){
                                          _screenLoaders.functionLoader(context);
                                          _transactionServices.changePaymentMethod(order_number: widget.isProcessing ? widget.details["trip_number"].toString() : widget.details["order_number"].toString()).whenComplete((){
                                            _transactionServices.cancel_order(context, order_number: widget.isProcessing ? widget.details["trip_number"].toString() : widget.details["order_number"].toString(), details: value).whenComplete((){
                                              _transactionServices.addrating(context,ticket: widget.details, rating_id:widget.rating_id, image: _images!, isProcessing: widget.isProcessing, signature: widget.signature).then((value){
                                                setState((){
                                                  widget.customers.remove(widget.details);
                                                });
                                                if(value != null){
                                                  if(widget.customers.length == 0){
                                                    popupChecker.updateIsfirst(data: true);
                                                    routes.navigator_pushreplacement(context, Landing(isProcessing: false,), transitionType: PageTransitionType.leftToRightWithFade);
                                                  }else{
                                                    routes.navigator_pushreplacement(context, ChooseCustomer(ticket: widget.details, customers: widget.customers,isProcessing: widget.isProcessing,),transitionType: PageTransitionType.leftToRightWithFade);
                                                  }
                                                }else{
                                                  Navigator.of(context).pop(null);
                                                }
                                              });
                                            });
                                          });
                                        },
                                        height: 50,
                                        minWidth: double.infinity,
                                        color: Palettes.mainColor,
                                        shape: StadiumBorder(),
                                        child: Text("CASH ON DELIVERY",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.white),),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      MaterialButton(
                                        onPressed: (){
                                          routes.navigator_pushreplacement(context, GcashTransaction(details: widget.details, qrCode: value, customers: widget.customers,rating: widget.rating_id,isProcessing: widget.isProcessing,image: _images!, signature: widget.signature,));
                                        },
                                        height: 50,
                                        minWidth: double.infinity,
                                        color: Colors.white,
                                        shape: StadiumBorder(),
                                        child: Text("CANCEL TRANSACTION",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black),),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      }
                    });
                  }else{
                    _screenLoaders.functionLoader(context);
                    _transactionServices.addrating(context,ticket: widget.details, rating_id:widget.rating_id, image: _images!, isProcessing: widget.isProcessing, signature: widget.signature).then((value){
                      setState((){
                        widget.customers.remove(widget.details);
                      });
                      if(value != null){
                        if(widget.customers.length == 0){
                          popupChecker.updateIsfirst(data: true);
                          routes.navigator_pushreplacement(context, Landing(isProcessing: false,), transitionType: PageTransitionType.leftToRightWithFade);
                        }else{
                          routes.navigator_pushreplacement(context, ChooseCustomer(ticket: widget.details, customers: widget.customers,isProcessing: widget.isProcessing,),transitionType: PageTransitionType.leftToRightWithFade);
                        }
                      }else{
                        Navigator.of(context).pop(null);
                      }
                    });
                  }
                },
                height: 50,
                minWidth: double.infinity,
                color: Colors.blueGrey,
                shape: StadiumBorder(),
                child: Text("DONE",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
