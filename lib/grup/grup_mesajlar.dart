import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delillerleislamiyet/grup/grup_anket_ekle.dart';
import 'package:delillerleislamiyet/grup/grup_mesaj_widget.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/mesaj.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/yeni_grup/mesaj_yaz_widget.dart';


class GrupMesajlar extends StatefulWidget {
  @override
  _GrupMesajlarState createState() => _GrupMesajlarState();
}

class _GrupMesajlarState extends State<GrupMesajlar> {
  final String tag = "GrupMesajlar";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();
  Grup _grup;
  Uye uye = Fonksiyon.uye;
  Firestore _firestore = Firestore.instance;

  Size _ekran;


  bool _bas = true;
  bool _bildirimAl = true;
  bool _islem = false;
  bool _rYukleniyor = false;
  bool _gittim = false;

  File _file;
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
                        //_mesajGonder('resim');
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

  void _resmiGor(Mesaj msj) {
    DateTime time = msj.tarih.toDate();

    String saat = time.hour.toString();
    String dakika = time.minute.toString();
    bool ben = msj.yazan == uye.uid;

    Widget resim = CachedNetworkImage(
      imageUrl: msj.resim,
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
                  ben ? "Siz" : msj.gonderen,
                  style: TextStyle(color: Renk.beyaz),
                ),
                Text(
                  "${saat.length > 1 ? saat : '0' + saat}:${dakika.length > 1 ? dakika : '0' + dakika}",
                  style: TextStyle(color: Renk.beyaz, fontSize: 14.0),
                ),
              ],
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(child: Center(child: resim)),
              SizedBox(height: 50.0),
            ],
          ),
        );
      },
    );
  }

  Future basla() async {
    final Map args = ModalRoute.of(context).settings.arguments;
    _ekran = MediaQuery.of(context).size;

    if (args['grupid'] != null) {
      DocumentSnapshot ds =
          await _firestore.collection('gruplar').document(args['grupid']).get();
      _grup = Grup.fromMap(ds.data, ds.documentID);
    } else {
      _grup = args['grup'];
    }
    
   // _bildirimAl = Fonksiyon.kayitAraci.getBool("grup_${_grup.id}") ?? true;

    _bas = false;
    if (!_gittim) setState(() {});
  }

  _scrollToBottom() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void didChangeDependencies() {
    if (_bas) basla();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _gittim = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: Renk.gGri12,
          appBar: AppBar(
            title: Text("Mesajlar"),
            actions: <Widget>[
              IconButton(
                onPressed: () async {
                  if (!_islem) {
                    _islem = true;
                    if (_bildirimAl) {
                      await Fonksiyon.konuAboneCik("grup_${_grup.id}");
                      _bildirimAl = false;
                    } else {
                      await Fonksiyon.konuyaAboneOl("grup_${_grup.id}");
                      _bildirimAl = true;
                    }
                    _islem = false;
                    if (!_gittim) setState(() {});
                  }
                },
                icon: Icon(
                  _bildirimAl
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                ),
              ),
              _rYukleniyor
                  ? Center(child: CircularProgressIndicator())
                  : IconButton(
                      onPressed: _resimSec,
                      icon: Icon(Icons.add_a_photo),
                    ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) {
                    return GrupAnketEkle(grup: _grup);
                  }));
                },
                icon: Icon(Icons.insert_chart),
              ),
            ],
          ),
          body: _bas
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: StreamBuilder(
                        stream: _firestore
                            .collection('grup_mesajlar')
                            .where('grupid', isEqualTo: _grup.id)
                            .orderBy('tarih', descending: true)
                            .limit(220)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text('Hiç Mesaj Yok');
                          } else {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: ListView.builder(
                                reverse: true,
                                controller: _scrollController,
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (ctx, i) {
                                  DocumentSnapshot ds =
                                      snapshot.data.documents[i];
                                  Mesaj msj =
                                      Mesaj.fromMap(ds.data, ds.documentID);
                                  return GrupMesajWidget(
                                    ekran: _ekran,
                                    resmiGor: _resmiGor,
                                    msj: msj,
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    MesajYazWidget(
                      grupID: _grup.id,
                      scrollToBottom: _scrollToBottom,
                    ),
                  ],
                ),
        ),
        if (_islem)
          Positioned.fill(
            child: Container(
              color: Color(0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
