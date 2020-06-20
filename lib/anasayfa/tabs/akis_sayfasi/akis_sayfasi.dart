import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:delillerleislamiyet/anasayfa/hikayeler/hikayeler.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/akis_veri_ekle.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/widgets/akis_veri_widget.dart';
import 'package:delillerleislamiyet/gunun_sozu/soz.dart';
import 'package:delillerleislamiyet/gunun_sozu/soz_widget.dart';
import 'package:delillerleislamiyet/model/akis_veri_model.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class AkisSayfasi extends StatefulWidget {
  const AkisSayfasi({Key key}) : super(key: key);
  @override
  _AkisSayfasiState createState() => _AkisSayfasiState();
}

class _AkisSayfasiState extends State<AkisSayfasi> {
  final String tag = "AkisSayfasi";

  final Firestore _db = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  List _hikayeler = [];
  List _sozler = [];

  List _akisVeri = [];
  DocumentSnapshot sonDoc;
  Box _kutu = Hive.box('anasayfa');

  bool _islem = false;

  double _sY = 0;
  double _sO = 0;

  Future sozleriGetir() async {
    _sozler = [];
    QuerySnapshot qs = await _db
        .collection('gunun_sozleri')
        .where('onay', isEqualTo: true)
        .orderBy('tarih', descending: true)
        .limit(1)
        .getDocuments();

    for (DocumentSnapshot ds in qs.documents) {
      _sozler.add(ds.data.map((key, value) =>
          key == 'tarih' ? MapEntry(key, (value as Timestamp).millisecondsSinceEpoch) : MapEntry(key, value)));
    }

    _kutu.put('gunun_sozu', _sozler);
    setState(() {});
  }

  Future _hikayeGetir() async {
    QuerySnapshot qs;
    if (Fonksiyon.uye.arkadaslar != null) if (sonDoc == null) {
      qs = await _db
          .collection('hikayeler')
          .where('onay', isEqualTo: true)
          .where('ekleyen', whereIn: Fonksiyon.uye.arkadaslar ?? '')
          .orderBy('tarih', descending: true)
          .limit(5)
          .getDocuments();
    } else {
      qs = await _db
          .collection('hikayeler')
          .where('onay', isEqualTo: true)
          .where('ekleyen', whereIn: Fonksiyon.uye.arkadaslar ?? '')
          .orderBy('tarih', descending: true)
          .startAfterDocument(sonDoc)
          .limit(5)
          .getDocuments();
    }

    Logger.log('gelen hikaye sayisi', message: qs.documents.length.toString());
    if (qs.documents.isNotEmpty) sonDoc = qs.documents.last;

    for (DocumentSnapshot ds in qs.documents) {
      if (ds.exists)
        _hikayeler.add(ds.data.map((key, value) =>
            key == 'tarih' ? MapEntry(key, (value as Timestamp).millisecondsSinceEpoch) : MapEntry(key, value)));
    }

    QuerySnapshot benQs = await _db
        .collection('hikayeler')
        .where('onay', isEqualTo: true)
        .where('ekleyen', isEqualTo: Fonksiyon.uye.uid)
        .getDocuments();

    for (DocumentSnapshot benDs in benQs.documents) {
      if (benDs.exists) {
        _hikayeler.add(benDs.data.map((key, value) =>
            key == 'tarih' ? MapEntry(key, (value as Timestamp).millisecondsSinceEpoch) : MapEntry(key, value)));
      }
    }

    _kutu.put('hikayeler', _hikayeler);
    setState(() {});
  }

  Future _makaleGetir() async {
    setState(() => _islem = true);
    QuerySnapshot qs;
    if (sonDoc == null) {
      qs = await _db
          .collection('akis_verileri')
          .where('onay', isEqualTo: true)
          .orderBy('tarih', descending: true)
          .limit(10)
          .getDocuments();
    } else {
      qs = await _db
          .collection('akis_verileri')
          .where('onay', isEqualTo: true)
          .orderBy('tarih', descending: true)
          .startAfterDocument(sonDoc)
          .limit(10)
          .getDocuments();
    }

    if (qs.documents.isNotEmpty) sonDoc = qs.documents.last;
    for (DocumentSnapshot ds in qs.documents) {
      _akisVeri.add(ds.data.map((key, value) =>
          key == 'tarih' ? MapEntry(key, (value as Timestamp).millisecondsSinceEpoch) : MapEntry(key, value)));
    }

    _kutu.put('akisVerileri', _akisVeri);

    Logger.log('fonksiyon', message: _kutu.get('akisVerileri', defaultValue: []).toString());

    setState(() => _islem = false);
  }

