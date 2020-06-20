import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/widgets/akis_benzer_widget.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/widgets/akis_yorum_widget.dart';
import 'package:delillerleislamiyet/model/akis_veri_model.dart';
import 'package:delillerleislamiyet/model/akis_veri_yorum.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/profil_ex/profil_ex.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/uyelik/profil_syf.dart';
import 'package:share/share.dart';

class AkisDetay extends StatefulWidget {
  final AkisVeri gVeri;
  final Uye gUye;

  const AkisDetay({Key key, this.gVeri, this.gUye}) : super(key: key);
  @override
  _AkisDetayState createState() => _AkisDetayState();
}

class _AkisDetayState extends State<AkisDetay> {
  final Firestore _db = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AkisVeri _veri;
  Uye _dUye;

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

  Future ekle() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        AkisVeriYorum _yorum = AkisVeriYorum();
        bool hata = false;
        return StatefulBuilder(
          builder: (ctx, setstate) {
            return AlertDialog(
              title: Text("Yeni Yorum Ekle"),
              content: Container(
                width: double.maxFinite,
                child: Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 160.0),
                      child: IntrinsicHeight(
                        child: TextField(
                          decoration: InputDecoration(labelText: "Yorumunuz"),
                          onChanged: (v) {
                            _yorum.cevap = v;
                            if (_yorum.cevap.length <= 5)
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
                    if (_yorum.cevap != null) {
                      if (_yorum.cevap.length > 5) {
                        Timestamp t = Timestamp.now();
                        _yorum.ekleyen = Fonksiyon.uye.uid;
                        _yorum.veriId = _veri.id;
                        _yorum.tarih = t;

                        _db
                            .collection('akis_verileri')
                            .document(_veri.id)
                            .collection('yorumlar')
                            .add(_yorum.toMap())
                            .then((onValue) {
                          _db
                              .collection('akis_verileri')
                              .document(_veri.id)
                              .collection('yorumlar')
                              .document(onValue.documentID)
                              .updateData({'id': onValue.documentID});
                        });

                        _veri.cevapSayisi++;

                        _db.collection('akis_verileri').document(_veri.id).updateData(_veri.toMap());

                        setState(() {});
                        Navigator.pop(context);
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

  Future<List<AkisVeri>> _benzerGetir() async {
    QuerySnapshot querySnapshot = await _db
        .collection('akis_verileri')
        .where('onay', isEqualTo: true)
        .where('kategori', isEqualTo: _veri.kategori)
        .where('ekleyen', isEqualTo: _veri.ekleyen)
        .orderBy('tarih', descending: true)
        .limit(4)
        .getDocuments();

    return querySnapshot.documents.map((d) => AkisVeri.fromMap(d.data)).toList();
  }

  Future<List<AkisVeriYorum>> _yorumGetir() async {
    QuerySnapshot querySnapshot = await _db
        .collection('akis_verileri')
        .document(_veri.id)
        .collection('yorumlar')
        .orderBy('tarih', descending: true)
        .getDocuments();

    return querySnapshot.documents.map((d) => AkisVeriYorum.fromMap(d.data)).toList();
  }

  Future veriGuncelle() async {
    await _db.collection('akis_verileri').document(_veri.id).updateData(_veri.toMap());
    setState(() {});
  }

  Future cevapBegen(AkisVeriYorum c, bool begen) async {
    if (begen) {
      if (!Fonksiyon.begenYorum.contains(c.id) && !Fonksiyon.begenmeYorum.contains(c.id)) {
        Fonksiyon.begenYorum.add(c.id);
        c.begenme++;
        setState(() {});

        await _db
            .collection('akis_verileri')
            .document(_veri.id)
            .collection('yorumlar')
            .document(c.id)
            .updateData({'begenme': c.begenme});

        Logger.log('tag', message: "soru: ${c.toMap()} begen: $begen");
      }
    }

    if (!begen) {
      if (!Fonksiyon.begenmeYorum.contains(c.id) && !Fonksiyon.begenYorum.contains(c.id)) {
        Fonksiyon.begenmeYorum.add(c.id);
        c.begenmeme++;
        setState(() {});
        await _db
            .collection('akis_verileri')
            .document(_veri.id)
            .collection('yorumlar')
            .document(c.id)
            .updateData({'begenmeme': c.begenmeme});

        Logger.log('tag', message: "soru: ${c.toMap()} begen: $begen");
      }
    }
  }

  @override
  void initState() {
    _veri = widget.gVeri;
    _dUye = widget.gUye;
    Logger.log('detay', message: null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Renk.gGri12,
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Renk.wpKoyu,
            title: Text(
              _kategoriler[int.parse(_veri.kategori) - 1].values.toString().replaceAll('(', '').replaceAll(')', ''),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    _veri.resim != "" || _veri.resim == null
                        ? Container(
                            width: double.maxFinite,
                            height: 200.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: NetworkImage(_veri.resim),
                              ),
                            ),
                          )
                        : Container(
                            height: 0.0,
                          ),
                  ],
                ),

                _veri.resim != "" || _veri.resim == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  child: Icon(
                                    FontAwesomeIcons.comments,
                                    size: 20.0,
                                    color: Renk.gGri.withOpacity(0.8),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(left: 5.0),
                                  child: Text(
                                    "${_veri.cevapSayisi}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Renk.gGri.withOpacity(0.8),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          FlatButton(
                            textColor: Colors.black54,
                            onPressed: () async {
                              await Share.share(
                                  "${_veri.baslik == '' ? 'Konu başlığı yok' : _veri.baslik}\n${_veri.aciklama == '' ? 'Konu detayı yok' : _veri.aciklama}");
                              _veri.paylasanlar.add(Fonksiyon.uye.uid);
                              await veriGuncelle();
                              Logger.log('tag', message: "soz paylaşıldı");
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.share,
                                  size: 20,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  child: Text(
                                    "${_veri.paylasanlar.length}",
                                    style: TextStyle(
                                      color: Renk.gGri65,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          FlatButton(
                            textColor: Colors.black54,
                            onPressed: () {
                              if (!Fonksiyon.begenenVeriler.contains(_veri.id)) if (!Fonksiyon.begenmeyenVeriler
                                  .contains(_veri.id)) {
                                _veri.begenmeyenler.add(Fonksiyon.uye.uid);
                                veriGuncelle();

                                Fonksiyon.begenmeyenVeriler.add(_veri.id);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.thumb_down,
                                  size: 20.0,
                                  color: Fonksiyon.begenmeyenVeriler.contains(_veri.id) ? Renk.wpAcik : Renk.gGri65,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  child: Text(
                                    "${_veri.begenmeyenler.length}",
                                    style: TextStyle(
                                      color: Fonksiyon.begenmeyenVeriler.contains(_veri.id) ? Renk.wpAcik : Renk.gGri65,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          FlatButton(
                            textColor: Colors.black54,
                            onPressed: () {
                              if (!Fonksiyon.begenmeyenVeriler.contains(_veri.id)) if (!Fonksiyon.begenenVeriler
                                  .contains(_veri.id)) {
                                _veri.begenenler.add(Fonksiyon.uye.uid);
                                veriGuncelle();
                                Fonksiyon.begenenVeriler.add(_veri.id);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.thumb_up,
                                  size: 20.0,
                                  color: Fonksiyon.begenenVeriler.contains(_veri.id) ? Renk.wpAcik : Renk.gGri65,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  child: Text(
                                    "${_veri.begenenler.length}",
                                    style: TextStyle(
                                      color: Fonksiyon.begenenVeriler.contains(_veri.id) ? Renk.wpAcik : Renk.gGri65,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(),
                IntrinsicHeight(
                  child: Card(
                    child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(bottom: 6.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              if (_dUye.uid == Fonksiyon.uye.uid)
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilSyf()));
                              else
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ProfilSyfEx(
                                              gUye: _dUye,
                                            )));
                            },
                            child: Row(
                              children: <Widget>[
                                _dUye == null
                                    ? Center(child: CircularProgressIndicator())
                                    : Container(
                                        margin: EdgeInsets.all(8.0),
                                        width: 30.0,
                                        height: 30.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: _dUye.resim == null
                                                ? Center(
                                                    child: CircularProgressIndicator(),
                                                  )
                                                : NetworkImage(_dUye.resim),
                                          ),
                                        ),
                                      ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      _dUye == null
                                          ? Center(
                                              child: LinearProgressIndicator(
                                              backgroundColor: Renk.wp,
                                            ))
                                          : Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                _dUye.gorunenIsim == "" ? "isimsiz kullanıcı" : _dUye.gorunenIsim,
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Renk.wpKoyu,
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      _kategoriler[int.parse(_veri.kategori) - 1]
                                          .values
                                          .toString()
                                          .replaceAll('(', '')
                                          .replaceAll(')', ''),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.0,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              _veri.baslik == ''
                                  ? Container(
                                      height: 0,
                                    )
                                  : Container(
                                      width: double.maxFinite,
                                      margin: EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _veri.baslik,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                              _veri.aciklama == ''
                                  ? Container(
                                      height: 0,
                                    )
                                  : Column(
                                      children: <Widget>[
                                        Container(
                                          width: double.maxFinite,
                                          margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 2.0),
                                          child: Text(
                                            _veri.aciklama,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 5.0, top: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(left: 5.0),
                                        child: Text(
                                          _veri.okunma.toString(),
                                          style: TextStyle(
                                              color: Renk.gGri.withOpacity(0.8),
                                              fontStyle: FontStyle.normal,
                                              fontSize: 13),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 5.0),
                                        child: Text(
                                          'görüntülenme',
                                          style: TextStyle(
                                              color: Renk.gGri.withOpacity(0.8),
                                              fontStyle: FontStyle.normal,
                                              fontSize: 12),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(left: 5.0),
                                        child: Text(
                                          '-',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 5.0, top: 3.0),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "${Fonksiyon.zamanFarkiBul(_veri.tarih.toDate())} önce",
                                          style: TextStyle(
                                              color: Renk.gGri.withOpacity(0.8),
                                              fontStyle: FontStyle.normal,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5.0, right: 20.0, top: 5.0),
                            child: Divider(
                              height: 1.0,
                              color: Colors.black38,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 5.0),
                                      child: Icon(
                                        FontAwesomeIcons.comments,
                                        size: 20.0,
                                        color: Renk.gGri.withOpacity(0.8),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        "${_veri.cevapSayisi}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Renk.gGri.withOpacity(0.8),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              FlatButton(
                                textColor: Colors.black54,
                                onPressed: () async {
                                  await Share.share(
                                      "${_veri.baslik == '' ? 'Konu başlığı yok' : _veri.baslik}\n${_veri.aciklama == '' ? 'Konu detayı yok' : _veri.aciklama}");
                                  _veri.paylasanlar.add(Fonksiyon.uye.uid);
                                  await veriGuncelle();
                                  Logger.log('tag', message: "soz paylaşıldı");
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.share,
                                      size: 20,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        "${_veri.paylasanlar.length}",
                                        style: TextStyle(
                                          color: Renk.gGri65,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              FlatButton(
                                textColor: Colors.black54,
                                onPressed: () {
                                  if (!Fonksiyon.begenenVeriler.contains(_veri.id)) if (!Fonksiyon.begenmeyenVeriler
                                      .contains(_veri.id)) {
                                    _veri.begenmeyenler.add(Fonksiyon.uye.uid);
                                    veriGuncelle();

                                    Fonksiyon.begenmeyenVeriler.add(_veri.id);
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.thumb_down,
                                      size: 20.0,
                                      color: Fonksiyon.begenmeyenVeriler.contains(_veri.id) ? Renk.wpAcik : Renk.gGri65,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        "${_veri.begenmeyenler.length}",
                                        style: TextStyle(
                                          color: Fonksiyon.begenmeyenVeriler.contains(_veri.id)
                                              ? Renk.wpAcik
                                              : Renk.gGri65,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              FlatButton(
                                textColor: Colors.black54,
                                onPressed: () {
                                  if (!Fonksiyon.begenmeyenVeriler.contains(_veri.id)) if (!Fonksiyon.begenenVeriler
                                      .contains(_veri.id)) {
                                    _veri.begenenler.add(Fonksiyon.uye.uid);
                                    veriGuncelle();
                                    Fonksiyon.begenenVeriler.add(_veri.id);
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.thumb_up,
                                      size: 20.0,
                                      color: Fonksiyon.begenenVeriler.contains(_veri.id) ? Renk.wpAcik : Renk.gGri65,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        "${_veri.begenenler.length}",
                                        style: TextStyle(
                                          color:
                                              Fonksiyon.begenenVeriler.contains(_veri.id) ? Renk.wpAcik : Renk.gGri65,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'İlginizi Çekebilir',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Renk.wpKoyu,
                    ),
                  ),
                ),
                FutureBuilder<List<AkisVeri>>(
                  future: _benzerGetir(),
                  builder: (_, als) {
                    if (als.connectionState == ConnectionState.active) return LinearProgressIndicator();
                    if (als.hasData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (AkisVeri veri in als.data)
                            if (_veri.id != veri.id) AkisBenzerWidget(veri: veri, scaffoldKey: _scaffoldKey)
                        ],
                      );
                    }
                    return SizedBox();
                  },
                ),

                if (_veri.cevapSayisi > 0)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tüm Yorumlar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Renk.wpKoyu,
                      ),
                    ),
                  ),

                FutureBuilder<List<AkisVeriYorum>>(
                  future: _yorumGetir(),
                  builder: (_, als) {
                    if (als.connectionState == ConnectionState.active) return LinearProgressIndicator();
                    if (als.hasData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (AkisVeriYorum _yorum in als.data)
                            AkisYorumWidget(
                              yorum: _yorum,
                              scaffoldKey: _scaffoldKey,
                              begen: cevapBegen,
                            )
                        ],
                      );
                    }

                    return SizedBox();
                  },
                ),
                SizedBox(
                  height: 200,
                )
                //  SaglikMutluluk(),
                //   SizedBox(height: 3400, child: YouTubeMain(de: true)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: ekle,
            child: Icon(Icons.send),
            foregroundColor: Colors.white,
            mini: true,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }
}
