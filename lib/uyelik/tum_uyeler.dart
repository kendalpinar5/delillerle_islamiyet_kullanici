import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delillerleislamiyet/model/ham_uye.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/iller.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class TumUyeler extends StatefulWidget {
  final Function menum;

  const TumUyeler({Key key, this.menum}) : super(key: key);
  @override
  _TumUyelerState createState() => _TumUyelerState();
}

class _TumUyelerState extends State<TumUyeler> {
  final String tag = "TumUyeler";
  final Firestore _db = Firestore.instance;

  final List<Map<int, String>> rutbeler = [
    {0: "Normal Kullanıcı"},
    {61: "Türkiye Temsilcisi"},
    {56: "Türkiye Moderatör"},
    {41: "Bölge Temsilcisi"},
    {36: "Bölge Moderatör"},
    {21: "İl Temsilcisi"},
    {16: "İl Moderatör"},
  ];
  Box _kutu;

  List<HamUye> _uyeler = [];

  List<HamUye> _aramaSql = [];
  bool _islem = false;
  bool _sonucYok = false;
  bool _gittim = false;

  String _araEmail = "";

  Future rutbeDegistir(HamUye uyeSql, int rutbe) async {
    int index;
    if (_aramaSql.length > 0) {
      index = _aramaSql.indexOf(uyeSql);

      Logger.log(tag,
          message: "$rutbe ${uyeSql.uid} $index ${_aramaSql[index].uid}");
    } else {
      index = _uyeler.indexOf(uyeSql);
    }

    await _db
        .collection('uyeler')
        .document(uyeSql.uid)
        .updateData({'rutbe': rutbe});

    uyeSql.rutbe = rutbe;

    _kutu.put(uyeSql.uid, uyeSql.toJson());

    if (_aramaSql.length > 0)
      _aramaSql[index] = uyeSql;
    else
      _uyeler[index] = uyeSql;
    if (!_gittim) setState(() {});
  }

  void _aramaYap() async {
    _aramaSql = [];
    if (!_gittim && !_islem) setState(() => _islem = true);
    if (_araEmail.length > 0) {
      _sonucYok = false;
      for (HamUye u in _uyeler) {
        String uu = json.encode(u.toJson());
        if (uu.toLowerCase().contains(_araEmail.toLowerCase()) ||
            uu.toUpperCase().contains(_araEmail.toUpperCase())) {
          _aramaSql.add(u);
        }
      }

      if (_aramaSql.length == 0) {
        QuerySnapshot qs = await _db
            .collection('uyeler')
            .where('email', isEqualTo: _araEmail)
            .getDocuments();

        for (DocumentSnapshot ds in qs.documents) {
          HamUye u = HamUye.fromJson(ds.data);
          _kutu.put(ds.documentID, u.toJson());
        }

        _uyeler = _kutu.values
            .map((f) => HamUye.fromJson(Map<String, dynamic>.from(f)))
            .toList();

        for (HamUye u in _uyeler) {
          String uu = json.encode(u.toJson());
          if (uu.toLowerCase().contains(_araEmail.toLowerCase()) ||
              uu.toUpperCase().contains(_araEmail.toUpperCase()))
            _aramaSql.add(u);
        }
        if (_aramaSql.length == 0) _sonucYok = true;
      }
    } else {
      _sonucYok = false;
      _uyeler = _kutu.values
          .map((f) => HamUye.fromJson(Map<String, dynamic>.from(f)))
          .toList();
    }

    if (!_gittim) setState(() => _islem = false);
  }

  Future _getKullanicilar([String sonElemen]) async {
    QuerySnapshot querySnapshot;

    try {
      querySnapshot = await _db
          .collection('uyeler')
          .orderBy('rutbe', descending: true)
          .limit(50)
          .getDocuments();

      Logger.log(
        tag,
        message: "querySnapshot length: ${querySnapshot.documents.length}",
      );

      Logger.log(tag, message: "_uyeler length: ${_uyeler.length}");

      for (DocumentSnapshot ds in querySnapshot.documents) {
        HamUye u = HamUye.fromJson(ds.data);
        _kutu.put(ds.documentID, u.toJson());
      }

      _uyeler = _kutu.values
          .map((f) => HamUye.fromJson(Map<String, dynamic>.from(f)))
          .toList();
    } on PlatformException catch (e) {
      Logger.log(tag, message: "Hata => PlatformException: ${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "Hata => ${e.toString()}");
    }
  }

  Future _girisIslem() async {
    _islem = true;
    if (!_gittim) setState(() {});
    if (_kutu == null || !_kutu.isOpen)
      _kutu = await Hive.openBox('kullanicilar');

    if (_kutu.keys.isEmpty)
      await _getKullanicilar();
    else {
      _uyeler = _kutu.values
          .map((f) => HamUye.fromJson(Map<String, dynamic>.from(f)))
          .toList();
    }
    _aramaYap();
  }

  _ilFiltrele(HamUye uye) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        String secilenIl = uye.il ?? "Türkiye";
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
                        uye.il = secilenIl;
                        _kutu.put(uye.uid, uye.toJson());
                        _db
                            .collection('uyeler')
                            .document(uye.uid)
                            .updateData({'il': uye.il});
                        _girisIslem();

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
    _girisIslem();
    super.initState();
  }