  yenile() {
    _akisVeri = [];
    sonDoc = null;
    _kutu.put('akisVerileri', null);
    _makaleGetir();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _hikayeGetir();
    sozleriGetir();

    _makaleGetir();
    _scrollController.addListener(() {
      _sO = _scrollController.offset;
      _sY = _scrollController.position.maxScrollExtent;

      if (_sO + 220 > _sY && !_islem) _makaleGetir();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Renk.gGri12,
      body: RefreshIndicator(
        backgroundColor: Renk.wpAcik,
        color: Renk.beyaz,
        onRefresh: () async {
          _hikayeGetir();
          sozleriGetir();

          _makaleGetir();
          Logger.log(tag, message: 'yenıledi');
        },
        child: _kutu.get('akisVerileri') == null
            ? CardListSkeleton(
                style: SkeletonStyle(
                    theme: SkeletonTheme.Light,
                    isShowAvatar: true,
                    isCircleAvatar: true,
                    barCount: 3,
                    borderRadius: BorderRadius.circular(10)),
              )
            : SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ValueListenableBuilder(
                        valueListenable: _kutu.listenable(keys: ['hikayeler']),
                        builder: (context, box, widget) {
                          List _hikler = box.get('hikayeler', defaultValue: []);

                          return Hikayeler(
                            gHikaye: _hikler,
                            hikayeGetir: _hikayeGetir,
                          );
                        }),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AkisVeriEkle(
                                      yenile: yenile,
                                    )));
                      },
                      child: Container(
                        height: 60,
                        width: double.maxFinite,
                        color: Renk.beyaz,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 40,
                              width: 40,
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Renk.siyah, width: 0.5),
                                  borderRadius: BorderRadius.circular(50),
                                  image: DecorationImage(image: NetworkImage(Fonksiyon.uye.resim), fit: BoxFit.cover)),
                            ),
                            Expanded(
                              child: Container(
                                  height: 35,
                                  width: double.maxFinite,
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(right: 10),
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: Renk.gGri, width: 0.5),
                                  ),
                                  child: Text('Yazı paylaş...', style: TextStyle(color: Renk.siyah))),
                            ),
                          ],
                        ),
                      ),
                    ),

                    ValueListenableBuilder(
                        valueListenable: _kutu.listenable(keys: ['gunun_sozu']),
                        builder: (context, box, widget) {
                          List _soz = box.get('gunun_sozu', defaultValue: []);
                          return Column(
                            children: <Widget>[
                              for (int i = 0; i < _soz.length; i++)
                                SozWidget(
                                    soz: Soz.fromJson(_soz[i]
                                        .map((k, v) => k == 'tarih'
                                            ? MapEntry(k, Timestamp.fromMillisecondsSinceEpoch(v))
                                            : MapEntry(k, v))
                                        .cast<String, dynamic>()),
                                    scaffoldKey: _scaffoldKey)
                            ],
                          );
                        }),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ValueListenableBuilder(
                            valueListenable: _kutu.listenable(keys: ['akisVerileri']),
                            builder: (context, box, widget) {
                              List _akisVeri = box.get('akisVerileri', defaultValue: []);
                              return Column(
                                children: <Widget>[
                                  for (int i = 0; i < _akisVeri.length; i++)
                                    AkisVeriWidget(
                                      yenile: yenile,
                                      veri: AkisVeri.fromMap(_akisVeri[i]
                                          .map((k, v) => k == 'tarih'
                                              ? MapEntry(k, Timestamp.fromMillisecondsSinceEpoch(v))
                                              : MapEntry(k, v))
                                          .cast<String, dynamic>()),
                                      scaffoldKey: _scaffoldKey,
                                    ),
                                ],
                              );
                            })
                      ],
                    ),

                    _islem
                        ? Center(
                            child: CircularProgressIndicator(backgroundColor: Renk.beyaz),
                          )
                        : SizedBox(
                            height: 200,
                          )
                    //  SaglikMutluluk(),
                    //   SizedBox(height: 3400, child: YouTubeMain(de: true)),
                  ],
                ),
              ),
      ),
    );
  }
}
