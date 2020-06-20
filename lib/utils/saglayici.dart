import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';

class Saglayici with ChangeNotifier {
  final String tag = "Saglayici Provider";

  Stream<QuerySnapshot> sS;

  bool akisAsagi = false;

  akisDegistir() {
    akisAsagi = !akisAsagi;
    notifyListeners();
  }

  firebaseDinle() {
    sS = Firestore.instance.collection('stream_deneme').snapshots();
    sS.listen((onData) {
      QuerySnapshot qs = onData;
      List<DocumentSnapshot> docs = qs.documents;
      Logger.log(tag, message: "firebase Takip Et: ${docs.length}");
      for (DocumentSnapshot ds in docs) {
        Logger.log(tag, message: "firebase döküman metadata: ${ds.metadata}");
        Logger.log(tag,
            message: "firebase döküman documentID: ${ds.documentID}");
        Logger.log(tag,
            message: "firebase döküman data: ${ds.data.toString()}");
      }
    });
  }

  Future cikisYap() async {
    final GoogleSignIn googleSignIn = new GoogleSignIn();

    bool googleSignedIn = await googleSignIn.isSignedIn();

    if (googleSignedIn) {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }

    FirebaseAuth.instance.signOut();
    notifyListeners();

    Fonksiyon.uye = null;
  }
}
