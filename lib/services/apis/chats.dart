import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:mapa_bea/models/auths.dart';
import 'package:mapa_bea/services/stream/chats.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class ChatServices{
 static IO.Socket? socket;
 static List initMessages = [];
 static List toSearch = [];
 static List selectedMembers = [];

 // CONNECTION
 Future stablishConnection(context) async{
   socket = IO.io('http://210.14.16.68:58006', <String, dynamic>{
     'transports': ['websocket'],
     'forceNew':true
   });
   socket!.onConnect((_) {
     print('Connection established');
     socket!.emit('dispatcher_receive', [int.parse(deviceAuth.hub_id.toString())]);
     socket!.emit('get-groups', deviceAuth.loggedUser!["user_id"].toString());
   });
   // DISPATCHER BROADCAST
   socket!.on('dispatcher_broadcast', (data){
     print("DISPATCH ${data}");
     toSearch = data;
     chatStreamServices.updateDispatch(data: data);
   });
   // GET GROUPS
   socket!.on('groups-broadcast', (data){
     print("GROUPS ${data}");
     chatStreamServices.updateGroups(data: data);
   });

   socket!.onDisconnect((_) => print('Connection Disconnection'));
   socket!.onConnectError((err) => print("CONNECT ERROR "+err.toString()));
   socket!.onError((err) => print("ERROR "+err.toString()));

   socket!.connect();
 }

 // SEND MESSAGE
  Future sendMessage({required String message, required int dispatch_id})async{
    if (message.isEmpty) return;
    Map messageMap = {
      'hub_recepient_id': null,
      'body': message,
      'dispatch_recepient_id': dispatch_id,
      'sender_id': deviceAuth.loggedUser!["user_id"],
      'actual_time': null,
      'type': 1,
    };
    socket!.emit('message_send_dispatch', messageMap);
  }

 // SEND GROUP MESSAGE
 Future sendGroupMessage({required String message, required int group_id})async{
   if (message.isEmpty) return;
   Map messageMap = {
     'group_chat_id': group_id,
     'body': message,
     'sender_id': deviceAuth.loggedUser!["user_id"],
     'actual_time': DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()).toString(),
     'type': 1,
   };
   socket!.emit('group-message-send', messageMap);
 }

  // GET MESSAGE
   Future getMessages({required Map dispatch})async{
     Map payload = {
       "my_id": deviceAuth.loggedUser!["user_id"],
       "dispatch_id": dispatch["id"]
     };

     socket!.emit('rider_history', payload);
     socket!.on('rider_history_broadcast', (data) => chatStreamServices.updateMessage(data: data));
   }

 // GET GROUP CHAT MESSAGES
 Future getGroupMessages({required Map dispatch})async{
   socket!.emit('group-chat-history', dispatch["id"].toString());
   socket!.on('group-chat-history-broadcast', (data) => chatStreamServices.updateMessage(data: data));
 }

  // GET STREAM MESSAGE
  Future getStreamMessage({required Map dispatch})async{
    socket!.on('message_broadcast', (data) => getMessages(dispatch: dispatch));
  }

 // GET GROUP STREAM MESSAGE
 Future getGroupStreamMessage({required Map dispatch})async{
   socket!.on('group-message-broadcast', (data) => getGroupMessages(dispatch: dispatch));
 }

  // CHECK IF TYPING
  Future checkTyping({required Map dispatch})async{
    socket!.on("typing", (data){
      chatStreamServices.updateTyping(data: data["is_typing"]);
    });
  }

 // CHECK IF TYPING
 Future checkGroupTyping({required Map dispatch})async{
   print("TYPING");
   socket!.on("group-typing", (data) =>  chatStreamServices.updateTyping(data: data["is_typing"]));
 }

  // SEEN MESSAGES
 Future seenMessage({required Map dispatch})async{
   Map payload = {
     "userType": 1,
     "sender_id": dispatch["id"],
     "recepient_id": deviceAuth.loggedUser!["user_id"],
   };
   socket!.emit('seen', payload);
   print("asdfasasd");
 }
}