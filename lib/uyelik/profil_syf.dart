import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delillerleislamiyet/anasayfa/hikayeler/hikaye_ekle_giris.dart';
import 'package:delillerleislamiyet/anasayfa/hikayeler/hikayeler.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/akis_veri_ekle.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/widgets/akis_veri_widget.dart';
import 'package:delillerleislamiyet/ayarlar/ayarlar.dart';
import 'package:delillerleislamiyet/model/akis_veri_model.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';
import 'package:delillerleislamiyet/uyelik/arkadas_listesi.dart';
import 'package:delillerleislamiyet/uyelik/profile_item.dart';
import 'package:delillerleislamiyet/uyelik/widgets/arkadaslar_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';

class ProfilSyf extends StatefulWidget {
  @override
  _ProfilSyfState createState() => _ProfilSyfState();
}

class _ProfilSyfState extends State<ProfilSyf> {
  final String tag = Yazi.profilSayfasi;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Firestore _db = Firestore.instance;
  final ScrollController _scrollController = ScrollController();

  Box _kutu;
  Uye user;
  File _file;

  bool _gittim = false;
  List<AkisVeri> _akisVeri = [];
  DocumentSnapshot sonDoc;

  bool _islem = false;

  double _sY = 0;
  double _sO = 0;

/* 
  _konumSecimiYap(LatLng ll) async {
    Map adrs = await Fonksiyon.adresbul(ll.latitude, ll.longitude);
    if (adrs != null && adrs['status'] == "OK") {
      List adres = adrs['results'];
      adres =
          adres.map((f) => f['address_components'][0]['long_name']).toList();

      user.yeniAdres = {
        'adres': adres,
        'enlem': ll.latitude,
        'boylam': ll.longitude,
      };
      await Firestore.instance
          .collection('kullanicilar')
          .document(user.uid)
          .updateData({'yeni_adres': user.yeniAdres});
    }
    if (!_gittim) setState(() {});
  } */

