import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delillerleislamiyet/forum/soru_syf.dart';
import 'package:delillerleislamiyet/forum/soru_widget.dart';
import 'package:delillerleislamiyet/model/konu.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/model/soru.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class KonuSyf extends StatefulWidget {
  final Konu konu;

  KonuSyf({Key key, @required this.konu}) : super(key: key);
  @override
  _KonuSyfState createState() => _KonuSyfState();
}

class _KonuSyfState extends State<KonuSyf> {
  final String tag = "KonuSyf";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Firestore _db = Firestore.instance;
  final Uye _uye = Fonksiyon.uye;
  Konu _konu;
  List<Soru> _sorular;

  List<Map> _kriterler = [
    {'deger': "begenme", 'kriter': "Beğenme Sayısı", 'yon': true},
    {'deger': "tarih", 'kriter': "Tarih", 'yon': true},
    {'deger': "cevapsayisi", 'kriter': "Cevap Sayısı", 'yon': true},
  ];

  String _aramaKriteri = "tarih";

  bool _aramaYonu = true;
  bool _gittim = false;

  Future _sorulariAl() async {
    _sorular = [];
    if (!_gittim) setState(() {});
    QuerySnapshot querySnapshot;
    try {
      querySnapshot = await _db
          .collection('forum')
          .document(_konu.id)
          .collection('sorular')
          .orderBy(_aramaKriteri, descending: _aramaYonu)
          .getDocuments();

      if (_konu.sorusayisi != querySnapshot.documents.length) {
        _konu.sorusayisi = querySnapshot.documents.length;
        await soruEsitle();
      }
      _sorular = querySnapshot.documents.map((f) => Soru.fromMap(f.data)).toList();
      if (!_gittim) setState(() {});
      return querySnapshot.documents;
    } on PlatformException catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    }
  }

  Future<Map> kullanici(String id) async {
    DocumentSnapshot doc;
    try {
      doc = await _db.collection('uyeler').document(id).get();
      return doc.data;
    } on PlatformException catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    }

    return null;
  }

  void _ekle() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        Soru soru = Soru();
        bool hata = false;
        return StatefulBuilder(
          builder: (ctx, setstate) {
            return AlertDialog(
              title: Text("Yeni Soru Ekle"),
              content: Container(
                width: double.maxFinite,
                child: Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(labelText: "Başlık"),
                      onChanged: (v) {
                        soru.baslik = v;
                        if (soru.baslik.length <= 5)
                          hata = true;
                        else
                          hata = false;
                        if (!_gittim) setstate(() {});
                      },
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 140.0),
                      child: IntrinsicHeight(
                        child: TextField(
                          decoration: InputDecoration(labelText: "Soru"),
                          onChanged: (v) {
                            soru.aciklama = v;
                            if (soru.aciklama.length <= 5)
                              hata = true;
                            else
                              hata = false;
                            if (!_gittim) setstate(() {});
                          },
                          expands: true,
                          minLines: null,
                          maxLines: null,
                        ),
                      ),
                    ),
                    hata ? Text("Lütfen en az 5 karakter girin!") : Container(),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    if (soru.baslik != null && soru.aciklama != null) {
                      if (soru.baslik.length > 5 && soru.aciklama.length > 5) {
                        String id = Timestamp.now().millisecondsSinceEpoch.toString();
                        soru.ekleyen = _uye.uid;
                        soru.konuId = _konu.id;
                        soru.tarih = Timestamp.now();
                        soru.id = id;

                        _db
                            .collection('forum')
                            .document(_konu.id)
                            .collection('sorular')
                            .document(id)
                            .setData(soru.toMap());
                        _konu.sorusayisi += 1;

                        _db.collection('forum').document(_konu.id).updateData(
                          {'sorusayisi': FieldValue.increment(1)},
                        );

                        Navigator.pop(context);
                        _sorulariAl();
                      } else {
                        hata = true;
                        if (!_gittim) setstate(() {});
                      }
                    } else {
                      hata = true;
                      if (!_gittim) setstate(() {});
                    }
                  },
                  child: Text("Ekle"),
                ),
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("İptal"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future soruEsitle() async {
    await _db.collection('forum').document(_konu.id).updateData({'sorusayisi': _konu.sorusayisi});
  }

  Future tekrarSil(List<DocumentSnapshot> veri) async {
    if (Fonksiyon.admin()) {
      Soru soru = Soru();
      for (DocumentSnapshot d in veri) {
        Soru soru2 = Soru.fromMap(d.data);
        if (soru.aciklama == soru2.aciklama) {
          await _db.collection('forum').document(soru2.konuId).collection('sorular').document(soru2.id).delete();
        } else {
          soru.aciklama = soru2.aciklama;
        }
      }
    }
  }

/* 
  duzelt(Soru s) async {
    await _db.collection('forum_sorulari').document(s.id).updateData(s.toMap());
  } */

  @override
  void initState() {
    _konu = widget.konu;
    _sorulariAl();
    super.initState();
  }

  @override
  void dispose() {
    _gittim = true;
    super.dispose();
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
            leading:
                IconButton(icon: Icon(Icons.arrow_back, color: Renk.wpKoyu), onPressed: () => Navigator.pop(context)),
            title: Text(
              _konu.baslik,
              style: TextStyle(color: Renk.wpKoyu),
            ),
            actions: <Widget>[
              PopupMenuButton<String>(
                icon: Icon(Icons.sort_by_alpha, color: Renk.wpKoyu),
                tooltip: "sırala",
                onSelected: (key) {
                  Map m = _kriterler.firstWhere((test) => test.containsValue(key));
                  if (!_gittim && m.length > 0) {
                    _aramaKriteri = m['deger'];
                    _aramaYonu = m['yon'];
                    _sorulariAl();
                  }
                },
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  for (Map m in _kriterler)
                    PopupMenuItem(
                      value: m['deger'],
                      child: Text(m['kriter']),
                    ),
                ],
              ),
            ],
          ),
          body: _sorular.length > 0
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      for (Soru soru in _sorular)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: FlatButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SoruSyf(soru: soru),
                              ),
                            ),
                            padding: EdgeInsets.all(0.0),
                            child: SoruWidget(
                              soru: soru,
                              fonk: kullanici,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Center(
                  child: Container(
                    child: Text('Henüz soru eklenmedi'),
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _ekle,
            backgroundColor: Renk.beyaz,
            child: Icon(
              Icons.add,
              color: Renk.wpKoyu,
            ),
            tooltip: "ekle",
          ),
        ),
      ),
    );
  }
}
