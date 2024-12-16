import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mapa_bea/screens/chat/components/members.dart';
import 'package:mapa_bea/services/apis/chats.dart';
import 'package:mapa_bea/services/routes.dart';
import 'package:mapa_bea/utils/palettes.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:intl/intl.dart';
import '../../models/auths.dart';
import '../../services/stream/chats.dart';
import 'dart:math' as math;

class ViewChat extends StatefulWidget {
  final Map dispatch;
  final bool isGroup;
  ViewChat({required this.dispatch, required this.isGroup});
  @override
  State<ViewChat> createState() => _ViewChatState();
}

class _ViewChatState extends State<ViewChat> {
  final ChatServices _chatServices = new ChatServices();
  final Routes _routes = new Routes();
  final TextEditingController _message = new TextEditingController();
  bool _showEmoji = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatStreamServices.updateMessage(data: []);
    if(widget.isGroup){
      _chatServices.getGroupMessages(dispatch: widget.dispatch,);
      _chatServices.getGroupStreamMessage(dispatch: widget.dispatch);
      _chatServices.checkGroupTyping(dispatch: widget.dispatch);
    }else{
      _chatServices.getMessages(dispatch: widget.dispatch,);
      _chatServices.getStreamMessage(dispatch: widget.dispatch);
      _chatServices.checkTyping(dispatch: widget.dispatch);
    }
    chatStreamServices.updateTyping(data: false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      stream: chatStreamServices.message,
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: (){
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() {
              _showEmoji = !_showEmoji;
            });
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 1,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              title: Row(
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
                        Text(widget.dispatch["name"][0].toString().toUpperCase()+widget.dispatch["name"].substring(1).toLowerCase(),style: TextStyle(color: Colors.black,fontFamily: "AppMediumStyle",fontSize: 16),),
                        widget.isGroup ? Container() : Text("Dispatcher",style: TextStyle(color: Colors.blueGrey,fontFamily: "AppMediumStyle",fontSize: 12),),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings,color: Colors.blueGrey,),
                    onPressed: (){
                      print(widget.dispatch);
                      ChatServices.socket!.emit('get-group-members', widget.dispatch["id"].toString());
                      ChatServices.socket!.on('group-members-broadcast', (data){
                        print("GROUPS MEMBERS ${data}");
                        chatStreamServices.updateMembers(data: data);
                      });
                      _routes.navigator_push(context, Members());
                    },
                  )
                ],
              ),

            ),
            body: StreamBuilder<bool>(
              stream: chatStreamServices.typing,
              builder: (context, snapshotTyping) {
                return SafeArea(
                  child: Stack(
                    children: [
                      !snapshot.hasData ?
                      Center(
                        child: CircularProgressIndicator(
                          color: Palettes.mainColor,
                        ),
                      ) :
                      snapshot.data!.isEmpty ?
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(bottom: 95,left: 20,right: 20),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 70,
                                  height: 40,
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(1000),
                                        color: Colors.grey[300],
                                    ),
                                    child: Icon(Icons.support_agent,size: 35,color: Colors.grey.shade700,),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius:
                                      BorderRadius.circular(1000),
                                  ),
                                  child: Icon(Icons.account_circle,size: 35,color: Colors.grey.shade700,),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "You can now start the conversation with ${widget.dispatch["name"]}.",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: "AppFontStyle",
                                  color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ) :
                      ListView(
                        reverse: true,
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                        children: [
                          SizedBox(
                            height: !snapshot.hasData ? 0 : !snapshotTyping.data! ? 90 : 130,
                          ),
                          for(int x = 0; x < snapshot.data!.length; x++)...{
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child:  snapshot.data![snapshot.data!.length - x - 1]["sender_id"] == deviceAuth.loggedUser!["user_id"] ?
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: DateFormat.yMMMd().format(DateTime.parse(snapshot.data![snapshot.data!.length - x - 1]["created_at"].toString())) == DateFormat.yMMMd().format(DateTime.now()) ?
                                  Text(DateFormat("HH:mm a").format(DateTime.parse(snapshot.data![snapshot.data!.length - x - 1]["created_at"].toString())),style: TextStyle(fontSize: 12,color: Colors.grey),) :
                                  Text(DateFormat.yMMMd().format(DateTime.parse(snapshot.data![snapshot.data!.length - x - 1]["created_at"].toString())),style: TextStyle(fontSize: 12,color: Colors.grey),),
                                ) :
                                DateFormat.yMMMd().format(DateTime.parse(snapshot.data![snapshot.data!.length - x - 1]["created_at"].toString())) == DateFormat.yMMMd().format(DateTime.now()) ?
                                Text(DateFormat("HH:mm a").format(DateTime.parse(snapshot.data![snapshot.data!.length - x - 1]["created_at"].toString())),style: TextStyle(fontSize: 12,color: Colors.grey),) :
                                Text(DateFormat.yMMMd().format(DateTime.parse(snapshot.data![snapshot.data!.length - x - 1]["created_at"].toString())),style: TextStyle(fontSize: 12,color: Colors.grey),)
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            snapshot.data![snapshot.data!.length - x - 1]["sender_id"] == deviceAuth.loggedUser!["user_id"] ?
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                                margin: EdgeInsets.only(left: 30),
                                decoration: BoxDecoration(
                                    color: Palettes.mainColor,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(20)
                                    )
                                ),
                                child: Text(snapshot.data![snapshot.data!.length - x - 1]["body"].toString(),style: TextStyle(color: Colors.white,fontFamily: "AppFontStyle")),
                              ),
                            ) :
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: (){
                                  print(snapshot.data![snapshot.data!.length - x - 1]);
                                },
                                child: widget.isGroup ?
                                Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                                          borderRadius: BorderRadius.circular(1000)
                                      ),
                                      child: Center(child: Text(snapshot.data![snapshot.data!.length - x - 1]["name"][0].toString().toUpperCase(),style: TextStyle(color: Colors.white,fontFamily: "AppFontStyle",fontWeight: FontWeight.bold))),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                                      margin: EdgeInsets.only(right: 30),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                              bottomLeft: Radius.circular(20)
                                          )
                                      ),
                                      child: Text(snapshot.data![snapshot.data!.length - x - 1]["body"].toString(),style: TextStyle(color: Colors.black,fontFamily: "AppFontStyle")),
                                    ),
                                  ],
                                ) :
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                                  margin: EdgeInsets.only(right: 30),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20)
                                      )
                                  ),
                                  child: Text(snapshot.data![snapshot.data!.length - x - 1]["body"].toString(),style: TextStyle(color: Colors.black,fontFamily: "AppFontStyle")),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            )
                          },
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          !snapshot.hasData?
                          Container() :
                          !snapshotTyping.data! ?
                          Container() :
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            padding: EdgeInsets.only(left: 20,top: 10),
                            alignment: Alignment.centerLeft,
                            child: Image(
                              width: 45,
                              image: AssetImage("assets/icons/typing.gif"),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 90,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.white,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(1000)
                                    ),
                                    child: TextField(
                                      controller: _message,
                                      textAlignVertical: TextAlignVertical.center,
                                      style: TextStyle(fontFamily: "AppFontStyle"),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                        hintText: "Type here...",
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(fontFamily: "AppFontStyle",color: Colors.grey),
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.emoji_emotions_outlined,color: Palettes.mainColor,),
                                          onPressed: (){
                                            setState(() {
                                              _showEmoji = !_showEmoji;
                                            });
                                          },
                                        )
                                      ),
                                      onChanged: (text){
                                        print(widget.dispatch.toString());
                                        Map payload = {
                                          "sender_name": "dispatch",
                                          "sender_id": deviceAuth.loggedUser!["user_id"],
                                          "recepient_id": widget.dispatch["id"].toString(),
                                          "is_typing": true,
                                        };
                                        if(widget.isGroup){
                                          ChatServices.socket!.emit('group-typing', payload);
                                        }else{
                                          ChatServices.socket!.emit('typing', payload);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send, color: Palettes.mainColor,),
                                  onPressed: (){
                                    if(_message.text.isNotEmpty){
                                      if(widget.isGroup){
                                        _chatServices.sendGroupMessage(message: _message.text, group_id: widget.dispatch["id"]).whenComplete((){
                                          _message.text = "";
                                          _chatServices.getGroupMessages(dispatch: widget.dispatch);
                                        });
                                      }else{
                                        _chatServices.sendMessage(message: _message.text, dispatch_id: widget.dispatch["id"]).whenComplete((){
                                          _message.text = "";
                                          _chatServices.getMessages(dispatch: widget.dispatch);
                                        });
                                      }
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 100),
                            width: double.infinity,
                            height: _showEmoji ? 300 : 0,
                            child: EmojiPicker(
                              onEmojiSelected: (Category? category, Emoji emoji) {
                                // Do something when emoji is tapped (optional)
                              },
                              onBackspacePressed: () {
                                // Do something when the user taps the backspace button (optional)
                                // Set it to null to hide the Backspace-Button
                              },
                              textEditingController: _message,
                              config: Config(
                                columns: 7,
                                emojiSizeMax: 32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0),
                                verticalSpacing: 0,
                                horizontalSpacing: 0,
                                gridPadding: EdgeInsets.zero,
                                initCategory: Category.RECENT,
                                bgColor: Color(0xFFF2F2F2),
                                indicatorColor: Colors.blue,
                                iconColor: Colors.grey,
                                iconColorSelected: Colors.blue,
                                backspaceColor: Colors.blue,
                                skinToneDialogBgColor: Colors.white,
                                skinToneIndicatorColor: Colors.grey,
                                enableSkinTones: true,
                                recentsLimit: 28,
                                noRecents: const Text(
                                  'No Recents',
                                  style: TextStyle(fontSize: 20, color: Colors.black26),
                                  textAlign: TextAlign.center,
                                ), // Needs to be const Widget
                                loadingIndicator: const SizedBox.shrink(), // Needs to be const Widget
                                tabIndicatorAnimDuration: kTabScrollDuration,
                                categoryIcons: const CategoryIcons(),
                                buttonMode: ButtonMode.MATERIAL,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              }
            )
          ),
        );
      }
    );
  }
}
