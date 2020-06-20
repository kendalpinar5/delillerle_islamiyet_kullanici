import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';

class GrupDetay extends StatefulWidget {
  @override
  _GrupDetayState createState() => _GrupDetayState();
}

class _GrupDetayState extends State<GrupDetay> {
  final String tag = "GrupDetay";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Grup _grup;
  Uye uye = Fonksiyon.uye;
  Firestore _firestore = Firestore.instance;
  List<DocumentSnapshot> veri = [];
  List<Map> katilanlar = [];
  DocumentSnapshot doc;

  double genislik = Fonksiyon.ekran.width;
  int katilimciSayisi = 0;
  int aktifSayi = 0;
  bool _isleniyor = false;
  bool _kIsleniyor = false;
  bool _katiliyor = false;
  bool _giris = true;
  bool _kuralMi = true;
  bool _dipMi = false;
  bool _katilanGeldi = false;
  bool _gittim = false;
  String docID;

  Future _grubaKatil([String uid]) async {
    _kIsleniyor = true;
    if (!_gittim) setState(() {});

  
      if (int.parse(_grup.katilimcisayisi) < int.parse(_grup.maxkatilimci)) {
        QuerySnapshot qs = await _firestore
            .collection('grup_katilanlar')
            .where('grup', isEqualTo: _grup.id)
            .where('katilimci', isEqualTo: uid ?? uye.uid)
            .getDocuments();
        if (qs.documents.length == 0) {
          final String fileName = Random().nextInt(10000000).toString();
          await _firestore
              .collection('grup_katilanlar')
              .document(fileName)
              .setData({
            "grup": _grup.id,
            "katilimci": uid ?? uye.uid,
          });
          docID = fileName;
          _grup.katilimcisayisi = "${int.parse(_grup.katilimcisayisi) + 1}";
          _firestore
              .collection('gruplar')
              .document(_grup.id)
              .updateData(_grup.toMap());

          Map<String, dynamic> uyeMap = {
            "id": fileName,
            "grup": _grup.id,
            "katilimci": uid ?? uye.uid,
          };

//          await DBProvider.db.birEkleGrupKatilan(uyeMap);

          katilanlar.add(uyeMap);

          if (uid == null) {
            _katiliyor = true;
            Fonksiyon.konuyaAboneOl("grup_${_grup.id}");
          } else {
            await getProfile(uid);
          }
        }
      } else {
        Fonksiyon.mesajGoster(_scaffoldKey, Yazi.sayiBasarisiz);
      }
   
    _kIsleniyor = false;
    if (!_gittim) setState(() {});
  }

  Future _gruptenVazgec([String uid]) async {
    _kIsleniyor = true;
    if (!_gittim) setState(() {});
    String id = uid ?? uye.uid;

    docID = katilanlar
        .where((t) => t['katilimci'] == id)
        .toList()[0]['id']
        .toString();

    if (docID != null) {
      await _firestore.collection('grup_katilanlar').document(docID).delete();
      _grup.katilimcisayisi = "${int.parse(_grup.katilimcisayisi) - 1}";
      await _firestore
          .collection('gruplar')
          .document(_grup.id)
          .updateData(_grup.toMap());

      /* await DBProvider.db.deleteGrupKatilan(
        _grup.id,
        int.parse(_grup.katilimcisayisi),
        docID,
      ); */

      katilanlar.removeWhere((t) => t['katilimci'] == id);

      if (uid == null) {
        _katiliyor = false;
        Fonksiyon.konuAboneCik("grup_${_grup.id}");
      } else {
        veri.removeWhere((t) => t.data['uid'] == uid);
      }
    }
    _kIsleniyor = false;
    if (!_gittim) setState(() {});
  }

  Future _grubaUyeEkle(String uid, bool katil) async {
    _kIsleniyor = true;
    if (!_gittim) setState(() {});

    if (katil)
      _grubaKatil(uid);
    else
      _gruptenVazgec(uid);

    await kullaniciListele();
    _kIsleniyor = false;
    if (!_gittim) setState(() {});
  }

  Future getKullanicilar(int limit) async {
    QuerySnapshot qs = await _firestore
        .collection('grup_katilanlar')
        .where('grup', isEqualTo: _grup.id)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .getDocuments();

    int i = 0;
    for (DocumentSnapshot ds in qs.documents) {
      i++;
      Timestamp tm = ds.data['timestamp'];
      Logger.log(tag, message: "sira: $i tarih: ${tm.toDate()}");
    }

    //await DBProvider.db.insertGrupKatilan(qs.documents);
  }

