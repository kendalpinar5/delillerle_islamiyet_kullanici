import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/akis_detay.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/akis_veri_ekle.dart';
import 'package:delillerleislamiyet/model/akis_veri_model.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/profil_ex/profil_ex.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/uyelik/profil_syf.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  Future veriGuncelle(String neOldu) async {
    await _db.collection('akis_verileri').document(_veri.id).updateData(_veri.toMap());
    if (_eUye.bildirimjetonu != '' && _eUye.bildirimjetonu != null && _eUye.uid != Fonksiyon.uye.uid)
      Fonksiyon.bildirimGonder(
          alici: _veri.ekleyen,
          gonderen: Fonksiyon.uye.uid,
          tur: 'veri_tepki',
          baslik: 'Gönderide hareketlenme',
          mesaj: '${Fonksiyon.uye.gorunenIsim} senin ${_veri.baslik} yazını $neOldu',
          bBaslik: 'Gönderide hareketlenme',
          bMesaj: '${Fonksiyon.uye.gorunenIsim} senin ${_veri.baslik} yazını $neOldu',
          jeton: [_eUye.bildirimjetonu]);
    setState(() {});
  }

  Future okunma() async {
    _veri.okunma = _veri.okunma + 1;

    await _db.collection('akis_verileri').document(_veri.id).updateData({'okunma': _veri.okunma});

    setState(() {});
  }

  Future _kCek() async {
    DocumentSnapshot ds = await _db.collection('uyeler').document(_veri.ekleyen).get();

    _eUye = Uye.fromMap(ds.data);
    if (!_gittim) setState(() {});
  }
