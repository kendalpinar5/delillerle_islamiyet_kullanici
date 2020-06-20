import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';

import 'yeni_grup_end_drawer.dart';
import 'yeni_grup_mesajlar.dart';

class YeniGrupDetay extends StatefulWidget {
  final Grup grup;
  final Box kutu;
  final bool onaydan;

  const YeniGrupDetay({
    Key key,
    @required this.grup,
    this.kutu,
    this.onaydan = false,
  }) : super(key: key);
  @override
  _YeniGrupDetayState createState() => _YeniGrupDetayState();
}

class _YeniGrupDetayState extends State<YeniGrupDetay> {
  final String tag = "YeniGrupDetay";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Grup _grup;
  Firestore _firestore = Firestore.instance;
  Box _kutu;

  bool _katiliyor = false;
  bool _kIsleniyor = false;

  bool _gittim = false;

  Future _grubaKatil([String uid]) async {
    _kIsleniyor = true;
    if (!_gittim) setState(() {});

    if (_grup.katilimcilar.length < int.parse(_grup.maxkatilimci)) {
      List yeniList = List.from(_grup.katilimcilar);

      yeniList.add(uid ?? Fonksiyon.uye.uid);
      _grup.katilimcilar = yeniList;

      _grup.katilimcisayisi = "${_grup.katilimcilar.length}";

      await _firestore.collection('gruplar').document(_grup.id).updateData({
        "katilimcisayisi": _grup.katilimcisayisi,
        'katilimcilar': FieldValue.arrayUnion([uid ?? Fonksiyon.uye.uid]),
      });

      if (Fonksiyon.uye.gruplar == null) Fonksiyon.uye.gruplar = [];
      Fonksiyon.uye.gruplar.add(_grup.id);
      _kutu.put('kullanici', Fonksiyon.uye.toMap());

      _firestore.collection('uyeler').document(Fonksiyon.uye.uid).updateData({
        'gruplar': FieldValue.arrayUnion([_grup.id])
      });

      _katiliyor = true;
    } else {
      Fonksiyon.mesajGoster(_scaffoldKey, Yazi.sayiBasarisiz);
    }

    _kIsleniyor = false;
    if (!_gittim) setState(() {});
  }

  Future<Grup> _kontrol() async {
    _grup = widget.grup;

    if (widget.grup.baslik == null) {
      DocumentSnapshot ds =
          await _firestore.collection('gruplar').document(_grup.id).get();
      _grup = Grup.fromMap(ds.data, ds.documentID);
    }

    if (Fonksiyon.admin())
      _katiliyor = true;
    else
      _katiliyor = _grup.katilimcilar.contains(Fonksiyon.uye.uid);

    return Future.value(_grup);
  }

  @override
  void initState() {
    Fonksiyon.aktifSayfa = "grup${widget.grup.id}";
    if (widget.kutu != null)
      _kutu = widget.kutu;
    else
      Hive.openBox('kayitaraci').then((onValue) => _kutu = onValue);
    Logger.log(tag, message: 'initState');
    super.initState();
  }

  @override
  void dispose() {
    Fonksiyon.aktifSayfa = "bos";
    _gittim = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp.withOpacity(0.65),
      child: SafeArea(
        child: FutureBuilder<Grup>(
          future: _kontrol(),
          builder: (context, AsyncSnapshot<Grup> snapshot) {
            if (snapshot.hasData) {
              _grup = snapshot.data;
              return Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  title: Text(_grup.baslik),
                  actions: <Widget>[
                    IconButton(
                      onPressed: () {
                        if (_katiliyor || widget.onaydan || Fonksiyon.admin())
                          _scaffoldKey.currentState.openEndDrawer();
                      },
                      icon: Icon(FontAwesomeIcons.ellipsisH),
                    ),
                  ],
                ),
                body: Stack(
                  children: <Widget>[
                    YeniGrupMesajlar(grup: _grup),
                    if (!_katiliyor)
                      Positioned.fill(
                        child: Container(
                          color: Renk.beyaz.withOpacity(0.7),
                          child: _kIsleniyor
                              ? Center(child: CircularProgressIndicator())
                              : Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 60.0),
                                    child: RaisedButton(
                                      color: Renk.wpKoyu,
                                      textColor: Renk.beyaz,
                                      onPressed: () {
                                        if (_grup.seviye < 10 ||
                                            _grup.il == Fonksiyon.uye.il ||
                                            Fonksiyon.uye.rutbe > 50)
                                          _grubaKatil();
                                        else {
                                          Fonksiyon.mesajGoster(
                                            _scaffoldKey,
                                            "Sadece yetkili olduğunuz ilin grubuna giriş yapabilirsiniz!",
                                          );
                                        }
                                      },
                                      child: Text("Gruba Katıl"),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
                endDrawer: YeniGrupEndDrawer(grup: _grup, kutu: _kutu),
              );
            }
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        ),
      ),
    );
  }
}
