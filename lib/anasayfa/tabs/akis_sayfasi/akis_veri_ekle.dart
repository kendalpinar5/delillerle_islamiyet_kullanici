import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delillerleislamiyet/model/akis_veri_model.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AkisVeriEkle extends StatefulWidget {
  final AkisVeri akisVeri;
  final Function yenile;

  const AkisVeriEkle({Key key, this.akisVeri, @required this.yenile}) : super(key: key);
  @override
  _AkisVeriEkleState createState() => _AkisVeriEkleState();
}

class _AkisVeriEkleState extends State<AkisVeriEkle> {
  final String tag = "AkisVeriEkle";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final int maxUzunluk = 44;
  final Firestore _firestore = Firestore.instance;
  AkisVeri _akisVeri;
  File _file;
  bool _bas = true;
  bool _inProcess = false;
  final picker = ImagePicker();
  bool _rYukleniyor = false;
  int _seviyeIndex = 0;

  bool _autoValidate = false;
  bool _isleniyor = false;
  final List<Map<int, String>> _kategoriler = [
    {1: "Akaid/İman"},
    {2: "Tefsir"},
    {3: "Fıkıh"},
    {4: "Hadis"},
    {5: "Tecvid/Talim"},
    {6: "Tasavvuf"},
    {7: "Reddiyeler"},
    {8: "Genel"},
  ];
  _resimSec(ImageSource source) async {
    Logger.log(tag, message: 'geldi');
    setState(() {
      _inProcess = true;
    });
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Delillerle İslamiyet',
              toolbarColor: Renk.wp,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      if (croppedFile != null)
        setState(() {
          _file = croppedFile;

          _inProcess = false;
        });
      else
        setState(() {
          _inProcess = false;
        });
    } else {
      setState(() {
        _inProcess = false;
      });
    }
  }

  void _cameraGalery() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Renk.wp,
                  child: IconButton(
                    icon: Icon(
                      FontAwesomeIcons.images,
                      color: Renk.beyaz,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _resimSec(ImageSource.gallery);
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  color: Renk.wpAcik,
                  child: IconButton(
                    icon: Icon(
                      FontAwesomeIcons.camera,
                      color: Renk.beyaz,
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      _resimSec(ImageSource.camera);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future _kayitYap() async {
    _isleniyor = true;
    setState(() {});
    _akisVeri.tarih = Timestamp.now();
    StorageReference storageRef;

    if (_file != null) {
      Logger.log(tag, message: "Dosya: ${_file.path}");
      storageRef = FirebaseStorage.instance.ref().child(
            "akisresimleri/${Random().nextInt(10000000).toString()}.jpg",
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
        Logger.log(tag, message: _akisVeri.resim);
        if (_akisVeri.resim != '') resimSil(_akisVeri.resim);

        _akisVeri.resim = (await downloadUrl.ref.getDownloadURL());
        Logger.log(tag, message: 'URL Is ${_akisVeri.resim}');
      }
    }

    if (_akisVeri.id != null) {
      await _firestore.collection('akis_verileri').document(_akisVeri.id).updateData(_akisVeri.toMap());
      mesajGoster('Gönderim başarılı', true);
    } else if (_file != null) {
      final String fileName = Random().nextInt(10000000).toString();
      _akisVeri.id = fileName;
      _akisVeri.ekleyen = Fonksiyon.uye.uid;

      _akisVeri.onay = true;

      await _firestore.collection('akis_verileri').document(fileName).setData(_akisVeri.toMap());
      await _firestore.collection('uyeler').document(Fonksiyon.uye.uid).get().then((value) {
        int gS = value.data['gonderiSayisi'];
        gS = gS + 1;

        _firestore.collection('uyeler').document(Fonksiyon.uye.uid).updateData({'gonderiSayisi': gS});
        Fonksiyon.uye.gonderiSayisi = gS;
      });

      mesajGoster('Gönderim başarılı', true);
    } else {
      final String fileName = Random().nextInt(10000000).toString();
      _akisVeri.id = fileName;
      _akisVeri.ekleyen = Fonksiyon.uye.uid;
      _akisVeri.resim = '';
      _akisVeri.onay = true;

      await _firestore.collection('akis_verileri').document(fileName).setData(_akisVeri.toMap());
      await _firestore.collection('uyeler').document(Fonksiyon.uye.uid).get().then((value) {
        int gS = value.data['gonderiSayisi'] ?? 0;
        gS = gS + 1;

        _firestore.collection('uyeler').document(Fonksiyon.uye.uid).updateData({'gonderiSayisi': gS});
        Fonksiyon.uye.gonderiSayisi = gS;
      });
      Logger.log(tag, message: Fonksiyon.uye.gonderiSayisi.toString());
      mesajGoster('Gönderim başarılı', true);
    }

    Logger.log(tag, message: "Kayıt işlemi sonuçlandı");
    _isleniyor = false;
    setState(() {});
  }

  resimSil(String res) {
    RegExp desen = RegExp("akisresimleri%2F(.*?).jpg");
    Match ma = desen.firstMatch(res);

    FirebaseStorage.instance.ref().child('akisresimleri/${ma.group(1)}.jpg').delete().whenComplete(() {
      Logger.log(tag, message: "eşleşen: ${ma.group(1)}");
    });
  }

  Future mesajGoster(String mesaj, bool sonMu) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Gönderi Durumu'),
          content: Text(mesaj),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                if (widget.yenile != null) widget.yenile();

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

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _kayitYap();
    } else {
      setState(() {
        _autoValidate = true;
      });
      Fonksiyon.mesajGoster(_scaffoldKey, "Lütfen tüm alanları doldurun");
    }
  }

  @override
  void initState() {
    if (_bas) {
      _akisVeri = widget.akisVeri ?? AkisVeri();
      if (_akisVeri.id == null) {
        _seviyeIndex = 7;
        _akisVeri.kategori = '8';

        _akisVeri.resim = '';
      }

      _bas = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Renk.beyaz,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, color: Renk.wpKoyu),
            ),
            title: Text("Ne düşünüyorsun?", style: TextStyle(color: Renk.wpKoyu)),
            actions: <Widget>[
              _isleniyor
                  ? Center(child: CircularProgressIndicator())
                  : IconButton(
                      onPressed: () {
                        Logger.log(tag, message: "Söz Kaydet tıklandı");
                        _validateInputs();
                      },
                      icon: Icon(Icons.check, color: Renk.wpKoyu),
                    ),
            ],
          ),
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: Container(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            height: 210.0,
                            width: Fonksiyon.ekran.width,
                            padding: EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              color: Renk.gGri12,
                              image: DecorationImage(
                                image: _file == null
                                    ? CachedNetworkImageProvider(
                                        _akisVeri.resim == ''
                                            ? 'https://img.icons8.com/carbon-copy/2x/camera.png'
                                            : _akisVeri.resim,
                                      )
                                    : FileImage(_file),
                                fit: _akisVeri.resim == '' ? BoxFit.contain : BoxFit.contain,
                              ),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(width: 1.0, color: Renk.gGri19),
                            ),
                            child: FlatButton(
                              onPressed: () {
                                _cameraGalery();
                              },
                              child: _rYukleniyor ? CircularProgressIndicator() : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Başlık',
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
                            hintText: 'yaz...',
                          ),
                          keyboardType: TextInputType.text,
                          onSaved: (deg) {
                            _akisVeri.baslik = deg;
                          },
                          initialValue: _akisVeri.baslik,
                          validator: bosKontrol,
                        ),
                        SizedBox(height: 8.0),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Ne düşünüyorsun?',
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
                            hintText: "yaz...",
                          ),
                          keyboardType: TextInputType.text,
                          onSaved: (deg) {
                            _akisVeri.aciklama = deg;
                          },
                          initialValue: _akisVeri.aciklama,
                          maxLines: 8,
                          validator: bosKontrol,
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Yazı Kategori: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: Fonksiyon.ekran.width / 24,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                            Expanded(
                              child: DropdownButton(
                                isExpanded: true,
                                value: _akisVeri.id != null
                                    ? _kategoriler[int.parse(_akisVeri.kategori) - 1]
                                    : _kategoriler[_seviyeIndex],
                                items: [
                                  for (Map m in _kategoriler)
                                    DropdownMenuItem(
                                      child: Container(
                                          width: double.maxFinite,
                                          color: _kategoriler[int.parse(_akisVeri.kategori) - 1] == m
                                              ? Renk.gGri12
                                              : Renk.beyaz,
                                          child: Text(m.values.first)),
                                      value: m,
                                    ),
                                ],
                                onChanged: (Map v) {
                                  _seviyeIndex = _kategoriler.indexOf(v);
                                  _akisVeri.kategori = _kategoriler[_seviyeIndex].keys.first.toString();

                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0),
                        /*  Container(
                          width: double.maxFinite,
                          child: RaisedButton(
                            onPressed: () {
                             
                              _validateInputs();
                            },
                            color: Renk.wpKoyu,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _isleniyor
                                  ? CircularProgressIndicator()
                                  : Text(
                                      Yazi.gTalebiGonder,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: Fonksiyon.ekran.width / 20,
                                        color: Renk.beyaz,
                                      ),
                                    ),
                            ),
                          ),
                        ), */
                      ],
                    ),
                  ),
                ),
              ),
              _inProcess
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.98,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Center()
            ],
          ),
        ),
      ),
    );
  }
}
