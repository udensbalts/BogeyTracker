import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  //get collection

  final CollectionReference laukumi =
      FirebaseFirestore.instance.collection('laukumi');

  //pievienot laukumu
  Future<void> addLaukums(String laukums, String grozi) {
    return laukumi.add({
      'laukums': laukums,
      'grozi': grozi,
      'timestamp': Timestamp.now(),
    });
  }
}
