import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/akis_detay.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/akis_veri_ekle.dart';
import 'package:delillerleislamiyet/model/akis_veri_model.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:share/share.dart';

class AkisVeriWidget extends StatefulWidget {
  final AkisVeri veri;
  final Function yenile;

  final GlobalKey<ScaffoldState> scaffoldKey;

  const AkisVeriWidget({Key key, this.veri, this.scaffoldKey, this.yenile}) : super(key: key);
  @override
  _AkisVeriWidgetState createState() => _AkisVeriWidgetState();
}

class _AkisVeriWidgetState extends State<AkisVeriWidget> {
  final String tag = 'AkisVeriWidget';
  final Firestore _db = Firestore.instance;
  Uye _eUye;
  AkisVeri _veri;
  bool _gittim = false;
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

  Future veriGuncelle() async {
    await _db.collection('akis_verileri').document(_veri.id).updateData(_veri.toMap());
    setState(() {});
  }

  Future okunma() async {
    _veri.okunma++;

    await _db.collection('akis_verileri').document(_veri.id).updateData(_veri.toMap());
    setState(() {});
  }

  Future _kCek() async {
    DocumentSnapshot ds = await _db.collection('uyeler').document(_veri.ekleyen).get();

    _eUye = Uye.fromMap(ds.data);
    if (!_gittim) setState(() {});
  }

  @override
  void dispose() {
    _gittim = true;
    super.dispose();
  }

  @override
  void initState() {
    Logger.log(tag, message: widget.veri.aciklama.toString());
    _veri = widget.veri;
    _kCek();
    if (_veri.begenenler.contains(Fonksiyon.uye.uid)) Fonksiyon.begenenVeriler.add(_veri.id);
    if (_veri.begenmeyenler.contains(Fonksiyon.uye.uid)) Fonksiyon.begenmeyenVeriler.add(_veri.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.beyaz,
      margin: EdgeInsets.only(bottom: 6.0),
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                _eUye == null
                    ? Container(width: 30.0, height: 30.0, child: Center(child: CircularProgressIndicator()))
                    : Container(
                        margin: EdgeInsets.all(8.0),
                        width: 30.0,
                        height: 30.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _eUye.resim == null
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : NetworkImage(_eUye.resim),
                          ),
                        ),
                      ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _eUye == null
                          ? Center(
                              child: LinearProgressIndicator(
                              backgroundColor: Renk.beyaz,
                            ))
                          : Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _eUye.gorunenIsim == "" ? "isimsiz kullanıcı" : _eUye.gorunenIsim,
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                              ),
                            ),
                    ],
                  ),
                ),
                Container(
                  color: Renk.wp.withOpacity(0.6),
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
                ),
                if (_veri.ekleyen == Fonksiyon.uye.uid)
                  Container(
                    child: IconButton(
                        icon: Icon(FontAwesomeIcons.solidEdit),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AkisVeriEkle(
                                        akisVeri: _veri,
                                        yenile: widget.yenile,
                                      )));
                        }),
                  )
              ],
            ),
            InkWell(
              onTap: () {
                okunma();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AkisDetay(
                      gVeri: _veri,
                      gUye: _eUye,
                    ),
                  ),
                );
              },
              child: Column(
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
                                maxLines: 7,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Container(
                              width: double.maxFinite,
                              margin: EdgeInsets.only(bottom: 3.0, right: 20.0),
                              alignment: Alignment.centerRight,
                              child: Text(
                                "...",
                                style: TextStyle(
                                  color: Renk.wpKoyu,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                  _veri.resim != "" || _veri.resim == null
                      ? Container(
                          width: double.maxFinite,
                          height: 200.0,
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
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
                            style:
                                TextStyle(color: Renk.gGri.withOpacity(0.8), fontStyle: FontStyle.normal, fontSize: 13),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5.0),
                          child: Text(
                            'görüntülenme',
                            style:
                                TextStyle(color: Renk.gGri.withOpacity(0.8), fontStyle: FontStyle.normal, fontSize: 12),
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
                            style:
                                TextStyle(color: Renk.gGri.withOpacity(0.8), fontStyle: FontStyle.normal, fontSize: 12),
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
                        margin: EdgeInsets.only(left: 8.0),
                        child: Icon(
                          FontAwesomeIcons.comments,
                          size: 20.0,
                          color: Renk.gGri.withOpacity(0.8),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 8.0),
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
                    Logger.log(tag, message: "soz paylaşıldı");
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
          ],
        ),
      ),
    );
  }
}