/* 
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          _begenenler = [];
          _veri.begenenler.forEach((element) {
            Firestore.instance.collection('uyeler').document(element).get().then((value) {
              Uye bU = Uye.fromMap(value.data);
              _begenenler.add(bU);
            });
          });

          return Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < _veri.begenenler.length; i++)
                    _begenenler[i] == null
                        ? Container(
                            height: 50,
                            child: Text(_begenenler[i].gorunenIsim == null ? '' : ''),
                          )
                        : LinearProgressIndicator(),
                ],
              ),
            ),
          );
        });
  } */

  @override
  void dispose() {
    _gittim = true;
    super.dispose();
  }

  @override
  void initState() {
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
      margin: EdgeInsets.only(top: 6.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () {
                  if (_eUye != null) if (_eUye.uid != Fonksiyon.uye.uid)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfilSyfEx(
                                  gUye: _eUye,
                                )));
                  else
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilSyf()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _eUye == null
                        ? Container(width: 30.0, height: 30.0, child: Center(child: CircularProgressIndicator()))
                        : Container(
                            margin: EdgeInsets.all(8.0),
                            width: 38.0,
                            height: 38.0,
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _eUye == null
                            ? Container(
                                width: 30,
                                child: Center(
                                    child: LinearProgressIndicator(
                                  backgroundColor: Renk.beyaz,
                                )),
                              )
                            : Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _eUye.gorunenIsim == "" ? "isimsiz kullanıcı" : _eUye.gorunenIsim,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).size.width / 26),
                                ),
                              ),
                        Container(
                          margin: EdgeInsets.only(),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${Fonksiyon.zamanFarkiBul(_veri.tarih.toDate())} önce",
                            style:
                                TextStyle(color: Renk.gGri.withOpacity(0.8), fontStyle: FontStyle.normal, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Renk.wp.withOpacity(0.6),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(50), bottomLeft: Radius.circular(50))),
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
                    yenile: widget.yenile,
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
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width / 26),
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
                                  fontSize: MediaQuery.of(context).size.width / 24),
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
                        height: 210.0,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          //  _settingModalBottomSheet(context);
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text(
                                _veri.okunma.toString(),
                                style: TextStyle(
                                    color: Renk.gGri.withOpacity(0.8), fontStyle: FontStyle.normal, fontSize: 13),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text(
                                'görüntülenme',
                                style: TextStyle(
                                    color: Renk.gGri.withOpacity(0.8), fontStyle: FontStyle.normal, fontSize: 12),
                              ),
                            ),
                            if (_veri.begenenler.length > 0)
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
                            if (_veri.begenenler.length > 0)
                              Container(
                                margin: EdgeInsets.only(left: 5.0),
                                child: Text(
                                  "${_veri.begenenler.length}",
                                  style: TextStyle(
                                      color: Renk.gGri.withOpacity(0.8), fontStyle: FontStyle.normal, fontSize: 13),
                                ),
                              ),
                            if (_veri.begenenler.length > 0)
                              Container(
                                margin: EdgeInsets.only(left: 5.0),
                                child: Text(
                                  'beğenme',
                                  style: TextStyle(
                                      color: Renk.gGri.withOpacity(0.8), fontStyle: FontStyle.normal, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          if (_veri.cevapSayisi > 0)
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(left: 8.0),
                              child: Text(
                                "${_veri.cevapSayisi}",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Renk.gGri.withOpacity(0.8), fontSize: 13),
                              ),
                            ),
                          if (_veri.cevapSayisi > 0)
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(right: 8.0, left: 3),
                              child: Text(
                                "Yorum",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Renk.gGri.withOpacity(0.8), fontSize: 12),
                              ),
                            ),
                          if (_veri.paylasanlar.length > 0 && _veri.cevapSayisi > 0)
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
                          if (_veri.paylasanlar.length > 0)
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(left: 8.0),
                              child: Text(
                                "${_veri.paylasanlar.length}",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Renk.gGri.withOpacity(0.8), fontSize: 13),
                              ),
                            ),
                          if (_veri.paylasanlar.length > 0)
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(right: 8.0, left: 3),
                              child: Text(
                                "Paylaşan",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Renk.gGri.withOpacity(0.8), fontSize: 12),
                              ),
                            )
                        ],
                      )
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
                child: FlatButton(
                  textColor: Colors.black54,
                  onPressed: () {
                    if (!Fonksiyon.begenmeyenVeriler.contains(_veri.id)) if (!Fonksiyon.begenenVeriler
                        .contains(_veri.id)) {
                      _veri.begenenler.add(Fonksiyon.uye.uid);

                      veriGuncelle('beğendi');
                      Fonksiyon.begenenVeriler.add(_veri.id);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.thumbsUp,
                        size: MediaQuery.of(context).size.width / 22,
                        color: Fonksiyon.begenenVeriler.contains(_veri.id) ? Renk.wpAcik : Renk.gGri65,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 5.0),
                        child: Text(
                          'Beğen',
                          style: TextStyle(
                              color: Fonksiyon.begenenVeriler.contains(_veri.id) ? Renk.wpAcik : Renk.gGri65,
                              fontStyle: FontStyle.normal,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FlatButton(
                textColor: Colors.black54,
                onPressed: () {
                  if (!Fonksiyon.begenenVeriler.contains(_veri.id)) if (!Fonksiyon.begenmeyenVeriler
                      .contains(_veri.id)) {
                    _veri.begenmeyenler.add(Fonksiyon.uye.uid);
                    veriGuncelle('beğenmedi');

                    Fonksiyon.begenmeyenVeriler.add(_veri.id);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.thumbsDown,
                      size: MediaQuery.of(context).size.width / 22,
                      color: Fonksiyon.begenmeyenVeriler.contains(_veri.id) ? Renk.wpAcik : Renk.gGri65,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5.0),
                      child: Text(
                        "${_veri.begenmeyenler.length}",
                        style: TextStyle(
                            color: Fonksiyon.begenmeyenVeriler.contains(_veri.id) ? Renk.wpAcik : Renk.gGri65,
                            fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        FontAwesomeIcons.comments,
                        size: MediaQuery.of(context).size.width / 22,
                        color: Renk.gGri.withOpacity(0.8),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Yorum Yap",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Renk.gGri.withOpacity(0.8), fontSize: 12),
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
                  await veriGuncelle('paylaştı');
                  Logger.log(tag, message: "soz paylaşıldı");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.shareAlt,
                      size: MediaQuery.of(context).size.width / 22,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5.0),
                      child: Text(
                        "Paylaş",
                        style: TextStyle(color: Renk.gGri65, fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
