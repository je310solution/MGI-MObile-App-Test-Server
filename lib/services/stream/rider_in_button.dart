import 'package:rxdart/subjects.dart';

class RiderButtonStream{
  BehaviorSubject<bool> subject = new BehaviorSubject();
  Stream get stream => subject.stream;
  bool get current => subject.value;

  update({required bool data}){
    subject.add(data);
  }
}

RiderButtonStream riderButtonStream = new RiderButtonStream();