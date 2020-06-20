import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:delillerleislamiyet/model/bildirim.dart';
import 'package:delillerleislamiyet/model/genel_kontrol.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';
import 'package:http/http.dart' as http;

class Fonksiyon {
  static final String tag = "Fnks";

  static Uye uye;
  static final Firestore firestore = Firestore.instance;
  static final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  static final FirebaseMessaging fcm = FirebaseMessaging();
  static GenelKontrol genelKontrol;

  static bool anasayfa = true;
  static List tanidiklarim = [];
  static List kaldirdigimTanArklar = [];
  static List begenler = [];
  static List begenYorum = [];
  static List begenmeYorum = [];

  static List begenenSozler = [];
  static List begenmeyenSozler = [];
  static List begenenVeriler = [];
  static List begenmeyenVeriler = [];
  static String fcmToken;
  static String serverToken =
      'AAAA7Qms_jQ:APA91bF6SVfrbjleVxSTZSBopD99uM4Tka-V097paDnNJA3p0tTpsiNZHP4EHR1aTO1DZIWRyUhosHQIcfTaBL27SPbkQVchTgUCZSgLEYePCjoh679lZH9hksamerIHD8aUEznx7k-s';

  //Harita ücretlendirme tarifesi: https://cloud.google.com/maps-platform/pricing/
  static final String mapApiKey = "AIzaSyBEtbXmGO6OJY8Tm8_6qIt8BY-bLwYdlRw";
  static String aktifSayfa = 'AIzaSyBl4lOFjCXv';

  static Size ekran = Size(320.0, 480.0);

  static double genislik = 320.0;
  static double yukseklik = 480.0;

  static int i = 0;
  static String tabloAdi;
  static String armTblAdi;

  static String seoYap(String s) {
    final List tr = ["ğ", "ü", "ş", "ı", "ç", "ö", " "];
    final List seo = ["g", "u", "s", "i", "c", "o", "_"];
    s = s.toLowerCase().trim();
    for (int i = 0; i < tr.length; i++) {
      s = s.replaceAll(tr[i], seo[i]);
    }
    return s;
  }

  static bool admin() => uye.rutbe == 101;

  static Future konuyaAboneOl(String konu) async {
    await fcm.subscribeToTopic(konu);
    Logger.log(tag, message: "$konu konusuna abone olundu");
  }

  static Future konuAboneCik(String konu) async {
    await fcm.unsubscribeFromTopic(konu);

    Logger.log(tag, message: "$konu konusuna abonelikten çıkıldı");
  }

