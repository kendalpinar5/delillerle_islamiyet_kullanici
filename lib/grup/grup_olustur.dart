import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/iller.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';

class GrupOlustur extends StatefulWidget {
  final Grup grup;

  const GrupOlustur({Key key, this.grup}) : super(key: key);
  @override
  _GrupOlusturState createState() => _GrupOlusturState();
}

class _GrupOlusturState extends State<GrupOlustur> {
  final String tag = "GrupOlustur";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final int maxUzunluk = 44;
  final Firestore _firestore = Firestore.instance;
  final List<Map<int, String>> _seviyeler = [
    {0: "Genel Seviye"},
    {11: "İl Moderatör Grubu"},
    {21: "Bölge Moderatör Grubu"},
    {31: "Türkiye Moderatör Grubu"},
    {41: "Türkiye Temsilci Grubu"},
  ];

  Grup _grup;
  File _file;

  bool _rYukleniyor = false;
  bool _autoValidate = false;
  bool _isleniyor = false;
  bool _bas = true;
  int _seviyeIndex = 0;

  Future _resimSec() async {
    _rYukleniyor = true;
    setState(() {});

    await FilePicker.getFile(type: FileType.image).then((onValue) {
      if (onValue != null) {
        Logger.log(tag, message: onValue.path);
        _file = onValue;
        setState(() {});
      }
    });

    _rYukleniyor = false;
    setState(() {});
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

  Future _kayitYap() async {
    _isleniyor = true;
    setState(() {});

    StorageReference storageRef;
    if (_file != null) {
      Logger.log(tag, message: "Dosya: ${_file.path}");
      storageRef = FirebaseStorage.instance.ref().child(
            "grupresimleri/${Random().nextInt(10000000).toString()}.jpg",
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

        if (_grup.resim != null) resimSil(_grup.resim);

        _grup.resim = (await downloadUrl.ref.getDownloadURL());
        Logger.log(tag, message: 'URL Is ${_grup.resim}');
      }
    }

    if (_grup.anahtarkelimeler.length > 0) {
      _grup.oTarih = FieldValue.serverTimestamp();
      if (_grup.id != null) {
        await _firestore
            .collection('gruplar')
            .document(_grup.id)
            .updateData(_grup.toMap());
        mesajGoster(Yazi.grupMesaj, true);
      } else if (_file != null) {
        final String fileName = Random().nextInt(10000000).toString();
        _grup.id = fileName;
        _grup.olusturan = Fonksiyon.uye.uid;
        _grup.katilimcisayisi = "0";
        _grup.yOnay = false;
        await _firestore
            .collection('gruplar')
            .document(fileName)
            .setData(_grup.toMap());
        mesajGoster(Yazi.grupMesaj, true);
      } else {
        mesajGoster(Yazi.kapakResmiSec, false);
      }
    } else {
      mesajGoster("Lütfen en az bir anahtar kelime seçin", false);
    }

    Logger.log(tag, message: "Kayıt işlemi sonuçlandı");
    _isleniyor = false;
    setState(() {});
  }

  resimSil(String res) {
    RegExp desen = RegExp("grupresimleri%2F(.*?).jpg");
    Match ma = desen.firstMatch(res);

    FirebaseStorage.instance
        .ref()
        .child('grupresimleri/${ma.group(1)}.jpg')
        .delete()
        .whenComplete(() {
      Logger.log(tag, message: "eşleşen: ${ma.group(1)}");
    });
  }

  Future mesajGoster(String mesaj, bool sonMu) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(Yazi.islemSonuc),
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

  secim(List s) {
    _grup.anahtarkelimeler = s.reversed.join(', ');
    setState(() {});
  }

  _ilFiltrele() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        String secilenIl = "Türkiye";
        return Container(
          child: StatefulBuilder(
            builder: (c, s) {
              return Container(
                height: 40.0,
                child: AlertDialog(
                  title: Text("İl Seçimi Yap"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        for (String ils in IlUlke.ilUlke)
                          ListTile(
                            onTap: () {
                              secilenIl = ils;
                              s(() {});
                            },
                            title: Text(ils),
                            trailing: secilenIl == ils
                                ? Icon(Icons.check)
                                : SizedBox(),
                          ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("İptal"),
                    ),
                    FlatButton(
                      onPressed: () {
                        _grup.il = secilenIl;
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Text("Tamam"),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    if (_bas) {
      _grup = widget.grup ?? Grup();
      if (_grup.baslik == null) {
        _grup.kurallar = ["Kural"];
      }
      _seviyeIndex = _seviyeler.indexWhere((m) => m.keys.first == _grup.seviye);
      _grup.seviye = _seviyeler[_seviyeIndex].keys.first;
      _bas = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(Yazi.grupOlustur.substring(0, Yazi.grupOlustur.length - 2)),
      ),
      body: SingleChildScrollView(
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
                    height: Fonksiyon.ekran.width / 3,
                    width: Fonksiyon.ekran.width,
                    padding: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      color: Renk.gGri12,
                      image: DecorationImage(
                        image: _file == null
                            ? CachedNetworkImageProvider(
                                _grup.resim ?? Linkler.giPicker,
                              )
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
                      Yazi.grupAdi,
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
                    hintText: Yazi.ornekBulusma,
                  ),
                  keyboardType: TextInputType.text,
                  onSaved: (deg) {
                    _grup.baslik = deg;
                  },
                  initialValue: _grup.baslik,
                  validator: bosKontrol,
                ),
                SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      Yazi.kisaAciklama,
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
                    hintText: Yazi.ornekGorsel,
                  ),
                  keyboardType: TextInputType.text,
                  onSaved: (deg) {
                    _grup.kisaaciklama = deg;
                  },
                  initialValue: _grup.kisaaciklama,
                  validator: bosKontrol,
                ),
                SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      Yazi.il,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Fonksiyon.ekran.width / 20,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                OutlineButton(
                  onPressed: _ilFiltrele,
                  child: Center(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _grup.il ?? 'İl Seçimi Yapın',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
                Text(
                  "Önemli: Grubu belli bir il için oluşturmayacaksanız lütfen il seçimi yapmayın. İl seçmemeniz halinde grubunuz genel kategoride olacaktır.",
                ),
                SizedBox(height: 8.0),
                if (Fonksiyon.admin())
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Grup Seviyesi: ",
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
                          value: _seviyeler[_seviyeIndex],
                          items: [
                            for (Map m in _seviyeler)
                              DropdownMenuItem(
                                child: Text(m.values.first),
                                value: m,
                              ),
                          ],
                          onChanged: (Map v) {
                            _seviyeIndex = _seviyeler.indexOf(v);
                            _grup.seviye = _seviyeler[_seviyeIndex].keys.first;
                            Logger.log(
                              tag,
                              message:
                                  "${v.toString()} ${_grup.seviye} ${v.keys.first}",
                            );
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      Yazi.anahtarKelimeler,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Fonksiyon.ekran.width / 20,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/alan_sec',
                    arguments: {
                      'Fnks': secim,
                      'secilenler': _grup.anahtarkelimeler?.split(',') ?? [],
                    },
                  ),
                  child: TextField(
                    controller:
                        TextEditingController(text: _grup.anahtarkelimeler),
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
                      hintText: Yazi.ornekEgitimMedya,
                    ),
                    enabled: false,
                  ),
                ),
                SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Katılımcı Kontenjanı",
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
                    hintText: "10",
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (deg) {
                    _grup.maxkatilimci = deg;
                  },
                  initialValue: _grup.maxkatilimci,
                  validator: bosKontrol,
                ),
                SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Grup Kuralları",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Fonksiyon.ekran.width / 20,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    for (int i = 0; i < _grup.kurallar.length; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(
                                    text: _grup.kurallar[i]),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFEAEBEC)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFEAEBEC)),
                                  ),
                                  fillColor: Renk.beyaz,
                                  filled: true,
                                  contentPadding: const EdgeInsets.all(12.0),
                                ),
                                onChanged: (deg) {
                                  _grup.kurallar[i] = deg;
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (i + 1 == _grup.kurallar.length)
                                  _grup.kurallar.add("Kural");
                                else
                                  _grup.kurallar.removeAt(i);
                                Logger.log(tag, message: "${_grup.kurallar}");
                                setState(() {});
                              },
                              icon: Icon(
                                i + 1 == _grup.kurallar.length
                                    ? Icons.add
                                    : Icons.remove,
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
                SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      Yazi.grubuAnlat,
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
                    hintText: "Ör: ${Yazi.grubuAnlat}",
                  ),
                  keyboardType: TextInputType.text,
                  onSaved: (deg) {
                    _grup.aciklama = deg;
                  },
                  initialValue: _grup.aciklama,
                  maxLines: 8,
                  validator: bosKontrol,
                ),
                SizedBox(height: 20.0),
                Container(
                  width: double.maxFinite,
                  child: RaisedButton(
                    onPressed: () {
                      Logger.log(
                        tag,
                        message: "Grup talebi gönder tıklandı",
                      );
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
