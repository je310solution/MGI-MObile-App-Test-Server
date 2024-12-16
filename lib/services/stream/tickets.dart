import 'package:mapa_bea/services/apis/tickets.dart';
import 'package:rxdart/subjects.dart';

class MyTicketStream{
  BehaviorSubject<List> assigned = new BehaviorSubject.seeded([]);
  Stream get assignedStream => assigned.stream;
  List get currentAssigned => assigned.value;

  updateAssigend({required List data}){
    assigned.add(data);
  }

  // ON PROCESSING
  BehaviorSubject<List> ongoing = new BehaviorSubject();
  Stream get ongoingStream => ongoing.stream;
  List get currentOngoing => ongoing.value;

  updateOngoing({required List data}){
    ongoing.add(data);
  }

  // REMITTANCE
  BehaviorSubject<List> remittance = new BehaviorSubject();
  Stream get remittanceStream => remittance.stream;
  List get currentRemittance => remittance.value;

  updateRemittance({required List data}){
    remittance.add(data);
  }

  // ARCHIVED
  BehaviorSubject<List> archive = new BehaviorSubject();
  Stream get archiveStream => archive.stream;
  List get currentArchive => archive.value;

  updateArchive({required List data}){
    archive.add(data);
  }

  // CLOSE
  BehaviorSubject<List> close = new BehaviorSubject();
  Stream get closeStream => close.stream;
  List get currentClose => close.value;

  updateClose({required List data}){
    close.add(data);
  }

}

MyTicketStream myTicketStream = new MyTicketStream();