  Future kontrolEt() async {
    _isleniyor = true;
    if (!_gittim) setState(() {});

    /* if (Fnks.kayitAraci.getBool('tumGrupKatilanlarTabloVar') ?? false) {
      await girisIslem();
    } else {
      await DBProvider.db.crateGrupKatilanlarTable();
      Fnks.kayitAraci.setBool('tumGrupKatilanlarTabloVar', true);
      await girisIslem();
    } */
    _isleniyor = false;
    if (!_gittim) setState(() {});
  }

  Future girisIslem() async {
    int a = int.parse(_grup.katilimcisayisi);
    int b = await kullaniciListele() ?? 0;
    if (a > b) {
      await getKullanicilar(a - b);
    } else if (b > a) {
      //await DBProvider.db.deleteTumGrupKatilan(_grup.id);
      if (a > 0) await getKullanicilar(a);
    }
    await kullaniciListele();
    _katilanGeldi = true;
  }

  Future<int> kullaniciListele() async {
    veri = [];
    //katilanlar = await DBProvider.db.listeleGrupKatilans(_grup.id);

    katilanlar.forEach((f) async {
      if (veri.length == katilanlar.length) {
        _isleniyor = false;
      } else {
        await getProfile(f['katilimci']);
      }
    });
    if (!_gittim) setState(() {});
    return katilanlar.length;
  }

  Future getProfile(String uid) async {
    doc = await _firestore.collection('uyeler').document(uid).get();
    Logger.log(tag, message: "getProfile: $uid, ${doc.data.toString()}");
    if (doc.data != null &&
        !(veri
                .where((test) => test.data['uid'] == doc.data['uid'])
                .toList()
                .length >
            0)) veri.add(doc);
  }

  Future _basla() async {
    final Map args = ModalRoute.of(context).settings.arguments;
    _grup = args['grup'];

    if (Fonksiyon.admin())
      _katiliyor = true;
    else {
      QuerySnapshot docs = await _firestore
          .collection('grup_katilanlar')
          .where('katilimci', isEqualTo: uye.uid)
          .where('grup', isEqualTo: _grup.id)
          .getDocuments();

      if (docs.documents.isNotEmpty) _katiliyor = true;
    }
    if (!_gittim) setState(() {});

    docID = _grup.id;

    kontrolEt();
  }

  Future dahaFazla() async {
    if (aktifSayi < veri.length - 30) {
      aktifSayi += 30;
      if (aktifSayi > veri.length - 30) aktifSayi = veri.length - 30;
      await Future.delayed(Duration(milliseconds: 500));
    }
    _dipMi = false;
    if (!_gittim) setState(() {});
  }

