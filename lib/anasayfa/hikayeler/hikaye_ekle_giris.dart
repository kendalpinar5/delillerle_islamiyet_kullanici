import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:delillerleislamiyet/model/hikaye_model.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';

class HikayeEkleGiris extends StatefulWidget {
  @override
  _HikayeEkleGirisState createState() => _HikayeEkleGirisState();
}

class _HikayeEkleGirisState extends State<HikayeEkleGiris> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final String tag = "HikayeEkleGiris";
  File _file;

  bool _kaydediliyor = false;
  List _resimler = [];
  Hikaye _hikayem = Hikaye();
  Future _resimSec() async {
    await FilePicker.getFile(type: FileType.image).then((onValue) {
      if (onValue != null) {
        Logger.log(tag, message: onValue.path);
        _file = onValue;
      }

      setState(() {});
    });
  }

  Future _hikayeKaydet() async {
    _kaydediliyor = true;
    setState(() {});
    Logger.log(tag, message: 'gedi');
    String zaman = Timestamp.now().millisecondsSinceEpoch.toString();
    Logger.log(tag, message: zaman);
    StorageReference storageRef;

    if (_file != null) {
      storageRef = FirebaseStorage.instance.ref().child(
            "hikayeresimleri/${Random().nextInt(10000000).toString()}.jpg",
          );
      File compressedFile;
      ImageProperties properties = await FlutterNativeImage.getImageProperties(_file.path);
      compressedFile = await FlutterNativeImage.compressImage(
        _file.path,
        quality: 80,
        targetWidth: 500,
        targetHeight: (properties.height * 600 / properties.width).round(),
      );

      if (storageRef != null) {
        final StorageUploadTask uploadTask = storageRef.putFile(
          compressedFile,
          StorageMetadata(contentType: "image/jpg"),
        );
        final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

        _resimler.add(await downloadUrl.ref.getDownloadURL());
      }

      Logger.log('resim sayısı', message: _resimler.length.toString());

      _hikayem.tarih = Timestamp.now();

      _hikayem.ekleyen = Fonksiyon.uye.uid;

      _hikayem.resim = _resimler;

      _hikayem.onay = true;

      CollectionReference reference = Fonksiyon.firestore.collection('hikayeler');
      if (_hikayem.id != null) {
        await reference.document(_hikayem.id).updateData(_hikayem.toMap());
      } else {
        _hikayem.id = zaman;
        await reference.document(zaman).setData(_hikayem.toMap());
      }

      mesajGoster('Hikayeniz eklenmiştir...', true);
      /*   await Future.delayed(Duration(seconds: 2));
     // if (widget.duzenle != null) widget.duzenle(_hikaye);
    //  if (widget.yenile != null) widget.yenile();
      Navigator.pop(context); */
    } else {
      Fonksiyon.mesajGoster(
        _scaffoldKey,
        "Lütfen hikayenize resim yükleyin!",
      );
    }

    _kaydediliyor = false;
    setState(() {});
  }

  Future mesajGoster(String mesaj, bool sonMu) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Hikaye Durum'),
          content: Text(mesaj),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _file = null;
                setState(() {});
                Navigator.pop(context);
              },
              child: Text(Yazi.tamam),
            )
          ],
        );
      },
    );
  }

  _hikayeCek() async {
    await Firestore.instance
        .collection('hikayeler')
        .where('ekleyen', isEqualTo: Fonksiyon.uye.uid)
        .getDocuments()
        .then((value) {
      if (value.documents.length > 0) {
        Logger.log(tag, message: 'hikaye var');
        for (DocumentSnapshot ds in value.documents) {
          _hikayem = Hikaye.fromMap(ds.data);
          _resimler = _hikayem.resim ?? [];
          setState(() {});
        }
      } else {
        _hikayem.ekleyen = Fonksiyon.uye.uid;
        _hikayem.goruntulenme = 0;
        _hikayem.onay = true;
        _hikayem.tarih = Timestamp.now();
        _resimler = _hikayem.resim ?? [];
      }
    });
  }

  _resimSil(String resUrl) async {
    _hikayem.resim.remove(resUrl);
    Logger.log(tag, message: _hikayem.resim.toString());
    await Firestore.instance.collection('hikayeler').document(_hikayem.id).updateData({'resim': _hikayem.resim});
    resimSil(resUrl);
    setState(() {});
  }

  resimSil(String res) {
    RegExp desen = RegExp("hikayeresimleri%2F(.*?).jpg");
    Match ma = desen.firstMatch(res);

    FirebaseStorage.instance.ref().child('hikayeresimleri/${ma.group(1)}.jpg').delete().whenComplete(() {
      Logger.log(tag, message: "eşleşen: ${ma.group(1)}");
    });
  }

  @override
  void initState() {
    _hikayeCek();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Renk.beyaz,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, color: Renk.wpKoyu),
            ),
            title: Text(
              "Hikaye Ekle",
              style: TextStyle(color: Renk.wpKoyu),
            ),
            actions: <Widget>[
              _kaydediliyor
                  ? Center(child: CircularProgressIndicator())
                  : IconButton(
                      onPressed: () {
                        Logger.log(tag, message: "Söz Kaydet tıklandı");
                        if (_file != null) _hikayeKaydet();
                      },
                      icon: Icon(
                        Icons.check,
                        color: _file == null ? Renk.beyaz : Renk.wpKoyu,
                      ),
                    ),
            ],
          ),
          body: Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (_hikayem.id != null && _hikayem.resim.length > 0)
                  Column(
                    children: <Widget>[
                      Container(
                        child: Text('Hikayelerim'),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 4,
                        width: double.maxFinite,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _hikayem.resim.length,
                            itemBuilder: (_, i) {
                              return Stack(
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 20),
                                      height: MediaQuery.of(context).size.height / 5,
                                      width: MediaQuery.of(context).size.width / 4.375,
                                      decoration: BoxDecoration(
                                        color: Renk.gGri,
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage(_hikayem.resim[i]),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            height: 40,
                                            width: 40,
                                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Renk.beyaz, width: 2),
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              alignment: Alignment.topLeft,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(50),
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                      Fonksiyon.uye.resim,
                                                    ),
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 40,
                                              width: double.maxFinite,
                                              alignment: Alignment.bottomLeft,
                                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              child: Text(
                                                Fonksiyon.uye.gorunenIsim,
                                                style: TextStyle(color: Renk.beyaz, fontWeight: FontWeight.normal),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    alignment: Alignment.center,
                                    decoration:
                                        BoxDecoration(color: Renk.gGri12, borderRadius: BorderRadius.circular(50)),
                                    child: Center(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          padding: EdgeInsets.all(0),
                                          icon: Icon(
                                            Icons.close,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _resimSil(_hikayem.resim[i]);
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                Expanded(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text('Yeni Hikaye'),
                        ),
                        InkWell(
                          onTap: () {
                            /*  if (_file != null)
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => HikayeBak(
                                            gHik: _hikayem,
                                            gUye: Fonksiyon.uye,
                                          ))); */
                          },
                          child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 3, vertical: 20),
                              height: MediaQuery.of(context).size.height / 4,
                              width: MediaQuery.of(context).size.width / 3.5,
                              decoration: BoxDecoration(
                                color: Renk.gGri,
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: _file == null
                                      ? NetworkImage('https://www.teb.org.tr/images/no-photo.png')
                                      : FileImage(
                                          _file,
                                        ),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: 40,
                                    width: 40,
                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Renk.beyaz, width: 2),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      alignment: Alignment.topLeft,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              Fonksiyon.uye.resim,
                                            ),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      width: double.maxFinite,
                                      alignment: Alignment.bottomLeft,
                                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Text(
                                        Fonksiyon.uye.gorunenIsim,
                                        style: TextStyle(color: Renk.beyaz, fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Container(
                            height: 90,
                            width: 90,
                            padding: EdgeInsets.all(4),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                color: Renk.wpAcik,
                                onPressed: () {},
                                child: Center(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.image,
                                      color: Renk.beyaz,
                                      size: MediaQuery.of(context).size.width / 15,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Yazı Ekle',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Renk.beyaz,
                                        fontSize: MediaQuery.of(context).size.width / 30,
                                      ),
                                    ),
                                  ],
                                )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Container(
                            height: 90,
                            width: 90,
                            padding: EdgeInsets.all(4),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                color: Renk.wp,
                                onPressed: _resimSec,
                                child: Center(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.image,
                                      color: Renk.beyaz,
                                      size: MediaQuery.of(context).size.width / 15,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Görsel Seç',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Renk.beyaz,
                                        fontSize: MediaQuery.of(context).size.width / 32,
                                      ),
                                    ),
                                  ],
                                )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
