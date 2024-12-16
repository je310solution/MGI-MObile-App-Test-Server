import 'package:rxdart/rxdart.dart';

class PopupChecker{
  BehaviorSubject<bool> subject = new BehaviorSubject();
  Stream get stream => subject.stream;
  bool get current => subject.value;

  update({required bool data}){
    subject.add(data);
  }

  // CHECK IF FIRST TICKET
  BehaviorSubject<bool> isfirst = new BehaviorSubject.seeded(false);
  Stream get streamIsfirst => isfirst.stream;
  bool get currentIsfirst => isfirst.value;

  updateIsfirst({required bool data}){
    isfirst.add(data);
  }
}

PopupChecker popupChecker = new PopupChecker();