  kullaniciEngelle(String uid) {
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: Text("Kullanıcıyı Engelle"),
          content: Text(
            "Kullanıcıyı bu grubtan engellemek istediğinizden emin misiniz?",
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İptal"),
            ),
            FlatButton(
              onPressed: () async {
                await _gruptenVazgec(uid);
                DateTime zaman = DateTime.now();
                _firestore
                    .collection('grup_engellenenler')
                    .document(zaman.millisecondsSinceEpoch.toString())
                    .setData({'grup': _grup.id, 'uye': uid});
                Logger.log(tag, message: "Kullanıcı engellendi: $uid");
                Navigator.pop(context);
              },
              child: Text("Engelle"),
            )
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_giris) {
      _basla();
      _giris = false;
    }
  }

  @override
  void dispose() {
    _gittim = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_grup.baslik),
        actions: <Widget>[
         /*  if (Fonksiyon.admin() ||
              (Fonksiyon.uye.yeniAdres['adres']
                          [Fonksiyon.uye.yeniAdres['adres'] - 1] ==
                      _grup.il &&
                  Fonksiyon.uye.rutbe > 15 &&
                  _grup.seviye > 10))
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) {
                  return GrupUyeEkle(
                    f: _grubaUyeEkle,
                    k: katilanlar
                        .map((f) => f['katilimci'].toString())
                        .toList(),
                  );
                }));
              },
              icon: Icon(Icons.person_add),
              tooltip: "Gruba Üye Ekle",
            ), */
          if (_katiliyor && !_kIsleniyor)
            IconButton(
              onPressed: _gruptenVazgec,
              icon: Icon(Icons.exit_to_app),
              tooltip: "Gruptan Çık",
            ),
          if (Fonksiyon.admin() || _grup.olusturan == Fonksiyon.uye.uid)
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  "/grup_olustur",
                  arguments: _grup,
                );
              },
              icon: Icon(Icons.edit),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent &&
                !_dipMi) {
              _dipMi = true;
              if (!_gittim) setState(() {});
              dahaFazla();
            }
            return false;
          },
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: genislik / 3,
                        width: genislik,
                        child: CachedNetworkImage(
                          imageUrl: _grup.resim ?? Linkler.grupThumbResim,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (_grup.resim == null)
                        Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "${_grup.il}",
                              style: TextStyle(
                                fontSize: genislik / 20,
                                fontWeight: FontWeight.w500,
                                color: Renk.beyaz,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _grup.baslik.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _grup.anahtarkelimeler,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              color: Renk.siyah,
                              onPressed: () {
                                _kuralMi = true;
                                if (!_gittim) setState(() {});
                              },
                              child: Text(
                                "Kurallar",
                                style: TextStyle(
                                  color: Renk.beyaz,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          SizedBox(width: _katiliyor ? 16.0 : 0),
                          _katiliyor
                              ? Expanded(
                                  child: RaisedButton(
                                    color: Renk.siyah,
                                    onPressed: () {
                                      if (_katilanGeldi &&
                                          _grup.katilimcisayisi != "0")
                                        _kuralMi = false;
                                      if (!_gittim) setState(() {});
                                    },
                                    child: Text(
                                      "Katılımcılar",
                                      style: TextStyle(
                                        color: Renk.beyaz,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16.0,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(width: 16.0),
                          Expanded(
                            flex: _katiliyor ? 1 : 2,
                            child: _kIsleniyor
                                ? Center(child: CircularProgressIndicator())
                                : RaisedButton(
                                    color: Renk.gKirmizi,
                                    onPressed: () {
                                      if (!_katiliyor) {
                                        /* if (_grup.seviye < 10 ||
                                            _grup.il ==
                                                Fonksiyon.uye.yeniAdres['adres']
                                                    [Fonksiyon.uye.yeniAdres[
                                                            'adres'] -
                                                        1])
                                          _grubaKatil();
                                        else {
                                          Fonksiyon.mesajGoster(
                                            _scaffoldKey,
                                            "Yalnızca profilinizdeki ilin grubuna giriş yapabilirsiniz!",
                                          );
                                        } */
                                      } else {
                                       
                                          Navigator.pushNamed(
                                            context,
                                            '/grup_mesajlar',
                                            arguments: {"grup": _grup},
                                          );
                                        
                                      }
                                    },
                                    child: Text(
                                      _katiliyor ? "Mesajlar" : "Gruba Katıl",
                                      style: TextStyle(
                                        color: Renk.beyaz,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16.0,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _kuralMi
                    ? Column(
                        children: <Widget>[
                          for (int i = 0; i < _grup.kurallar.length; i++)
                            ListTile(
                              leading: Text("${i + 1}"),
                              title: Text(_grup.kurallar[i]),
                            ),
                        ],
                      )
                    : _isleniyor
                        ? CircularProgressIndicator()
                        : Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    "${Yazi.katilimciSayi}: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                        fontSize: genislik / 35),
                                  ),
                                  Text(
                                    " ${_grup.katilimcisayisi}",
                                    style: TextStyle(fontSize: genislik / 40),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () async {
                                      _dipMi = true;
                                      if (!_gittim) setState(() {});
                                      /* await DBProvider.db
                                          .deleteTumGrupKatilan(_grup.id); */
                                      await kontrolEt();
                                      await Future.delayed(
                                        Duration(milliseconds: 500),
                                      );
                                      _dipMi = false;
                                      if (!_gittim) setState(() {});
                                    },
                                    icon: Icon(Icons.refresh),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                              if (veri.length > 30)
                                for (int i = 0; i < aktifSayi + 30; i++)
                                  //KullaniciListeOge(user: veri[i]),
                                  if (veri.length < 30)
                                    for (int i = 0; i < veri.length; i++)
                                      /* InkWell(
                                      onLongPress: Fnks.uye.rutbe < 16
                                          ? null
                                          : () {
                                              kullaniciEngelle(veri[i]['uid']);
                                            },
                                      child: KullaniciListeOge(user: veri[i])), */
                                      if (_dipMi)
                                        Center(
                                            child: CircularProgressIndicator()),
                            ],
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
