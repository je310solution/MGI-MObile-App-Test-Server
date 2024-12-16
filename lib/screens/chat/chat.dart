import 'package:flutter/material.dart';
import 'package:mapa_bea/screens/chat/view_chat.dart';
import 'package:mapa_bea/services/apis/chats.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/services/stream/chats.dart';
import 'package:mapa_bea/utils/palettes.dart';
import 'package:mapa_bea/widgets/shimmering_loader.dart';
import 'package:intl/intl.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../../models/auths.dart';
import 'components/compose_message.dart';

class Chat extends StatefulWidget {
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ShimmeringLoader _shimmeringLoader = new ShimmeringLoader();
  final Routes _routes = new Routes();
  final ChatServices _chatServices = new ChatServices();
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    _chatServices.stablishConnection(context).whenComplete((){
      setState(() {
        _isLoading = false;
      });
    });
    ChatServices.initMessages.clear();
  }

  @override
  void dispose() {
    ChatServices.socket!.disconnect();
    ChatServices.socket!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      stream: chatStreamServices.subject,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(70.0),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: Center(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: TextField(
                      style: TextStyle(fontFamily: "AppFontStyle"),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          hintText: "Search message",
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey),
                          prefixIcon: Icon(Icons.search,color: Colors.blueGrey,)
                      ),
                      onChanged: (text){
                        setState((){
                          chatStreamServices.updateDispatch(data: ChatServices.toSearch.where((s) => s["name"].toString().toUpperCase().contains(text.toUpperCase())).toList());
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: _isLoading ?
            Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                for(int x = 0; x < 5; x++)...{
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    width: double.infinity,
                    height: 85,
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(1000),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              _shimmeringLoader.pageLoader(radius: 5, width: double.infinity, height: 20),
                              SizedBox(
                                height: 5,
                              ),
                              _shimmeringLoader.pageLoader(radius: 5, width: 200, height: 15),
                              SizedBox(
                                height: 2,
                              ),
                              _shimmeringLoader.pageLoader(radius: 5, width: 150, height: 15),
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                }
              ],
            ) :
            ListView(
              padding: EdgeInsets.symmetric(vertical: 15),
              children: [
                !snapshot.hasData ?
                Container() : Column(
                  children: [
                    for(int x = 0; x < snapshot.data!.length; x++)...{
                      Message(details: snapshot.data![x], index: x, isGroup: false,),
                    },
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("GROUP CONVERSATIONS",style: TextStyle(fontFamily: "AppMediumStyle"),),
                ),
                SizedBox(
                  height: 10,
                ),
                StreamBuilder<List>(
                  stream: chatStreamServices.groups,
                  builder: (context, groupSnapshot) {
                    return !groupSnapshot.hasData ?
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                      child: Text("NO GROUP FOUND!",style: TextStyle(color: Colors.grey[600],fontFamily: "AppMediumStyle",fontSize: 13),),
                    ) : Column(
                      children: [
                        for(int x = 0; x < groupSnapshot.data!.length; x++)...{
                          Message(details: groupSnapshot.data![x], index: x,isGroup: true,),
                        },
                      ],
                    );
                  }
                ),
                // for(int x = 0; x < chatStreamServices.currentGroup.length; x++)...{
                //   Message(details: chatStreamServices.currentGroup[x], index: x,),
                // }
              ],
            )
          ),
          // floatingActionButton: FloatingActionButton(
          //   elevation: 2,
          //   backgroundColor: Palettes.mainColor,
          //   child: Icon(Icons.add),
          //   onPressed: (){
          //     print(deviceAuth.loggedUser!["user_id"].toString());
          //   },
          // ),
        );
      }
    );
  }
}

class Message extends StatefulWidget {
  final Map details;
  final int index;
  final bool isGroup;
  Message({required this.details, required this.index, required this.isGroup});
  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  final Routes _routes = new Routes();
  final ChatServices _chatServices = new ChatServices();
  final ShimmeringLoader _shimmeringLoader = new ShimmeringLoader();
  bool _isLoading = false;

  Future _getMessage()async{
    var payload = {
      "my_id": deviceAuth.loggedUser!["user_id"],
      "dispatch_id": widget.details["id"]
    };
    ChatServices.socket!.emit('rider_history', payload);
    ChatServices.socket!.on('rider_history_broadcast', (data){
      if(mounted){
        setState(() {
          if(!ChatServices.initMessages.toString().contains(data.toString())){
            ChatServices.initMessages.add(data);
          }
        });
      }
    });
  }

  Future _getStreamMessage()async{
    ChatServices.socket!.on('message_broadcast', (data) {
      _isLoading = true;
      ChatServices.initMessages.clear();
      _getMessage().whenComplete((){
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    _getMessage().whenComplete(() {
      _isLoading = false;
    });
    _getStreamMessage();
  }

  @override
  Widget build(BuildContext context) {
    return  ZoomTapAnimation(
      end: 0.99,
      onTap: (){
        _chatServices.seenMessage(dispatch: widget.details);
        _routes.navigator_push(context, ViewChat(dispatch: widget.details, isGroup: widget.isGroup,));
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: double.infinity,
        height: widget.isGroup ? 75 : 85,
        margin: EdgeInsets.only(left: 15,right: 15,bottom: 10),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: widget.isGroup ? Icon(Icons.groups,size: 35,color: Colors.grey.shade700,) : Icon(Icons.support_agent,size: 35,color: Colors.grey.shade700,),
                ),
                Container(
                  width: 45,
                  height: 45,
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.circle,color: Colors.green,size: 12,),
                )
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(widget.details["name"][0].toString().toUpperCase()+widget.details["name"].substring(1).toLowerCase(),style: TextStyle(color: Colors.black,fontFamily: "AppMediumStyle"),),
                  SizedBox(
                    height: 5,
                  ),
                  widget.isGroup ? Container() : Text("Dispatcher",style: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey.shade500),)
                  // ChatServices.initMessages.toString() == "[]" ?
                  // Text("Iniatializing messages...",style: TextStyle(color: Colors.grey.shade400,fontFamily: "AppFontStyle"),) :
                  // ChatServices.initMessages.where((s) => s[0].toString().toLowerCase().contains("name: ${widget.details["name"].toLowerCase()}")).toList().isEmpty ?
                  // _shimmeringLoader.pageLoader(radius: 5, width: 130, height: 15)
                  //  : Text(ChatServices.initMessages.where((s) => s[0].toString().contains("name: ${widget.details["name"]}")).toList()[0][ChatServices.initMessages.where((s) => s[0].toString().contains("name: ${widget.details["name"]}")).toList()[0].length - 1]["body"].toString(),style: TextStyle(color: Colors.grey[600],fontFamily: "AppFontStyle"),maxLines: 2,overflow: TextOverflow.ellipsis,),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),

          ],
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
        ),
      ),
    );
  }
}
