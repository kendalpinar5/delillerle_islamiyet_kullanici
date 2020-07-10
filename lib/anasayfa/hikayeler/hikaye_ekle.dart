import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:delillerleislamiyet/model/hikaye_model.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';

class HikayeEkle extends StatefulWidget {
  final Hikaye gHikaye;

  const HikayeEkle({Key key, this.gHikaye}) : super(key: key);
  @override
  _HikayeEkleState createState() => _HikayeEkleState();
}

class _HikayeEkleState extends State<HikayeEkle> {
  final String tag = "HikayeEkle";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final int maxUzunluk = 44;
  Hikaye _hikaye;
  List<String> _resimler;

  List<File> _files = [];
  bool _bas = true;

  bool _autoValidate = false;
  bool _kaydediliyor = false;

  Future _resimSec() async {
    await FilePicker.getFile(type: FileType.image).then((onValue) {
      if (onValue != null) {
        Logger.log(tag, message: onValue.path);
        _files.add(onValue);
      }
      setState(() {});
    });
  }

  void _resimSil(int i) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Silme Uyarısı"),
          content: Text("Resmi silmek istediğinizden emin misiniz?"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                if (i < _hikaye.resim.length) {
                  _hikaye.resim.removeAt(i);
                } else {
                  _files.removeAt(i - _hikaye.resim.length);
                }
                setState(() {});
                Navigator.pop(context);
              },
              child: Text("Evet"),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Hayır"),
            ),
          ],
        );
      },
    );
  }

  Future _hikayeKaydet() async {
    _kaydediliyor = true;
    setState(() {});
    Logger.log(tag, message: 'gedi');
    String zaman = Timestamp.now().millisecondsSinceEpoch.toString();
    Logger.log(tag, message: zaman);
    StorageReference storageRef;

    if (_files.length > 0) {
      for (File dosya in _files) {
        Logger.log(tag, message: "Dosya: ${dosya.path}");
        storageRef = FirebaseStorage.instance.ref().child(
              "hikayeresimleri/${Random().nextInt(10000000).toString()}.jpg",
            );
        File compressedFile;
        ImageProperties properties = await FlutterNativeImage.getImageProperties(dosya.path);
        compressedFile = await FlutterNativeImage.compressImage(
          dosya.path,
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

          if (_hikaye.resim != null) resimSil(_hikaye.resim[0]);
          _resimler.add(await downloadUrl.ref.getDownloadURL());
          //  _hikaye.resim = (await downloadUrl.ref.getDownloadURL());
          Logger.log(tag, message: 'URL Is ${_hikaye.resim}');
        }
      }

      _hikaye.tarih = Timestamp.now();

      _hikaye.ekleyen = Fonksiyon.uye.uid;

      _hikaye.resim = _resimler;

      _hikaye.onay = true;
      Logger.log(tag, message: _hikaye.resim.toString());

      CollectionReference reference = Fonksiyon.firestore.collection('hikayeler');
      if (_hikaye.id != null) {
        await reference.document(_hikaye.id).updateData(_hikaye.toMap());
      } else {
        _hikaye.id = zaman;
        await reference.document(zaman).setData(_hikaye.toMap());
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

  void _resmiGoster(Widget w) {
    showDialog(
      context: context,
      builder: (ctx) {
        return FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Container(
            width: double.maxFinite,
            child: w,
          ),
        );
      },
    );
  }
/* 
   Future _kayitYap() async {
    _isleniyor = true;
    setState(() {});

    StorageReference storageRef;

    if (_file != null) {
      Logger.log(tag, message: "Dosya: ${_file.path}");
      storageRef = FirebaseStorage.instance.ref().child(
            "hikayeresimleri/${Random().nextInt(10000000).toString()}.jpg",
          );
      File compressedFile;
      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(_file.path);
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

        if (_hikaye.resim != null) resimSil(_hikaye.resim[0]);

        _hikaye.resim = (await downloadUrl.ref.getDownloadURL());
        Logger.log(tag, message: 'URL Is ${_hikaye.resim}');
      }
    }
    _hikaye.tarih = Timestamp.now();
    if (_hikaye.id != null) {
      await _firestore
          .collection('hikayeler')
          .document(_hikaye.id)
          .updateData(_hikaye.toMap());

      mesajGoster(Yazi.grupMesaj, true);
    } else if (_file != null) {
      _hikaye.id = Fonksiyon.uye.uid;
      _hikaye.ekleyen = Fonksiyon.uye.uid;

      _hikaye.onay = true;
      await _firestore.collection('hikayeler').add(_hikaye.toMap());

      mesajGoster('Hikayeniz eklenmiştir...', true);
    } else {
      mesajGoster('Lütfen bir hikaye resmi ekleyiniz!!!', false);
    }

    Logger.log(tag, message: "Kayıt işlemi sonuçlandı");
    _isleniyor = false;
    setState(() {});
  } */

  resimSil(String res) {
    RegExp desen = RegExp("hikayeresimleri%2F(.*?).jpg");
    Match ma = desen.firstMatch(res);

    FirebaseStorage.instance.ref().child('hikayeresimleri/${ma.group(1)}.jpg').delete().whenComplete(() {
      Logger.log(tag, message: "eşleşen: ${ma.group(1)}");
    });
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
                Navigator.pop(context);
                if (sonMu) {
                  Future.delayed(Duration(milliseconds: 10)).whenComplete(() {
                    Navigator.pop(context);
                  });
                }
              },
              child: Text(Yazi.tamam),
            )
          ],
        );
      },
    );
  }

  String bosKontrol(String s) {
    if (s == null || s.length < 1) {
      return Yazi.bosBirakma;
    } else {
      return null;
    }
  }

