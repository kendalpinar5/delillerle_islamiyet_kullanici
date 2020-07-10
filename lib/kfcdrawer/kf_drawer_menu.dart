import 'dart:io';

import 'package:delillerleislamiyet/kfcdrawer/class_builder.dart';
import 'package:delillerleislamiyet/kfcdrawer/gelistirme_page.dart';
import 'package:delillerleislamiyet/kfcdrawer/gunun_sozu_page.dart';
import 'package:delillerleislamiyet/kfcdrawer/kf_drawer_controller.dart';
import 'package:delillerleislamiyet/kfcdrawer/main_page.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:package_info/package_info.dart';

class KfDrawerMenu extends StatefulWidget {
  @override
  _KfDrawerMenuState createState() => _KfDrawerMenuState();
}

class _KfDrawerMenuState extends State<KfDrawerMenu> {
  final String tag = "KfDrawerMenu";

  KFDrawerController _drawerController;
  Box _kutu;

  Map<String, dynamic> _deviceData = <String, dynamic>{};

  Future<void> _initPlatformState() async {
    _kutu = await Hive.openBox('kayitaraci');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    Fonksiyon.firestore.collection('uyeler').document(Fonksiyon.uye.uid).updateData({
      'platform': Platform.isAndroid ? 'android' : 'iOS',
      'platform_bilgileri': _deviceData,
      'paket': {
        'appName': appName,
        'packageName': packageName,
        'version': version,
        'buildNumber': buildNumber,
      }
    });
  }

  Future<void> _signOut(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await FirebaseAuth.instance.signOut();
      bool googleSignedIn = await googleSignIn.isSignedIn();
      if (googleSignedIn) {
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }
      Fonksiyon.uye = null;
    } catch (e) {
      Logger.log(tag, message: e.toString());
    }
  }

  _confirmSignOut() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Çıkış'),
          content: Text('Uygulamadan çıkmak istediğinizden emin misiniz?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
                _signOut(context).whenComplete(() {
                  _kutu.delete('kullanici');

                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/'),
                  );
                  setState(() {});
                });
              },
              child: Text('Çıkış'),
            ),
          ],
        );
      },
    );
  }

  void _basla() {
    _drawerController = KFDrawerController(
      initialPage: ClassBuilder.fromString('MainPage'),
      items: [
        KFDrawerItem.initWithPage(
          text: Text('Anasayfa', style: TextStyle(color: Renk.beyaz)),
          icon: Icon(Icons.home, color: Renk.beyaz),
          page: MainPage(),
        ),
        KFDrawerItem.initWithPage(
          text: Text(
            'Günün Ayeti/Hadisi',
            style: TextStyle(color: Renk.beyaz),
          ),
          icon: Icon(
            FontAwesomeIcons.bookOpen,
            color: Renk.beyaz,
            size: 18,
          ),
          page: GununSozuPage(),
        ),
        KFDrawerItem.initWithPage(
          text: Text(
            'Geliştirme',
            style: TextStyle(color: Renk.beyaz),
          ),
          icon: Icon(Icons.developer_mode, color: Renk.beyaz),
          page: GelistirmePage(),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _basla();
    _initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Fonksiyon.anasayfa)
          return true;
        else {
          _basla();
          Fonksiyon.anasayfa = true;
          setState(() {});
          return false;
        }
      },
      child: Scaffold(
        body: KFDrawer(
          controller: _drawerController,
          header: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              width: Fonksiyon.ekran.width * 0.5,
              child: Image.asset(
                'assets/images/icon.png',
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          footer: Column(
            children: <Widget>[
              KFDrawerItem(
                text: Text(
                  'Puan Ver',
                  style: TextStyle(color: Renk.beyaz),
                ),
                icon: Icon(Icons.star, color: Renk.beyaz),
                onPressed: () {
                  /* String iosMarket =
                      "itms-apps://itunes.apple.com/us/app/id1472551764";
                  String androidMarket =
                      "market://details?id=dershub.senv2yayin";
                  launch(Platform.isIOS ? iosMarket : androidMarket); */
                },
              ),
              KFDrawerItem(
                text: Text(
                  'Çıkış Yap',
                  style: TextStyle(color: Renk.beyaz),
                ),
                icon: Icon(Icons.input, color: Renk.beyaz),
                onPressed: () {
                  _confirmSignOut();
                },
              ),
            ],
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Renk.beyaz, Renk.wp, Renk.wpKoyu],
              tileMode: TileMode.repeated,
            ),
          ),
        ),
      ),
    );
  }
}