  static Future kullaniciEngelle(BuildContext context, String engelUye) async {
    bool engel = uye.rutbe > 15;
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: Text("Kullanıcıyı ${engel ? 'Engelle' : 'Şikayet Et'}"),
          content: Text(
            "Kullanıcıyı ${engel ? 'engellemek' : 'yönetime şikayet etmek'} istediğinizden emin misiniz?\nÖnemli!!!\nKullanıcının engellenmesi durumunda uygulama içindeki tüm aktiviteleri engellenecektir.",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Vazgeç"),
            ),
            FlatButton(
              onPressed: () {
                _kullaniciIslemYap(engelUye).whenComplete(() {
                  Navigator.pop(context);
                });
              },
              child: Text("${engel ? 'Engelle' : 'Şikayet Et'}"),
            ),
          ],
        );
      },
    );
  }

  static Future _kullaniciIslemYap(String engelUye) async {
    DocumentReference docRef =
        firestore.collection('engellenenler').document(engelUye);
    if (uye.rutbe > 15) {
      await docRef.setData({
        'engellenen_id': engelUye,
        'metin': 'Bu mesaj yetkili tarafından silindi',
        'engelleyen_id': uye.uid,
      });

      await firestore
          .collection('uyeler')
          .document(engelUye)
          .updateData({'engel': true});
    } else
      await firestore.collection('uyeler').document(engelUye).updateData({
        'sikayetler': FieldValue.arrayUnion([uye.uid])
      });
  }

  static void mesajGoster(GlobalKey<ScaffoldState> scfk, String msj) {
    scfk.currentState.showSnackBar(
      SnackBar(
        content: Text(msj),
        duration: Duration(seconds: 10),
        action: SnackBarAction(
          label: "Tamam",
          onPressed: () => scfk.currentState.removeCurrentSnackBar(),
        ),
      ),
    );
  }

  static Future<String> resimYukleHikaye({
    @required File file,
    @required String isim,
    @required String klasor,
  }) async {
    File compressedFile;
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(file.path);
    compressedFile = await FlutterNativeImage.compressImage(
      file.path,
      quality: 80,
      targetWidth: 600,
      targetHeight: (properties.height * 600 / properties.width).round(),
    );

    StorageReference storageRef;
    storageRef = firebaseStorage.ref().child(
          "$klasor/$isim.jpg",
        );

    if (storageRef != null) {
      final StorageUploadTask uploadTask = storageRef.putFile(
        compressedFile,
        StorageMetadata(
          contentType: "image/jpg",
        ),
      );
      final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      return (await downloadUrl.ref.getDownloadURL());
    } else {
      return "Hata oluştu";
    }
  }

  static void resmiGor(BuildContext context, String resimUrl, baslik,
      [String altbaslik]) {
    Widget resim = CachedNetworkImage(
      imageUrl: resimUrl ?? Linkler.thumbResim,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: BoxFit.cover,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return Scaffold(
          backgroundColor: Renk.siyah,
          appBar: AppBar(
            backgroundColor: Renk.siyah,
            centerTitle: false,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  baslik,
                  style: TextStyle(color: Renk.beyaz),
                ),
                if (altbaslik != null)
                  Text(
                    altbaslik,
                    style: TextStyle(color: Renk.beyaz, fontSize: 14.0),
                  ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Expanded(child: Center(child: resim)),
                SizedBox(height: 50.0),
              ],
            ),
          ),
        );
      },
    );
  }

  static String phoneKontrol(String deger) {
    Pattern pattern = r'^(?:[0]5)[0-9]{9}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(deger)) {
      return null;
      //return "${Yazi.telGir} ${11 - deger.length} ${Yazi.rakamGir} ";
    } else {
      return null;
    }
  }

  static String emailKontrol(String deger) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);

    if (!regex.hasMatch(deger)) {
      return Yazi.emailGir;
    } else {
      return null;
    }
  }

  static String sifreKontrol(String deger) {
    Pattern pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(deger)) {
      return Yazi.sifreGir;
    } else {
      return null;
    }
  }

  static String bosKontrol(String deger) {
    if (deger.length > 1) {
      return null;
      //return "${Yazi.telGir} ${11 - deger.length} ${Yazi.rakamGir} ";
    } else {
      return "Lütfen en az 2 karakter girin";
    }
  }

  static String zamanFarkiBul(DateTime dt) {
    String sure;
    Duration duration = DateTime.now().difference(dt);
    if (duration.inDays < 1) {
      if (duration.inHours < 1) {
        if (duration.inMinutes < 1)
          sure = "${duration.inSeconds} Sn";
        else
          sure = "${duration.inMinutes} Dk";
      } else
        sure = "${duration.inHours} Sa";
    } else if (duration.inDays < 7) {
      sure = "${duration.inDays} Gün";
    } else if (duration.inDays < 30) {
      sure = "${(duration.inDays / 7).floor()} Hafta";
    } else if (duration.inDays < 365) {
      sure = "${(duration.inDays / 30).floor()} Ay";
    } else {
      sure = "${(duration.inDays / 365).floor()} Yıl";
    }
    return sure;
  }

  static Future<String> resimYukle({
    @required File file,
    @required String isim,
    @required String klasor,
  }) async {
    File compressedFile;
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(file.path);
    compressedFile = await FlutterNativeImage.compressImage(
      file.path,
      quality: 80,
      targetWidth: 600,
      targetHeight: (properties.height * 600 / properties.width).round(),
    );

    StorageReference storageRef;
    storageRef = firebaseStorage.ref().child(
          "$klasor/$isim.jpg",
        );

    if (storageRef != null) {
      final StorageUploadTask uploadTask = storageRef.putFile(
        compressedFile,
        StorageMetadata(
          contentType: "image/jpg",
        ),
      );
      final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      return (await downloadUrl.ref.getDownloadURL());
    } else {
      return "Hata oluştu";
    }
  }

  static Future bildirimGonder({
    @required String alici,
    @required String gonderen,
    @required String tur,
    @required String baslik,
    @required String mesaj,
    @required String bBaslik,
    @required String bMesaj,
    @required List jeton,
  }) async {
    Logger.log(tag, message: jeton.toString());
    Bildirim _bil = Bildirim();
    _bil.id = '';
    _bil.gonderen = gonderen;
    _bil.alici = alici;
    _bil.tur = tur;
    _bil.baslik = bBaslik;
    _bil.aciklama = bMesaj;
    _bil.tarih = Timestamp.now();

    Map mapBody = <String, dynamic>{
      "registration_ids": jeton,
      'notification': <String, dynamic>{
        'title': baslik,
        'body': '${mesaj.length > 100 ? mesaj.substring(97) + '...' : mesaj}',
        'click_action': 'SENV2_NOTIFICATION_CLICK',
        'sound': 'default',
      },
      'priority': 'high',
      "collapse_key": Fonksiyon.uye.uid,
      /* 'data': <String, dynamic>{
        'id': "${_grup.id}",
        "routeName": "grupmesajbildirimi",
        "tip": "grupmesajbildirimi",
      } */
    };

    try {
      http.Response res = await http.post(
        'https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${Fonksiyon.serverToken}',
        },
        body: jsonEncode(mapBody),
        encoding: Encoding.getByName('utf-8'),
      );
      Logger.log(tag,
          message: "cevap kodu: ${res.statusCode} cevap: ${res.body}");
      Logger.log(tag, message: res.body);

      await Firestore.instance
          .collection('bildirimler')
          .add(_bil.toMap())
          .then((onValue) {
        Firestore.instance
            .collection('bildirimler')
            .document(onValue.documentID)
            .updateData({'id': onValue.documentID});
      });
    } catch (e) {
      Logger.log(tag, message: "hata oluştu: $e");
    }
  }
}