/* 
  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // _kayitYap();
    } else {
      setState(() {
        _autoValidate = true;
      });
      Fonksiyon.mesajGoster(_scaffoldKey, "Lütfen tüm alanları doldurun");
    }
  } */

  @override
  void initState() {
    if (_bas) {
      _hikaye = widget.gHikaye ?? Hikaye();
      _resimler = _hikaye.resim ?? [];
      _bas = false;
    }
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
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
            ),
            title: Text("Hikaye ${widget.gHikaye == null ? 'Gönder' : 'Düzenle'}"),
            actions: <Widget>[
              _kaydediliyor
                  ? Center(child: CircularProgressIndicator())
                  : IconButton(
                      onPressed: () {
                        Logger.log(tag, message: "Söz Kaydet tıklandı");
                        _hikayeKaydet();
                      },
                      icon: Icon(Icons.check),
                    ),
            ],
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: Container(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    /*   Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        height: Fonksiyon.ekran.width / 3,
                        width: Fonksiyon.ekran.width,
                        padding: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          color: Renk.gGri12,
                          image: DecorationImage(
                            image: _file == null
                                ? CachedNetworkImageProvider(
                                    _hikaye.resim ??
                                        'https://img.icons8.com/carbon-copy/2x/camera.png',
                                  )
                                : FileImage(_file),
                            fit: _hikaye.resim == null
                                ? BoxFit.fitHeight
                                : BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 1.0, color: Renk.gGri19),
                        ),
                        child: FlatButton(
                          onPressed: () {
                            _resimSec();
                          },
                          child:
                              _rYukleniyor ? CircularProgressIndicator() : null,
                        ),
                      ),
                    ), */
                    Container(
                      height: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _resimler.length + _files.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i < _resimler.length) {
                            return Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      border: Border.all(
                                        color: Renk.wpKoyu,
                                        width: 1,
                                      ),
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          "${_resimler[i]}",
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: FlatButton(
                                      onPressed: () {
                                        _resmiGoster(
                                          CachedNetworkImage(
                                            imageUrl: "${_resimler[i]}",
                                            placeholder: (context, url) => CircularProgressIndicator(),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                          ),
                                        );
                                      },
                                      child: null,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  padding: EdgeInsets.all(6.0),
                                  child: Container(
                                    width: 30.0,
                                    height: 30.0,
                                    child: FlatButton(
                                      color: Renk.beyaz,
                                      padding: EdgeInsets.all(0.0),
                                      onPressed: () {
                                        _resimSil(i);
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: Renk.wpKoyu,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else if (i < _resimler.length + _files.length) {
                            return Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      border: Border.all(
                                        color: Renk.wpKoyu,
                                        width: 1,
                                      ),
                                      image: DecorationImage(
                                        image: FileImage(
                                          _files[i - _resimler.length],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: FlatButton(
                                      onPressed: () {
                                        _resmiGoster(
                                          Image.file(
                                            _files[i - _resimler.length],
                                          ),
                                        );
                                      },
                                      child: null,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  padding: EdgeInsets.all(6.0),
                                  child: Container(
                                    width: 30.0,
                                    height: 30.0,
                                    child: FlatButton(
                                      color: Renk.wpKoyu,
                                      padding: EdgeInsets.all(0.0),
                                      onPressed: () {
                                        _resimSil(i);
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: Renk.beyaz,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(15.0),
                                ),
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Renk.wpKoyu, width: 1),
                                    borderRadius: new BorderRadius.circular(15.0),
                                  ),
                                  child: FlatButton(
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(15.0),
                                    ),
                                    onPressed: _resimSec,
                                    color: Color(0xffD3D3D3).withOpacity(0.5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        FontAwesomeIcons.plus,
                                        color: Renk.wpKoyu,
                                        size: 30.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 8.0),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
