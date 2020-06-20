import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delillerleislamiyet/forum/cevap_widget.dart';
import 'package:delillerleislamiyet/forum/soru_widget.dart';
import 'package:delillerleislamiyet/model/cevap.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/model/soru.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class SoruSyf extends StatefulWidget {
  final Soru soru;

  SoruSyf({Key key, @required this.soru}) : super(key: key);
  @override
  _SoruSyfState createState() => _SoruSyfState();
}

class _SoruSyfState extends State<SoruSyf> {
  final String tag = "SoruSyf";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Firestore _db = Firestore.instance;
  final Uye _uye = Fonksiyon.uye;
  bool _bas = true;
  Soru _soru;

  Future<List<DocumentSnapshot>> cevaplariAl() async {
    QuerySnapshot querySnapshot;
    try {
      querySnapshot = await _db
          .collection('forum')
          .document(_soru.konuId)
          .collection('sorular')
          .document(_soru.id)
          .collection('cevaplar')
          .orderBy('begenme', descending: true)
          .getDocuments();
      _bas = false;
      Logger.log(tag, message: "gelenler: $querySnapshot");
      if (_soru.cevapsayisi != querySnapshot.documents.length) {
        _soru.cevapsayisi = querySnapshot.documents.length;
        await cevapEsitle();
      }
      return querySnapshot.documents;
    } on PlatformException catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    }
    return null;
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

  Future ekle() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        Cevap cevap = Cevap();
        bool hata = false;
        return StatefulBuilder(
          builder: (ctx, setstate) {
            return AlertDialog(
              title: Text("Yeni Cevap Ekle"),
              content: Container(
                width: double.maxFinite,
                child: Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 160.0),
                      child: IntrinsicHeight(
                        child: TextField(
                          decoration: InputDecoration(labelText: "Cevabınız"),
                          onChanged: (v) {
                            cevap.cevap = v;
                            if (cevap.cevap.length <= 5)
                              hata = true;
                            else
                              hata = false;
                            setstate(() {});
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
                    if (cevap.cevap != null) {
                      if (cevap.cevap.length > 5) {
                        Timestamp t = Timestamp.now();
                        cevap.ekleyen = _uye.uid;
                        cevap.soruId = _soru.id;
                        cevap.tarih = t;
                        cevap.id = t.millisecondsSinceEpoch.toString();

                        _db
                            .collection('forum')
                            .document(_soru.konuId)
                            .collection('sorular')
                            .document(_soru.id)
                            .collection('cevaplar')
                            .document(t.millisecondsSinceEpoch.toString())
                            .setData(cevap.toMap());
                        _soru.cevapsayisi++;
                        Navigator.pop(context);
                        setState(() {});
                      } else {
                        hata = true;
                        setState(() {});
                      }
                    } else {
                      hata = true;
                      setState(() {});
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

  Future cevapEsitle() async {
    await _db
        .collection('forum')
        .document(_soru.konuId)
        .collection('sorular')
        .document(_soru.id)
        .updateData({'cevapsayisi': _soru.cevapsayisi});
  }

  Future tekrarSil(List<DocumentSnapshot> veri) async {
    if (Fonksiyon.admin()) {
      Cevap cevap = Cevap();
      for (DocumentSnapshot d in veri) {
        Cevap cevap2 = Cevap.fromMap(d.data);
        if (cevap.cevap == cevap2.cevap) {
          await _db
              .collection('forum')
              .document(_soru.konuId)
              .collection('sorular')
              .document(_soru.id)
              .collection('cevaplar')
              .document(cevap2.id)
              .delete();
        } else {
          cevap.cevap = cevap2.cevap;
        }
      }
    }
  }

  Future soruBegen(bool begen) async {
    if (!Fonksiyon.begenler.contains(_soru.id)) {
      if (begen)
        _soru.begenme++;
      else
        _soru.begenmeme++;
      await _db
          .collection('forum')
          .document(_soru.konuId)
          .collection('sorular')
          .document(_soru.id)
          .updateData({'begenme': _soru.begenme, 'begenmeme': _soru.begenmeme});
      Fonksiyon.begenler.add(_soru.id);
      Logger.log(tag, message: "soru: ${_soru.toMap()} begen: $begen");
    }
  }

  Future cevapBegen(Cevap c, bool begen) async {
    Logger.log(tag, message: "soru: ${c.toMap()} begen: $begen");
    if (!Fonksiyon.begenler.contains(c.id)) {
      if (begen)
        c.begenme++;
      else
        c.begenmeme++;
      await _db
          .collection('forum')
          .document(_soru.konuId)
          .collection('sorular')
          .document(_soru.id)
          .collection('cevaplar')
          .document(c.id)
          .updateData({'begenme': c.begenme, 'begenmeme': c.begenmeme});
      Fonksiyon.begenler.add(c.id);
      Logger.log(tag, message: "soru: ${c.toMap()} begen: $begen");
    }
  }

  @override
  void didChangeDependencies() {
    if (_bas) {
      cevaplariAl();
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _soru = widget.soru;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Renk.gGri12,
          appBar: AppBar(
            title: Text(_soru.baslik),
          ),
          body: Center(
            child: FutureBuilder(
              future: cevaplariAl(),
              builder: (ctx, AsyncSnapshot<List<DocumentSnapshot>> q) {
                if (q.connectionState == ConnectionState.active) {
                  return LinearProgressIndicator();
                } else if (q.hasData) {
                  List<DocumentSnapshot> veri = q.data;
                  if (Fonksiyon.admin()) tekrarSil(veri);
                  return ListView.builder(
                    itemCount: veri.length + 1,
                    itemBuilder: (c, i) {
                      if (i == 0) {
                        return SoruWidget(
                          soru: _soru,
                          fonk: kullanici,
                          begen: soruBegen,
                        );
                      } else {
                        i = i - 1;
                        Cevap cevap = Cevap.fromMap(veri[i].data);

                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: EdgeInsets.only(
                              bottom: i == veri.length - 1 ? 80 : 0),
                          child: CevapWidget(
                            cevap: cevap,
                            fonk: kullanici,
                            begen: cevapBegen,
                          ),
                        );
                      }
                    },
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: ekle,
            child: Icon(
              Icons.message,
              color: Renk.beyaz,
            ),
          ),
        ),
      ),
    );
  }
}
