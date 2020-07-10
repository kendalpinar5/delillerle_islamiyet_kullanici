import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:http/http.dart' as http;
import 'package:delillerleislamiyet/grup/grup_anket_ekle.dart';
import 'package:delillerleislamiyet/grup/grup_mesaj_widget.dart';
import 'package:delillerleislamiyet/model/bildirim.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/mesaj.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/yeni_grup/mesaj_yaz_widget.dart';

class YeniGrupMesajlar extends StatefulWidget {
  final Grup grup;

  const YeniGrupMesajlar({Key key, @required this.grup}) : super(key: key);
  @override
  _YeniGrupMesajlarState createState() => _YeniGrupMesajlarState();
}

class _YeniGrupMesajlarState extends State<YeniGrupMesajlar> {
  final String tag = "YeniGrupMesajlar";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  Grup _grup;
  Firestore _firestore = Firestore.instance;

  Size _ekran;

  bool _islem = false;
  bool _dipMi = true;
  bool _klavye = false;
  bool _gittim = false;
  bool _rYukleniyor = false;
  bool _silYetki;

  double _sY = 0;
  double _sO = 0;

  File _file;

  Future _bildirimGonder({
    @required String baslik,
    @required String mesaj,
  }) async {
    for (int i = 0; i < widget.grup.katilimcilar.length; i++) {
      Bildirim _bil = Bildirim();
      _bil.id = '';
      _bil.gonderen = Fonksiyon.uye.uid;
      _bil.alici = widget.grup.katilimcilar[i];
      _bil.tur = 'gurup_mesaj';
      _bil.baslik = baslik;
      _bil.aciklama = mesaj;
      _bil.tarih = Timestamp.now();

      await Firestore.instance.collection('bildirimler').add(_bil.toMap()).then((onValue) {
        Firestore.instance
            .collection('bildirimler')
            .document(onValue.documentID)
            .updateData({'id': onValue.documentID});
      });
    }

    List sesliJetonlar = _grup.sesliler.where((test) => test != Fonksiyon.fcmToken).toList();
    List sessizJetonlar = _grup.sessizler.where((test) => test != Fonksiyon.fcmToken).toList();

    Map mapBody = <String, dynamic>{
      "registration_ids": sessizJetonlar,
      'notification': <String, dynamic>{
        'title': baslik,
        'body': '${mesaj.length > 100 ? mesaj.substring(97) + '...' : mesaj}',
        'click_action': 'SENV2_NOTIFICATION_CLICK',
      },
      'priority': 'high',
      "collapse_key": "grup${_grup.id}",
      'data': <String, dynamic>{
        'id': "${_grup.id}",
        "routeName": "grupmesajbildirimi",
        "tip": "grupmesajbildirimi",
      }
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
      Logger.log(tag, message: "cevap kodu: ${res.statusCode} cevap: ${res.body}");
      Logger.log(tag, message: res.body);
    } catch (e) {
      Logger.log(tag, message: "hata oluştu: $e");
    }

    mapBody['registration_ids'] = sesliJetonlar;
    mapBody['notification']['sound'] = 'default';
    mapBody['data']['ses'] = true;

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
      Logger.log(tag, message: "cevap kodu: ${res.statusCode} cevap: ${res.body}");
      Logger.log(tag, message: res.body);
    } catch (e) {
      Logger.log(tag, message: "hata oluştu: $e");
    }
  }

  /* Future _konumsec(LatLng k) async {
    _islem = true;
    if (!_gittim) setState(() {});

    Mesaj msj = Mesaj(
      gonderen: Fonksiyon.uye.gorunenIsim,
      yazan: Fonksiyon.uye.uid,
      yazanRsm: Fonksiyon.uye.resim,
      grupid: _grup.id,
      metin: 'konum',
      enlem: k.latitude,
      boylam: k.longitude,
      tarih: FieldValue.serverTimestamp(),
    );

    await Firestore.instance
        .collection('gruplar')
        .document(_grup.id)
        .collection('mesajlar')
        .document(Timestamp.now().millisecondsSinceEpoch.toString())
        .setData(msj.toMap());

    _bildirimGonder(
      baslik: "${_grup.baslik}",
      mesaj: "${Fonksiyon.uye.gorunenIsim} bir konum paylaştı",
    );

    _islem = false;
    if (!_gittim) setState(() {});
  } */

  Future _resimSec() async {
    _rYukleniyor = true;
    if (!_gittim) setState(() {});

    _file = await FilePicker.getFile(type: FileType.image);
    if (_file != null) {
      _resmiGonderGor();
    }

    _rYukleniyor = false;
    if (!_gittim) setState(() {});
  }

  Future _resmiGonderGor() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.center,
          color: Renk.siyah.withAlpha(180),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(height: _ekran.height / 2, child: Image.file(_file)),
                Row(
                  children: <Widget>[
                    SizedBox(width: 16.0),
                    FloatingActionButton(
                      elevation: 0.0,
                      backgroundColor: Color(0),
                      onPressed: () => Navigator.pop(context),
                      child: Icon(Icons.close),
                    ),
                    Spacer(),
                    FloatingActionButton(
                      elevation: 0.0,
                      backgroundColor: Renk.yesil,
                      onPressed: () {
                        _mesajGonder('resim');
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.send),
                    ),
                    SizedBox(width: 16.0),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _mesajGonder(String m) async {
    Logger.log(tag, message: m);
    String resim = '';
    if (_file != null && m == 'resim') {
      _islem = true;
      if (!_gittim) setState(() {});
      StorageReference storageRef;

      storageRef = FirebaseStorage.instance.ref().child(
            "grupmesajresimleri/${Random().nextInt(10000000).toString()}.jpg",
          );

      ImageProperties properties = await FlutterNativeImage.getImageProperties(_file.path);
      File compressedFile = await FlutterNativeImage.compressImage(
        _file.path,
        quality: 80,
        targetWidth: 500,
        targetHeight: (properties.height / (properties.width / 500)).round(),
      );

      if (storageRef != null) {
        final StorageUploadTask uploadTask = storageRef.putFile(
          compressedFile,
          StorageMetadata(contentType: "image/jpg"),
        );
        final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

        resim = (await downloadUrl.ref.getDownloadURL());
      }
      _islem = false;
    }

    Mesaj msj = Mesaj(
      gonderen: Fonksiyon.uye.gorunenIsim,
      yazan: Fonksiyon.uye.uid,
      yazanRsm: Fonksiyon.uye.resim,
      grupid: _grup.id,
      metin: m,
      resim: resim,
      tarih: FieldValue.serverTimestamp(),
    );

    await Firestore.instance
        .collection('gruplar')
        .document(_grup.id)
        .collection('mesajlar')
        .document(Timestamp.now().millisecondsSinceEpoch.toString())
        .setData(msj.toMap());

    _bildirimGonder(
      baslik: "${_grup.baslik}",
      mesaj: "${Fonksiyon.uye.gorunenIsim} bir resim paylaştı",
    );

    if (!_gittim) setState(() {});
  }

  void _scrollToBottom({String yazan, String mesaj}) {
    if (yazan != null)
      _bildirimGonder(
        baslik: "$yazan, ${_grup.baslik} gurubuna mesaj yazdı",
        mesaj: mesaj,
      );

    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: ((_sO + 1) / 5).floor()),
      curve: Curves.easeOut,
    );
  }

  void _resmiGor(Mesaj msj) {
    DateTime time = msj.tarih.toDate();
    bool ben = msj.yazan == Fonksiyon.uye.uid;

    Fonksiyon.resmiGor(
      context,
      msj.resim ?? Linkler.thumbResim,
      ben ? "Siz" : msj.gonderen,
      "${Fonksiyon.zamanFarkiBul(time)} Önce",
    );
  }

  void _msjSikayetEt(Mesaj msj) {
    _silYetki = (Fonksiyon.uye.rutbe > 15 || msj.yazan == Fonksiyon.uye.uid) && msj.metin != "Bu mesaj silindi";
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: Text("Mesajı ${_silYetki ? 'Sil' : 'Şikayet Et'}"),
          content: Text(
            "Mesaj içeriğini ${_silYetki ? 'silmek' : 'yönetime şikayet etmek'} istediğinizden emin misiniz?",
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Vazgeç"),
            ),
            FlatButton(
              onPressed: () => _msjIslemYap(msj).whenComplete(() {
                Navigator.pop(context);
              }),
              child: Text("${_silYetki ? 'Sil' : 'Şikayet Et'}"),
            ),
          ],
        );
      },
    );
  }

  Future _msjIslemYap(Mesaj msj) async {
    DocumentReference docRef =
        _firestore.collection('gruplar').document(_grup.id).collection('mesajlar').document(msj.id);

    if (_silYetki)
      await docRef.updateData({
        'silinen_mesaj': msj.metin,
        'metin': "Bu mesaj silindi",
        'mesaji_silen': Fonksiyon.uye.uid,
      });
    else
      await docRef.updateData({
        'sikayetler': FieldValue.arrayUnion([Fonksiyon.uye.uid])
      });

    Fonksiyon.mesajGoster(_scaffoldKey, "İşleminiz başarıyla gerçekleşti");
  }

  @override
  void initState() {
    _grup = widget.grup;
    _ekran = Fonksiyon.ekran;

    _scrollController.addListener(() {
      _sO = _scrollController.offset;
      _sY = _scrollController.position.viewportDimension;
      Logger.log(tag, message: "_sO: $_sO / _sY: $_sY");
      Logger.log(tag, message: "${_scrollController.position.outOfRange}");
      if (_sO < _sY + 120) {
        if (!_dipMi) setState(() => _dipMi = true);
      } else {
        if (_dipMi) setState(() => _dipMi = false);
      }
    });

    KeyboardVisibilityNotification().addNewListener(onChange: (v) => _klavye = v);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    KeyboardVisibilityNotification().dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _klavye ? () => FocusScope.of(context).requestFocus(FocusNode()) : null,
      child: Scaffold(
        key: _scaffoldKey,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _dipMi
            ? null
            : FloatingActionButton(
                onPressed: _scrollToBottom,
                child: Icon(Icons.arrow_downward),
              ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: _firestore
                    .collection('gruplar')
                    .document(_grup.id)
                    .collection('mesajlar')
                    .orderBy('tarih', descending: true)
                    .limit(120)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Text('Hiç Mesaj Yok');
                  else
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListView.builder(
                        reverse: true,
                        controller: _scrollController,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (ctx, i) {
                          DocumentSnapshot ds = snapshot.data.documents[i];
                          Mesaj msj = Mesaj.fromMap(ds.data, ds.documentID);

                          return InkWell(
                            onLongPress: _klavye ? null : () => _msjSikayetEt(msj),
                            child: GrupMesajWidget(
                              ekran: _ekran,
                              resmiGor: _resmiGor,
                              msj: msj,
                            ),
                          );
                        },
                      ),
                    );
                },
              ),
            ),
            if (_islem || _rYukleniyor)
              SizedBox(
                height: 4.0,
                child: Center(child: LinearProgressIndicator()),
              ),
            Opacity(
              opacity: _dipMi ? 1.0 : 0.0,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    PopupMenuButton<int>(
                      onSelected: (s) {
                        Logger.log(tag, message: "seçilen menü: $s");
                        switch (s) {
                          case 0:
                            _resimSec();
                            break;

                          case 1:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GrupAnketEkle(grup: _grup),
                              ),
                            );
                            break;

                          case 2:
                            /*  Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HaritaSec(secim: _konumsec),
                              ),
                            ); */
                            break;
                        }
                      },
                      icon: Icon(Icons.add_circle_outline),
                      itemBuilder: (_) => <PopupMenuEntry<int>>[
                        PopupMenuItem<int>(
                          value: 0,
                          child: Text("Resim Gönder"),
                        ),
                        PopupMenuItem<int>(
                          value: 1,
                          child: Text("Anket Oluştur"),
                        ),
                        /*  PopupMenuItem<int>(
                          value: 2,
                          child: Text("Konum Gönder"),
                        ), */
                      ],
                    ),
                    if (!_grup.baslik.toLowerCase().contains('duyuru') || Fonksiyon.uye.rutbe > 10)
                      Expanded(
                        child: MesajYazWidget(
                          grupID: _grup.id,
                          scrollToBottom: _scrollToBottom,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
