import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delillerleislamiyet/model/konu.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';


class ForumKonuEkle extends StatefulWidget {
  final Konu konu;

  const ForumKonuEkle({Key key, this.konu}) : super(key: key);
  @override
  _ForumKonuEkleState createState() => _ForumKonuEkleState();
}

class _ForumKonuEkleState extends State<ForumKonuEkle> {
  final String tag = "ForumKonuEkle";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File _file;
  Konu _konu;

  bool _rYukleniyor = false;
  bool _autoValidate = false;
  bool _isleniyor = false;

  Future _resimSec() async {
    _rYukleniyor = true;
    setState(() {});

    _file = await FilePicker.getFile(type: FileType.image);

    _rYukleniyor = false;
    setState(() {});
  }

  Future _kayitYap() async {
    _isleniyor = true;
    setState(() {});

    StorageReference storageRef;
    Logger.log(tag, message: "{adresKntr()}");

    if (_file != null) {
      Logger.log(tag, message: "Dosya: ${_file.path}");
      storageRef = FirebaseStorage.instance.ref().child(
            "forumresimleri/${Random().nextInt(10000000).toString()}.jpg",
          );
      File compressedFile;
      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(_file.path);
      compressedFile = await FlutterNativeImage.compressImage(
        _file.path,
        quality: 80,
        targetWidth: 300,
        targetHeight: 300 * (properties.height / properties.width).round(),
      );
      Logger.log(
        tag,
        message:
            "resim ölçüleri: ${properties.height * 300 / properties.width}",
      );
      if (storageRef != null) {
        final StorageUploadTask uploadTask = storageRef.putFile(
          compressedFile,
          StorageMetadata(contentType: "image/jpg"),
        );
        final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);

        if (_konu.resim != Konu().resim) resimSil(_konu.resim);

        _konu.resim = (await downloadUrl.ref.getDownloadURL());

        Logger.log(tag, message: 'URL Is ${_konu.resim}');
      }
    }

    if (_konu.id != null) {
      await Firestore.instance
          .collection('forum')
          .document(_konu.id)
          .updateData(_konu.toMap());
    } else {
      final String fileName = Timestamp.now().millisecondsSinceEpoch.toString();
      _konu.id = fileName;
      await Firestore.instance
          .collection('forum')
          .document(fileName)
          .setData(_konu.toMap());
    }
    Fonksiyon.mesajGoster(_scaffoldKey, Yazi.islemTamamlandi);
    await Future.delayed(Duration(milliseconds: 1500));
    _isleniyor = false;
    setState(() {});
    Navigator.pop(context);
  }

  resimSil(String res) {
    RegExp desen = RegExp("forumresimleri%2F(.*?).jpg");
    Match ma = desen.firstMatch(res);

    FirebaseStorage.instance
        .ref()
        .child('forumresimleri/${ma.group(1)}.jpg')
        .delete()
        .whenComplete(() {
      Logger.log(tag, message: "eşleşen: ${ma.group(1)}");
    });
  }

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _kayitYap();
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  @override
  void initState() {
    _konu = widget.konu ?? Konu();
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
            title: Text("Konu ${widget.konu == null ? 'Ekle' : 'Düzenle'}"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                autovalidate: _autoValidate,
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Konu İkonu",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: Fonksiyon.ekran.width / 20,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        height: Fonksiyon.ekran.width / 3,
                        width: Fonksiyon.ekran.width / 3,
                        padding: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          color: Renk.gGri12,
                          image: DecorationImage(
                            image: _file == null
                                ? CachedNetworkImageProvider(_konu.resim??Linkler.thumbResim)
                                : FileImage(_file),
                            fit: BoxFit.cover,
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
                    ),
                    SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Başlık",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: Fonksiyon.ekran.width / 20,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                        ),
                        fillColor: Renk.beyaz,
                        filled: true,
                        contentPadding: const EdgeInsets.all(12.0),
                        hintText: "Konu başlığınızı yazın",
                      ),
                      keyboardType: TextInputType.text,
                      onSaved: (deg) {
                        _konu.baslik = deg;
                      },
                      initialValue: _konu.baslik,
                      validator: Fonksiyon.bosKontrol,
                    ),
                    SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Kısa Açıklama",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: Fonksiyon.ekran.width / 20,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                        ),
                        fillColor: Renk.beyaz,
                        filled: true,
                        contentPadding: const EdgeInsets.all(12.0),
                        hintText: "Konu için kısa bir açıklama yazın",
                      ),
                      keyboardType: TextInputType.text,
                      onSaved: (deg) {
                        _konu.kisaaciklama = deg;
                      },
                      initialValue: _konu.kisaaciklama,
                      validator: Fonksiyon.bosKontrol,
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      width: double.maxFinite,
                      color: Renk.wpKoyu,
                      child: _isleniyor
                          ? Center(child: CircularProgressIndicator())
                          : RaisedButton(
                              onPressed: () {
                                Logger.log(tag, message: "Tamamla tıklandı");
                                _validateInputs();
                              },
                              color: Renk.wpKoyu,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Tamamla",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: Fonksiyon.ekran.width / 20,
                                    color: Renk.beyaz,
                                  ),
                                ),
                              ),
                            ),
                    ),
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
