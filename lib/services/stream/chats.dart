
import 'package:rxdart/rxdart.dart';

class ChatStreamServices{
  // DISPATCHER
  BehaviorSubject<List> subject = new BehaviorSubject();
  Stream get stream => subject.stream;
  List get current => subject.value;

  updateDispatch({required List data}){
    subject.add(data);
  }

  // GROUPS
  BehaviorSubject<List> groups = new BehaviorSubject();
  Stream get streamGroups => groups.stream;
  List get currentGroup => groups.value;

  updateGroups({required List data}){
    groups.add(data);
  }

  // GROUP MEMBERS
  BehaviorSubject<List> members = new BehaviorSubject();
  Stream get streamMembers => members.stream;
  List get currentMembers => members.value;

  updateMembers({required List data}){
    members.add(data);
  }

  // MESSAGES
  BehaviorSubject<List> message = new BehaviorSubject();
  Stream get streamMessage => message.stream;
  List get currentMessage => message.value;

  updateMessage({required List data}){
    message.add(data);
  }

  // TYPING CHECKER
  BehaviorSubject<bool> typing = new BehaviorSubject();
  Stream get streamTyping => typing.stream;
  bool get currentTyping => typing.value;

  updateTyping({required bool data}){
    typing.add(data);
  }
}

ChatStreamServices chatStreamServices = new ChatStreamServices();