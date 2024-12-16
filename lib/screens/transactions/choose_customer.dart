import 'package:flutter/material.dart';
import 'package:mapa_bea/screens/transactions/signature.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/services/stream/popup_checker.dart';
import 'package:mapa_bea/utils/palettes.dart';

class ChooseCustomer extends StatefulWidget {
  final Map ticket;
  final List customers;
  final bool isProcessing;
  ChooseCustomer({required this.customers, required this.ticket, required this.isProcessing});
  @override
  State<ChooseCustomer> createState() => _ChooseCustomerState();
}

class _ChooseCustomerState extends State<ChooseCustomer> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    popupChecker.update(data: true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Palettes.mainColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text("VICINITY IN TICKETS",style: TextStyle(fontSize: 16,fontFamily: "AppMediumStyle"),),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          children: [
            for(int x = 0; x < widget.customers.length; x++)...{
              Text(widget.isProcessing? widget.customers[x]["trip_number"].toString() : widget.customers[x]["order_number"].toString(),style: TextStyle(fontSize: 16,fontFamily: "AppMediumStyle",color: Colors.green),),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text("Store Location: ",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black),),
                  Expanded(child: Text(widget.customers[x]["branch_name"].toString(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),)),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text("Customer Name: ",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black),),
                  Expanded(child: Text(widget.isProcessing? widget.customers[x]["trip_consignee_name"].toString() : widget.customers[x]["consignee_name"].toString(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),)),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text("Order Amount: ",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black),),
                  Expanded(child: Text(widget.isProcessing? "₱"+widget.customers[x]["total_amount"].toString() : "₱"+widget.customers[x]["amount"].toString(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),)),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text("Order Time: ",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black),),
                  Expanded(child: Text(widget.isProcessing? widget.customers[x]["time_stamp"].toString() : widget.customers[x]["delivery_time"].toString(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),)),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text("Payment Option: ",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black),),
                  Expanded(child: Text(widget.isProcessing? widget.customers[x]["payment_mode"].toString() == "1" ? "Cash on Delivery" : "Globe Gcash" : widget.customers[x]["payment_mode_name"].toString(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),)),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text("Remark: ",style: TextStyle(fontFamily: "AppMediumStyle",color: Colors.black),),
                  Expanded(child: Text(widget.customers[x]["remarks"].toString(),style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),)),
                ],
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    color: Colors.blueGrey,
                  ),
                  child: Center(
                    child: Text("SERVE",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.white,fontWeight: FontWeight.w600),),
                  ),
                ),
                onTap: (){
                  routes.navigator_pushreplacement(context, SignSignature(details: widget.customers[x], customers: widget.customers,isProcessing: widget.isProcessing,));
                },
              ),
              SizedBox(
                height: 10,
              ),
              Divider(),
              SizedBox(
                height: 10,
              ),
            }
          ],
        ),
      ),
    );
  }
}
