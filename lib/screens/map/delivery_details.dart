// import 'package:flutter/material.dart';
// import 'package:mapa_bea/utils/palettes.dart';
//
// class DeliveryDetails extends StatefulWidget {
//   final double distance;
//   final Map customer;
//   DeliveryDetails(this.distance,this.customer);
//   @override
//   State<DeliveryDetails> createState() => _DeliveryDetailsState();
// }
//
// class _DeliveryDetailsState extends State<DeliveryDetails> {
//   double _currentIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 280,
//       padding: EdgeInsets.symmetric(vertical: 20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: Text("Delivery Tracking",style: TextStyle(fontSize: 16,fontFamily: "AppMediumStyle"),),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Expanded(
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: 20,
//                     ),
//                     Container(
//                       width: 45,
//                       height: 45,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(1000),
//                       ),
//                       child: Center(
//                         child: Image(
//                           image: NetworkImage("http://cdn.onlinewebfonts.com/svg/img_568657.png"),
//                           width: 30,
//                           height: 30,
//                           color: Colors.blueGrey,
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Expanded(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(widget.customer["consignee_name"].toString(),style: TextStyle(fontFamily: "AppMediumStyle"),),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           Text("Customer",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600],fontSize: 13.5),),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: (){},
//                       icon: Icon(Icons.message,color: Palettes.mainColor,),
//                     ),
//                     IconButton(
//                       onPressed: (){},
//                       icon: Icon(Icons.call,color: Palettes.mainColor,),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Divider(
//                   color: Colors.grey[300],
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 25),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 25,
//                         height: 25,
//                         decoration: BoxDecoration(
//                             color: Palettes.mainColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(1000)
//                         ),
//                         child: Center(
//                           child: Icon(Icons.location_on,size: 15,color: Palettes.mainColor,),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Expanded(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Delivery Address",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
//                             SizedBox(
//                               height: 3,
//                             ),
//                             Text(widget.customer["address"].toString(),style: TextStyle(fontFamily: "AppMediumtStyle"),),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 25),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 25,
//                         height: 25,
//                         decoration: BoxDecoration(
//                             color: Palettes.mainColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(1000)
//                         ),
//                         child: Center(
//                           child: Icon(Icons.location_on,size: 15,color: Palettes.mainColor,),
//                         ),
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Expanded(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Distance",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey[600]),),
//                             SizedBox(
//                               height: 3,
//                             ),
//                             Text(widget.distance.toString()+" Kilometers",style: TextStyle(fontFamily: "AppMediumtStyle"),),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
