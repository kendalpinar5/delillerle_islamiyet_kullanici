import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delillerleislamiyet/animasyon/kaydirma.dart';
import 'package:delillerleislamiyet/kfcdrawer/class_builder.dart';
import 'package:delillerleislamiyet/kfcdrawer/kf_drawer_menu.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/uyelik/giris.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UyeKontrol extends StatefulWidget {
  @override
  _UyeKontrolState createState() => _UyeKontrolState();
}

class _UyeKontrolState extends State<UyeKontrol> with RouteAware {
  final String tag = "UyeKontrol";
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final Firestore _db = Firestore.instance;

  Box _kutu;

  StreamSubscription iosSubscription;
  bool _cevapGeldi = false;
  bool _bas = true;

  _girisKontrol() async {
    await Hive.initFlutter('delilerleislamiyet');
    ClassBuilder.registerClasses();
    Logger.log(tag, message: 'Hive acıldı');
    await FirebaseAuth.instance.currentUser();
    _kutu = await Hive.openBox('kayitaraci');
    _kutu.watch(key: 'kullanici').listen((onData) {
      setState(() {});
      Logger.log(
        tag,
        message: "_kutu.watch ${onData.value} ${onData.key} ${onData.deleted}",
      );
    });

    if (_kutu.get('kullanici') != null) {
      Fonksiyon.uye = Uye.fromMap(
        Map<String, dynamic>.from(_kutu.get('kullanici')),
      );

      _bildirimAl();
    }
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (Fonksiyon.uye == null) {
      if (user != null) {
        await _uyeEslestir(user.uid);
      }
    } else {
      //  _kullaniciCek(Fonksiyon.uye.uid);
    }

    //  await Future.delayed(Duration(milliseconds: 500));

    _cevapGeldi = true;
    Logger.log(tag, message: _kutu.get('kullanici').toString());
    setState(() {});
  }

  /*  _kullaniciCek(String id) async {
    await FireDB.firestore.collection('uyeler').document(id).get().then((value) {
      Fonksiyon.temaRengi = value.data['temaRengi'] ?? 4279405694;
    });
  } */

  _uyeEslestir(String useruid) async {
    Logger.log(tag, message: "uyeEslestir useruid: $useruid");

    try {
      DocumentSnapshot ds = await Firestore.instance.collection('uyeler').document(useruid).get();

      Logger.log(tag, message: "uyeEslestir DocumentSnapshot: ${ds.data}");
      _kutu.put('kullanici', Uye.fromMap(ds.data).toMap());
      if (_kutu.get('kullanici') != null)
        Fonksiyon.uye = Uye.fromMap(
          Map<String, dynamic>.from(_kutu.get('kullanici')),
        );
    } catch (e) {
      Logger.log(tag, message: "uyeEslestir catch (e): $e");
    }

    _bildirimAl();

    Logger.log(tag, message: "uyeEslestir useruid 3: $useruid");

    if (!Fonksiyon.uye.telOnay) {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      if (user?.phoneNumber != null) {
        Fonksiyon.uye.telefon = user.phoneNumber;
        Fonksiyon.uye.telOnay = true;
        await _db.collection('uyler').document(Fonksiyon.uye.uid).updateData(Fonksiyon.uye.toMap());

        _kutu.put('kullanici', Fonksiyon.uye.toMap());
      }
    }
  }

  _saveDeviceToken() async {
    Fonksiyon.fcmToken = await _fcm.getToken();

    if (Fonksiyon.fcmToken != null && Fonksiyon.uye != null) {
      Logger.log('asasasasa', message: 'bildirim jetonu geldı');
      await _db.collection('uyeler').document(Fonksiyon.uye.uid).updateData({
        'bildirimjetonu': Fonksiyon.fcmToken,
      });
    }
  }

  _bildirimAlertCalistir(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message['notification']['title']),
        content: Text(message['notification']['body']),
        actions: <Widget>[
          FlatButton(
            child: Text('Tamam'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future _bildirimCalistir(Map<String, dynamic> message, [bool onmesaj = false]) async {
    Map data = message['data'];

    switch (data['tip']) {
      /*  case "duyuru":
        bilgilendime(context, message, onmesaj);
        break;

      case "grupmesajbildirimi":
        grupMesaj(context, message, onmesaj);
        break;

      case "duellorakipgeldi":
        duelloRakipGeldi(context, message, onmesaj);
        break;

      case "etkinlikmesajbildirimi":
        etkinlikMesajMildirimi(context, message, onmesaj);
        break; */

      default:
        _bildirimAlertCalistir(message);
        break;
    }
  }

  _bildirimAl() {
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        Logger.log(tag, message: data.toString());
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    try {
      _fcm.configure(
        // onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
        onMessage: (Map<String, dynamic> message) async {
          Logger.log(tag, message: "onMessage: $message");
          /*   if (YerelBildirim.flutterLocalNotificationsPlugin == null)
            YerelBildirim.ilkKurulum(context); */

          _bildirimCalistir(message, true);
        },
        onLaunch: (Map<String, dynamic> message) async {
          Logger.log(tag, message: "onLaunch: $message");

          _bildirimCalistir(message);
        },
        onResume: (Map<String, dynamic> message) async {
          Logger.log(tag, message: "onResume: $message");

          _bildirimCalistir(message);
        },
      );
    } catch (e) {
      Logger.log(tag, message: "hata oluştu: $e");
    }
  }

  Scaffold _s = Scaffold(
    backgroundColor: Renk.wpKoyu,
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FadeAnimation(
          0.3,
          Center(
            child: Image.asset(
              'assets/images/icon.png',
              fit: BoxFit.contain,
              width: Fonksiyon.ekran.width / 2,
            ),
          ),
        ),
        SizedBox(height: 10),
        FadeAnimation(
          0.4,
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Delillerle İslamiyet",
                style: TextStyle(
                  color: Renk.beyaz,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Renk.beyaz),
            ),
          ),
        ),
      ],
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Logger.log(tag, message: 'geldi');

    Fonksiyon.ekran = MediaQuery.of(context).size;
    if (_bas) {
      _girisKontrol();
      _bas = false;
      //saglayici.firebaseDinle();
    }
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _cevapGeldi ? _kutu.get('kullanici') == null ? GirisYapSyf(kutu: _kutu) : KfDrawerMenu() : _s;
  }
}