  _resimAc(String resim) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Container(
            color: Renk.siyah,
            child: Image.network(
              resim,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  secim(List s) {
    user.ilgiAlanlari = s;
    //if (!_gittim) setState(() {});
  }

  Future _giris() async {
    _kutu = await Hive.openBox('kayitaraci');
    user = Uye.fromMap(Map<String, dynamic>.from(_kutu.get('kullanici')));

    if (user.element == "Hidrojen") {
      user.element = "Bronz_5";
      Firestore.instance.collection('uyeler').document(user.uid).updateData({'element': "Bronz_5"});
    }

    Firestore.instance.collection('uyeler').document(user.uid).get().then((DocumentSnapshot ds) {
      user = Uye.fromMap(ds.data);
      Fonksiyon.uye = user;
      _kutu.put('kullanici', user.toMap());
      if (!_gittim) setState(() {});
    });
  }

  Future _makaleGetir() async {
    setState(() => _islem = true);
    QuerySnapshot qs;
    if (sonDoc == null)
      qs = await _db
          .collection('akis_verileri')
          .where('ekleyen', isEqualTo: Fonksiyon.uye.uid)
          .where('onay', isEqualTo: true)
          .orderBy('tarih', descending: true)
          .limit(5)
          .getDocuments();
    else
      qs = await _db
          .collection('akis_verileri')
          .where('ekleyen', isEqualTo: Fonksiyon.uye.uid)
          .where('onay', isEqualTo: true)
          .orderBy('tarih', descending: true)
          .startAfterDocument(sonDoc)
          .limit(5)
          .getDocuments();
    if (qs.documents.isNotEmpty) sonDoc = qs.documents.last;
    for (DocumentSnapshot ds in qs.documents) {
      _akisVeri.add(AkisVeri.fromMap(ds.data));
    }
    setState(() => _islem = false);
  }

  yenile() {
    _akisVeri = [];
    sonDoc = null;
    _makaleGetir();
    setState(() {});
  }

  @override
  void initState() {
    _giris();

    _makaleGetir();
    _scrollController.addListener(() {
      _sO = _scrollController.offset;
      _sY = _scrollController.position.maxScrollExtent;

      if (_sO + 220 > _sY && !_islem) _makaleGetir();
    });
    super.initState();
  }

  @override
  void dispose() {
    _gittim = true;

    super.dispose();
  }

  int islemSayisi = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("${Yazi.profilSayfasi}"),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => Ayarlar(
                                  yenile: _giris,
                                )));
                  })
            ],
            /* actions: <Widget>[
              IconButton(
                onPressed: () async {
                  Logger.log(tag, message: "İşlem başladı ${ks.length}");
                  /* for (Map k in ks) {
                    QuerySnapshot qs = await Firestore.instance
                        .collection('kullanicilar')
                        .where('email',
                            isEqualTo: "${k['email']}".toLowerCase())
                        .getDocuments();

                    for (DocumentSnapshot ds in qs.documents) {
                      Logger.log(tag, message: "${ds.data['gorunen_isim']}");
                      Logger.log(tag, message: "${k['isim']}");
                      await Firestore.instance
                          .collection('kullanicilar')
                          .document(ds.documentID)
                          .updateData({
                        'gorunen_isim': "${k['isim']}",
                        "il": "${k['il']}",
                        "rutbe": 21,
                      });
                    }
                    setState(() => islemSayisi++);
                  } */
                  Logger.log(tag, message: "İşlem bitti");
                },
                icon: Icon(Icons.airline_seat_flat_angled),
              ),
            ], */
          ),
          body: user == null
              ? Center(child: CircularProgressIndicator())
              : Container(
                  color: Renk.beyaz,
                  height: double.maxFinite,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 275,
                          margin: EdgeInsets.only(bottom: 10),
                          child: Stack(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Card(
                                    elevation: 10,
                                    margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20), topLeft: Radius.circular(20))),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 200,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Renk.wpKoyu,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                                        /*  image: DecorationImage(
                                            image: NetworkImage(
                                              user.resim,
                                            ),
                                            fit: BoxFit.fill), */
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 50.0),
                                        child: Text(
                                          user.gorunenIsim,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width / 20, color: Renk.beyaz),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    /*  padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [0.3, 0.7],
                                        colors: [
                                          Renk.wp,
                                          Renk.gGri9,
                                        ],
                                      ),
                                    ), */

                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Container(
                                                  margin: EdgeInsets.only(bottom: 0),
                                                  child: Text(
                                                    "Gönderiler",
                                                    style: TextStyle(
                                                      color: Renk.wpKoyu,
                                                      fontSize: Fonksiyon.ekran.width / 28,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                  child: Text(
                                                user.gonderiSayisi.toString(),
                                                style: TextStyle(
                                                  color: Renk.siyah,
                                                  fontSize: Fonksiyon.ekran.width / 26,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => Navigator.push(
                                                context, MaterialPageRoute(builder: (_) => ArkadasListesi())),
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    margin: EdgeInsets.only(bottom: 0),
                                                    child: Text(
                                                      "Arkadaşlar",
                                                      style: TextStyle(
                                                        color: Renk.wpKoyu,
                                                        fontSize: Fonksiyon.ekran.width / 28,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    user.arkadaslar.length.toString(),
                                                    style: TextStyle(
                                                      color: Renk.siyah,
                                                      fontSize: Fonksiyon.ekran.width / 26,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                right: MediaQuery.of(context).size.width / 2 - 75,
                                child: Stack(
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        _resimAc(user.resim);
                                      },
                                      child: Container(
                                        height: 150,
                                        width: 150,
                                        padding: EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          color: Renk.beyaz,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Renk.gGri,
                                              blurRadius: 10.0,
                                            ),
                                          ],
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipOval(
                                          child: _file == null
                                              ? CachedNetworkImage(
                                                  imageUrl: user.resim,
                                                  placeholder: (context, url) => CircularProgressIndicator(),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(_file, fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                    /*  Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        alignment: Alignment.bottomCenter,
                                        child: IconButton(icon: Icon(Icons.photo_camera), onPressed: null),
                                      ),
                                    ) */
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        /*  Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.3, 0.7],
                              colors: [
                                Renk.wp,
                                Renk.gGri9,
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          "Gönderiler",
                                          style: TextStyle(
                                            color: Renk.beyaz,
                                            fontSize: Fonksiyon.ekran.width / 30,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        child: Text(
                                      user.gonderiSayisi.toString(),
                                      style: TextStyle(
                                        color: Renk.gKirmizi,
                                        fontSize: Fonksiyon.ekran.width / 26,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              Stack(
                                children: <Widget>[
                                  InkWell(
                                    onTap: _resimSec,
                                    child: Container(
                                      height: 150,
                                      width: 150,
                                      padding: EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                        color: Renk.beyaz,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Renk.gGri,
                                            blurRadius: 10.0,
                                          ),
                                        ],
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: _file == null
                                            ? CachedNetworkImage(
                                                imageUrl: user.resim,
                                                placeholder: (context, url) => CircularProgressIndicator(),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(_file, fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      alignment: Alignment.bottomCenter,
                                      child: IconButton(icon: Icon(Icons.photo_camera), onPressed: null),
                                    ),
                                  )
                                ],
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => ArkadasListesi())),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: Text(
                                            "Arkadaşlar",
                                            style: TextStyle(
                                              color: Renk.beyaz,
                                              fontSize: Fonksiyon.ekran.width / 30,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          user.arkadaslar.length.toString(),
                                          style: TextStyle(
                                            color: Renk.gKirmizi,
                                            fontSize: Fonksiyon.ekran.width / 26,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ), */

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: FutureBuilder(
                            future: Firestore.instance
                                .collection('saglik_mutluluk')
                                .where('kisi_id', isEqualTo: user.uid)
                                .getDocuments(),
                            builder: (_, AsyncSnapshot<QuerySnapshot> asq) {
                              if (asq.hasData) {
                                if (asq.data.documents.length > 0) {
                                  List<DocumentSnapshot> docs = asq.data.documents;
                                  double saglik =
                                      (docs.fold(0.0, (prev, elem) => prev + elem.data['saglik']) / docs.length);
                                  double mutluluk =
                                      (docs.fold(0.0, (prev, elem) => prev + elem.data['mutluluk']) / docs.length);
                                  return Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text('Sağlık ortalaması: '),
                                              ),
                                            ),
                                            Stack(
                                              children: <Widget>[
                                                CircularProgressIndicator(
                                                  value: saglik / 10,
                                                  backgroundColor: Renk.gGri19,
                                                ),
                                                Positioned.fill(
                                                  child: Center(
                                                    child: Text(
                                                      "${saglik.toStringAsFixed(1)}",
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text('Mutluluk ortalaması: '),
                                              ),
                                            ),
                                            Stack(
                                              children: <Widget>[
                                                CircularProgressIndicator(
                                                  value: mutluluk / 10,
                                                  backgroundColor: Renk.gGri19,
                                                ),
                                                Positioned.fill(
                                                  child: Center(
                                                    child: Text(
                                                      "${mutluluk.toStringAsFixed(1)}",
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                } else
                                  return SizedBox();
                              }
                              return LinearProgressIndicator();
                            },
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              color: Renk.beyaz,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Renk.gGri, width: 0.5),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            "${user.puan ?? ''}",
                                            style: TextStyle(fontSize: MediaQuery.of(context).size.width / 30),
                                          ),
                                          Container(
                                            child: Text(
                                              'Puan',
                                              style: TextStyle(
                                                  color: Renk.gGri.withOpacity(0.7),
                                                  fontSize: MediaQuery.of(context).size.width / 38),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            "${user.element ?? ''}",
                                            style: TextStyle(fontSize: MediaQuery.of(context).size.width / 30),
                                          ),
                                          Container(
                                            child: Text(
                                              "Seviye",
                                              style: TextStyle(
                                                  color: Renk.gGri.withOpacity(0.7),
                                                  fontSize: MediaQuery.of(context).size.width / 38),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            /*  Container(
                              width: double.maxFinite,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                color: Renk.wpAcik,
                                onPressed: () {
                                  // _veriCek();
                                  profiliGuncelle();
                                },
                                child: _rYukleniyor
                                    ? CircularProgressIndicator(
                                        backgroundColor: Renk.beyaz,
                                      )
                                    : Text(
                                        "Değişiklikleri Kaydet",
                                        style: TextStyle(color: Renk.beyaz),
                                      ),
                              ),
                            ), */

                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8.0),
                                      child: FlatButton(
                                        color: Renk.wpKoyu,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => HikayeEkleGiris()));
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.settings,
                                              color: Renk.beyaz,
                                              size: MediaQuery.of(context).size.width /
                                                  (MediaQuery.of(context).size.width / 18),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              'Hikaye Ayarları',
                                              style: TextStyle(
                                                color: Renk.beyaz,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  /*  FlatButton(
                                    padding: EdgeInsets.all(0),
                                    color: Renk.gGri.withOpacity(0.2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    onPressed: () {},
                                    child: Icon(
                                      FontAwesomeIcons.ellipsisH,
                                      color: Renk.siyah,
                                      size:
                                          MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width / 18),
                                    ),
                                  ), */
                                ],
                              ),
                            ),
                            IntrinsicHeight(child: ArkadaslarWidgets()),
                            SizedBox(height: 12.0),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  Renk.beyaz.withAlpha(22),
                                  BlendMode.screen,
                                ),
                                child: ProfileItem(
                                  ikon: Icons.mail,
                                  yazi: "${user.email}",
                                ),
                              ),
                            ),
                            SizedBox(height: 12.0),

                            /*  InkWell(
                              onTap: () {
                                if (!user.telOnay) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TelDogrula(uye: user),
                                    ),
                                  );
                                }
                              },
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  Renk.beyaz
                                      .withAlpha(user.telOnay ? 22 : 0),
                                  BlendMode.screen,
                                ),
                                child: ProfileItem(
                                  ikon: Icons.phone,
                                  yazi:
                                      "${user.telefon} Onaylı ${user.telOnay ? '' : 'Değil'}",
                                ),
                              ),
                            ),
                            SizedBox(height: 12.0), */

                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              height: 40.0,
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Renk.gGri19,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                                color: Renk.beyaz,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(Icons.nature),
                                  ),
                                  Flexible(
                                    child: FlatButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/alan_sec',
                                        arguments: {
                                          'Fnks': secim,
                                          'secilenler': user.ilgiAlanlari,
                                        },
                                      ),
                                      child: Text(
                                        user.ilgiAlanlari.length > 0
                                            ? "${user.ilgiAlanlari.reversed}"
                                            : "İlgi alanlarınızı seçin",
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Divider(
                              color: Renk.gGri.withOpacity(0.7),
                            ),
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
                                height: 90,
                                width: double.maxFinite,
                                color: Renk.beyaz,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      height: 30,
                                      width: double.maxFinite,
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(right: 10, bottom: 5, top: 5),
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        'Gönderiler',
                                        style: TextStyle(color: Renk.siyah, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          height: 40,
                                          width: 40,
                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(50),
                                              image: DecorationImage(
                                                  image: NetworkImage(Fonksiyon.uye.resim), fit: BoxFit.cover)),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 30,
                                            width: double.maxFinite,
                                            alignment: Alignment.centerLeft,
                                            margin: EdgeInsets.only(right: 10),
                                            padding: EdgeInsets.only(left: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Renk.siyah, width: 1),
                                            ),
                                            child: Text('Yazı paylaş...'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Container(
                              color: Renk.gGri.withOpacity(0.7),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  for (int i = 0; i < _akisVeri.length; i++)
                                    AkisVeriWidget(
                                      veri: _akisVeri[i],
                                      scaffoldKey: _scaffoldKey,
                                    ),
                                  if (_akisVeri.length < 1)
                                    Container(
                                      child: Text('Henuz bişey paylaşılmadı'),
                                    )
                                ],
                              ),
                            ),
                            _islem
                                ? Center(
                                    child: CircularProgressIndicator(backgroundColor: Renk.beyaz),
                                  )
                                : SizedBox(
                                    height: 200,
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