  @override
  void dispose() {
    _kutu.compact();
    _kutu.close();
    _gittim = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<HamUye> sonuyeler = _aramaSql.length > 0 ? _aramaSql : _uyeler;
    sonuyeler = sonuyeler.where((test) => test.rutbe < 90).toList();
    sonuyeler.sort((a, b) => b.rutbe.compareTo(a.rutbe));

    return Container(
      color: Renk.gKirmizi.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Renk.beyaz,
              ),
              onPressed: widget.menum,
            ),
            title: TextField(
              decoration: InputDecoration(
                hintText: 'Email Adresi',
                hintStyle: TextStyle(color: Renk.beyaz),
              ),
              cursorColor: Renk.beyaz,
              style: TextStyle(color: Renk.beyaz),
              onChanged: (v) => _araEmail = v,
            ),
            actions: <Widget>[
              if (!_islem)
                FlatButton(
                  textColor: Renk.beyaz,
                  onPressed: _aramaYap,
                  child: Text("Bul"),
                ),
              if (_islem)
                Center(
                  child: CircularProgressIndicator(backgroundColor: Renk.beyaz),
                ),
              SizedBox(width: 4.0),
            ],
          ),
          body: _islem && (_kutu == null || _kutu.keys.isEmpty)
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: _sonucYok
                      ? Center(child: Text("Sonuç Bulunamadı"))
                      : Column(
                          children: sonuyeler.take(50).map((document) {
                            String resim = document.resim ?? Linkler.thumbResim;
                            String baslik =
                                "${document.gorunenIsim}${document.il.length > 0 ? ' - ' + document.il : ''}";
                            String uid = document.uid;
                            String rtb;
                            switch (document.rutbe) {
                              case 61:
                                rtb = rutbeler[1].values.first;
                                break;
                              case 56:
                                rtb = rutbeler[2].values.first;
                                break;
                              case 41:
                                rtb = rutbeler[3].values.first;
                                break;
                              case 36:
                                rtb = rutbeler[4].values.first;
                                break;
                              case 21:
                                rtb = rutbeler[5].values.first;
                                break;
                              case 16:
                                rtb = rutbeler[6].values.first;
                                break;
                              default:
                                rtb = rutbeler[0].values.first;
                            }
                            return Column(
                              children: <Widget>[
                                ListTile(
                                  leading: ClipOval(
                                    child: InkWell(
                                      onTap: () => Fonksiyon.resmiGor(
                                        context,
                                        resim,
                                        baslik,
                                      ),
                                      onLongPress: () =>
                                          Fonksiyon.kullaniciEngelle(context, uid),
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        child: CachedNetworkImage(
                                          imageUrl: document.resim ??
                                              Linkler.thumbResim,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Container(
                                    height: 82,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          baslik,
                                          style: TextStyle(
                                            color: Renk.gGri,
                                            fontSize: 16.0,
                                          ),
                                          maxLines: 1,
                                        ),
                                        Text(
                                          "email: ${document.email}",
                                          style: TextStyle(
                                            color: Renk.gGri,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: FlatButton(
                                                onPressed: () =>
                                                    _ilFiltrele(document),
                                                child: Text(
                                                  document.il.length > 0
                                                      ? document.il
                                                      : "İl Seçimi Yap",
                                                ),
                                              ),
                                            ),
                                            DropdownButton(
                                              items: rutbeler.map(
                                                  (Map<int, String> rutbe) {
                                                return DropdownMenuItem(
                                                  value: rutbe,
                                                  child:
                                                      Text(rutbe.values.first),
                                                );
                                              }).toList(),
                                              onChanged: (s) {
                                                rtb = s.values.first;
                                                rutbeDegistir(
                                                  document,
                                                  s.keys.first,
                                                );
                                                Logger.log(
                                                  tag,
                                                  message: s.toString(),
                                                );
                                                if (!_gittim) setState(() {});
                                              },
                                              /* value: rtb, */
                                              hint: Text(
                                                rtb,
                                                style: TextStyle(
                                                    color: Renk.siyah),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(color: Renk.gKirmizi),
                              ],
                            );
                          }).toList(),
                        ),
                ),
        ),
      ),
    );
  }
}
