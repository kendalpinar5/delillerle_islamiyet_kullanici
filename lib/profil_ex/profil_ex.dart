import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delillerleislamiyet/uyelik/arkadas_listesi.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/widgets/akis_veri_widget.dart';
import 'package:delillerleislamiyet/model/akis_veri_model.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';

class ProfilSyfEx extends StatefulWidget {
  final Uye gUye;

  const ProfilSyfEx({Key key, this.gUye}) : super(key: key);
  @override
  _ProfilSyfExState createState() => _ProfilSyfExState();
}

class _ProfilSyfExState extends State<ProfilSyfEx> {
  final Firestore _db = Firestore.instance;
  final ScrollController _scrollController = ScrollController();

  final String tag = Yazi.profilSayfasi;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Uye _uye;

  List<AkisVeri> _akisVeri = [];
  DocumentSnapshot sonDoc;

  bool _islem = false;

  double _sY = 0;
  double _sO = 0;
  bool _ark = false;
  bool _istek = false;
  bool gittim = false;

  _resimAc(String resim) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Container(
            color: Renk.siyah,
            //  height: MediaQuery.of(context).size.height - 50,
            child: Image.network(
              resim,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
  /*  _degistir(String s) {
    _editingController.text = user.toMap()[s];
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: TextFormField(
            controller: _editingController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: s,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("İptal"),
            ),
            FlatButton(
              onPressed: () {
                if (s == "referans" && _editingController.text.length != 6) {
                  Fonksiyon.mesajGoster(
                    _scaffoldKey,
                    "Lütfen referans kodunu 6 hane olacak şekilde girin!",
                  );
                } else {
                  Map use = user.toMap();
                  use[s] = _editingController.text;
                  user = Uye.fromMap(use);

                  Logger.log(tag, message: "$user");
                  Navigator.pop(context);
                  if (!_gittim) setState(() {});
                }
              },
              child: Text("Onay"),
            ),
          ],
        );
      },
    );
  } */

  Future _istekAt() async {
    List g = [];
    await Firestore.instance.collection('uyeler').document(_uye.uid).get().then((onValue) {
      g = onValue.data['arkIstekleri'] ?? [];
      if (!g.contains(Fonksiyon.uye.uid)) {
        g.add(Fonksiyon.uye.uid);
        Firestore.instance
            .collection('uyeler')
            .document(onValue.documentID)
            .updateData({'arkIstekleri': g}).then((onValue) {
          Fonksiyon.bildirimGonder(
              bMesaj: '',
              bBaslik: '',
              alici: _uye.uid,
              gonderen: Fonksiyon.uye.uid,
              tur: 'arkadaslik',
              baslik: 'Arkadaşlık isteği',
              mesaj: '${Fonksiyon.uye.gorunenIsim} size arkadaşlık isteği gönderdi..',
              jeton: [_uye.bildirimjetonu]);
        });
      }
    });
    _istek = true;
    setState(() {});
  }

  Future _arkCik() async {
    List g = [];

    await Firestore.instance.collection('uyeler').document(_uye.uid).get().then((onValue) {
      g = onValue.data['arkadaslar'] ?? [];
      if (g.contains(Fonksiyon.uye.uid)) {
        g.remove(Fonksiyon.uye.uid);
        g.join(', ');
        Firestore.instance.collection('uyeler').document(onValue.documentID).updateData({'arkadaslar': g});
      }
    });
    List b = [];
    await Firestore.instance.collection('uyeler').document(Fonksiyon.uye.uid).get().then((onValue) {
      b = onValue.data['arkadaslar'] ?? [];
      if (b.contains(_uye.uid)) {
        b.remove(_uye.uid);
        b.join(', ');
        Firestore.instance.collection('uyeler').document(onValue.documentID).updateData({'arkadaslar': b});
        Fonksiyon.uye.arkadaslar = b;
      }
    });

    _ark = false;
    setState(() {});
  }

  Future _istegiCek() async {
    List g = [];

    await Firestore.instance.collection('uyeler').document(_uye.uid).get().then((onValue) {
      g = onValue.data['arkIstekleri'] ?? [];
      if (g.contains(Fonksiyon.uye.uid)) {
        g.remove(Fonksiyon.uye.uid);
        g.join(', ');
        Firestore.instance.collection('uyeler').document(onValue.documentID).updateData({'arkIstekleri': g});
      }
    });

    await Firestore.instance
        .collection('bildirimler')
        .where('alici', isEqualTo: _uye.uid)
        .where('gonderen', isEqualTo: Fonksiyon.uye.uid)
        .where('tur', isEqualTo: 'arkadaslik')
        .getDocuments()
        .then((onValue) {
      for (DocumentSnapshot ds in onValue.documents) {
        if (ds.exists) {
          Firestore.instance.collection('bildirimler').document(ds.documentID).delete();
          Logger.log(tag, message: 'sildim');
        }
      }
    });

    _istek = false;
    setState(() {});
  }

  Future _istekKontrol() async {
    List g = [];

    await Firestore.instance.collection('uyeler').document(_uye.uid).get().then((onValue) {
      g = onValue.data['arkIstekleri'] ?? [];
      if (g.contains(Fonksiyon.uye.uid)) {
        _istek = true;
        setState(() {});
      }
    });
  }

  Future _arkKontrol() async {
    List g = [];

    await Firestore.instance.collection('uyeler').document(Fonksiyon.uye.uid).get().then((onValue) {
      g = onValue.data['arkadaslar'] ?? [];
      if (g.contains(_uye.uid)) {
        _ark = true;
        setState(() {});
      }
    });
  }

  Future _makaleGetir() async {
    setState(() => _islem = true);
    QuerySnapshot qs;
    if (sonDoc == null)
      qs = await _db
          .collection('akis_verileri')
          .where('ekleyen', isEqualTo: _uye.uid)
          .where('onay', isEqualTo: true)
          .orderBy('tarih', descending: true)
          .limit(5)
          .getDocuments();
    else
      qs = await _db
          .collection('akis_verileri')
          .where('ekleyen', isEqualTo: _uye.uid)
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

  @override
  void initState() {
    _uye = widget.gUye;
    _istekKontrol();
    _arkKontrol();
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
    gittim = true;

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
          body: Center(
            child: _uye == null
                ? CircularProgressIndicator()
                : Container(
                    color: Renk.gGri9,
                    height: double.maxFinite,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: double.maxFinite,
                            color: Renk.wp,
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                children: <Widget>[
                                  ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: 20),
                                    child: Text(
                                      "${_uye.gorunenIsim}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Renk.beyaz,
                                        fontSize: 26.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${_uye.unvan}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Renk.beyaz,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.5, 0.5],
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
                                        _uye.gonderiSayisi.toString(),
                                        style: TextStyle(
                                          color: Renk.gKirmizi,
                                          fontSize: Fonksiyon.ekran.width / 26,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _resimAc(_uye.resim);
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
                                      child: CachedNetworkImage(
                                        imageUrl: _uye.resim,
                                        placeholder: (context, url) => CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
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
                                          _uye.arkadaslar.length.toString(),
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
                              ],
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
                                              "${_uye.puan ?? ''}",
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
                                              "${_uye.element ?? ''}",
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
                              MaterialButton(
                                color: _ark ? Renk.eKirmizi : _istek ? Renk.wpAcik : Renk.wp,
                                onPressed: () {
                                  if (_ark) {
                                    _arkCik();
                                  } else {
                                    if (_istek)
                                      _istegiCek();
                                    else
                                      _istekAt();
                                  }
                                },
                                child: Text(
                                  _ark ? 'Arkadaşlıktan çık' : _istek ? 'İstek Gönderildi' : 'Arkadaşı Ekle',
                                  style: TextStyle(color: Renk.beyaz),
                                ),
                              ),
                              SizedBox(height: 12.0),
                              /*  Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    Renk.beyaz.withAlpha(22),
                                    BlendMode.screen,
                                  ),
                                  child: ProfileItem(
                                    ikon: Icons.mail,
                                    yazi: "${_uye.email}",
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.0), */
                              Container(
                                height: 40.0,
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                margin: EdgeInsets.symmetric(horizontal: 8),
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
                                      child: Container(
                                        child: Text(
                                          _uye.ilgiAlanlari.length > 0
                                              ? "${_uye.ilgiAlanlari.reversed}"
                                              : "İlgi alanları girilmedi",
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12.0),
                              Column(
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
                              _islem
                                  ? Center(
                                      child: CircularProgressIndicator(backgroundColor: Renk.beyaz),
                                    )
                                  : SizedBox(
                                      height: 300,
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
