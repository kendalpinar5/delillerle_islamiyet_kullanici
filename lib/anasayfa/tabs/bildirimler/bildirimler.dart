import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/model/bildirim.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/profil_ex/profil_ex.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class Bildirimler extends StatefulWidget {
  final Box kutu;

  const Bildirimler({Key key, this.kutu}) : super(key: key);
  @override
  _BildirimlerState createState() => _BildirimlerState();
}

class _BildirimlerState extends State<Bildirimler> {
  final String tag = 'Bildirimler';
  final Firestore _db = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  List<Uye> _uyeler = [];

  List<Bildirim> _bildirimler = [];
  DocumentSnapshot sonDoc;

  bool _islem = false;

  double _sY = 0;
  double _sO = 0;

  bool _gittim = false;

  Future _enCokOkunanAl() async {
    if (!_gittim) setState(() => _islem = true);
    QuerySnapshot qs;
    if (sonDoc == null) {
      qs = await _db
          .collection('bildirimler')
          .where('alici', isEqualTo: Fonksiyon.uye.uid)
          .orderBy('tarih', descending: true)
          .limit(10)
          .getDocuments();
    } else {
      qs = await _db
          .collection('bildirimler')
          .where('alici', isEqualTo: Fonksiyon.uye.uid)
          .orderBy('tarih', descending: true)
          .startAfterDocument(sonDoc)
          .limit(10)
          .getDocuments();
    }

    if (qs.documents.isNotEmpty) sonDoc = qs.documents.last;
    for (DocumentSnapshot ds in qs.documents) {
      await _kCek(ds.data['gonderen']);
      _bildirimler.add(Bildirim.fromMap(ds.data));
    }
    Logger.log(tag, message: _bildirimler.length.toString());
    if (!_gittim) setState(() => _islem = false);
  }

  Future _kCek(String uId) async {
    DocumentSnapshot ds = await _db.collection('uyeler').document(uId).get();

    _uyeler.add(Uye.fromMap(ds.data));
  }

  Future _arkIstekReddet(Bildirim bildirim) async {
    List g = [];

    await Firestore.instance
        .collection('uyeler')
        .document(Fonksiyon.uye.uid)
        .get()
        .then((onValue) {
      g = onValue.data['arkIstekleri'] ?? [];
      if (g.contains(bildirim.gonderen)) {
        g.remove(bildirim.gonderen);
        g.join(', ');
        Firestore.instance
            .collection('uyeler')
            .document(onValue.documentID)
            .updateData({'arkIstekleri': g});
        Fonksiyon.uye.arkIstekleri = g;
      }

      Firestore.instance
          .collection('bildirimler')
          .document(bildirim.id)
          .delete();
    });
    _enCokOkunanAl();
  }

  Future _sil(Bildirim bildirim) async {
    await Firestore.instance
        .collection('bildirimler')
        .document(bildirim.id)
        .delete();

    _bildirimler.remove(bildirim);
    setState(() {});
  }

  Future _arkIstekOnayla(Bildirim bildirim) async {
    List g = [];

    await Firestore.instance
        .collection('uyeler')
        .document(Fonksiyon.uye.uid)
        .get()
        .then((onValue) {
      g = onValue.data['arkIstekleri'] ?? [];
      if (g.contains(bildirim.gonderen)) {
        g.remove(bildirim.gonderen);
        g.join(', ');
        Firestore.instance
            .collection('uyeler')
            .document(onValue.documentID)
            .updateData({'arkIstekleri': g});
        Fonksiyon.uye.arkIstekleri = g;
      }
    });

    List e = [];
    await Firestore.instance
        .collection('uyeler')
        .document(Fonksiyon.uye.uid)
        .get()
        .then((onValue) {
      e = onValue.data['arkadaslar'] ?? [];
      e.add(bildirim.gonderen);

      Firestore.instance
          .collection('uyeler')
          .document(onValue.documentID)
          .updateData({'arkadaslar': e});
      Fonksiyon.uye.arkadaslar = e;
      Firestore.instance
          .collection('bildirimler')
          .document(bildirim.id)
          .delete();
      Firestore.instance
          .collection('uyeler')
          .document(bildirim.gonderen)
          .get()
          .then((onValue) {
        List s = [];
        s = onValue.data['arkadaslar'] ?? [];
        s.add(bildirim.alici);
        Firestore.instance
            .collection('uyeler')
            .document(onValue.documentID)
            .updateData({'arkadaslar': s});

        Fonksiyon.bildirimGonder(
            alici: bildirim.gonderen,
            gonderen: Fonksiyon.uye.uid,
            tur: 'cevap',
            baslik: Fonksiyon.uye.gorunenIsim,
            mesaj: 'Arkadaşlık istegini kabul etti',
            bBaslik: null,
            bMesaj: null,
            jeton: [onValue.data['bildirimjetonu']]);
      });
    });
    _enCokOkunanAl();
  }

  @override
  void initState() {
    _enCokOkunanAl();
    _scrollController.addListener(() {
      _sO = _scrollController.offset;
      _sY = _scrollController.position.maxScrollExtent;

      if (_sO + 220 > _sY && !_islem) _enCokOkunanAl();
    });

    super.initState();
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
      backgroundColor: Renk.gGri12,
      body: _bildirimler != null
          ? SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int i = 0; i < _bildirimler.length; i++)
                        if (_bildirimler[i].tur == 'arkadaslik')
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 2),
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            color: Renk.beyaz,
                            width: double.maxFinite,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: 50,
                                  width: 50,
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Renk.wpAcik, width: 2),
                                    borderRadius: BorderRadius.circular(50),
                                    image: DecorationImage(
                                        image: NetworkImage(_uyeler[i].resim),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        _uyeler[i].gorunenIsim,
                                        style: TextStyle(
                                            color: Renk.siyah,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      child: Text(
                                          'Sana arkadaşlık istegi gönderdi'),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          color: Renk.eKirmizi,
                                          child: Icon(
                                            Icons.delete,
                                            color: Renk.beyaz,
                                          ),
                                          onPressed: () {
                                            _arkIstekReddet(_bildirimler[i]);
                                          }),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          color: Renk.wpAcik,
                                          child: Icon(
                                            Icons.check,
                                            color: Renk.beyaz,
                                          ),
                                          onPressed: () {
                                            _arkIstekOnayla(_bildirimler[i]);
                                          }),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                          )
                        else if (_bildirimler[i].tur == 'gurup_mesaj')
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 2),
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            color: Renk.beyaz,
                            width: double.maxFinite,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topCenter,
                                  height: 30,
                                  width: 30,
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Renk.wpAcik, width: 2),
                                    borderRadius: BorderRadius.circular(50),
                                    image: DecorationImage(
                                        image: NetworkImage(_uyeler[i].resim),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          _bildirimler[i].baslik,
                                          style: TextStyle(
                                              color: Renk.siyah,
                                              fontWeight: FontWeight.normal,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  30),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        child: Text(
                                            'Mesaj: ${_bildirimler[i].aciklama}'),
                                      )
                                    ],
                                  ),
                                ),
                                InkWell(
                                    onTap: () {
                                      _sil(_bildirimler[i]);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Renk.gGri19,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Icon(
                                        Icons.close,
                                        color: Renk.beyaz,
                                      ),
                                    )),
                              ],
                            ),
                          )
                        else if (_bildirimler[i].tur == 'cevap')
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 2),
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            color: Renk.beyaz,
                            width: double.maxFinite,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: 30,
                                  width: 30,
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Renk.gGri, width: 1),
                                    borderRadius: BorderRadius.circular(50),
                                    image: DecorationImage(
                                        image: NetworkImage(_uyeler[i].resim),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          _uyeler[i].gorunenIsim,
                                          style: TextStyle(
                                              color: Renk.siyah,
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  28),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        child: Text(
                                          'Arkadaşlık isteğini kabul etti..',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  30),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      FlatButton(
                                          padding: EdgeInsets.all(0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          color: Renk.wpAcik,
                                          child: Text('Profili gör',
                                              style:
                                                  TextStyle(color: Renk.beyaz)),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => ProfilSyfEx(
                                                          gUye: _uyeler[i],
                                                        )));
                                          }),
                                      Spacer(),
                                      InkWell(
                                          onTap: () {
                                            _sil(_bildirimler[i]);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Renk.gGri19,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Icon(
                                              Icons.close,
                                              color: Renk.beyaz,
                                            ),
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                    ],
                  ),
                  _islem
                      ? Center(
                          child: LinearProgressIndicator(
                              backgroundColor: Renk.beyaz),
                        )
                      : _bildirimler.length > 0
                          ? SizedBox(
                              height: 200,
                            )
                          : Center(
                              child: Container(
                                  margin: EdgeInsets.only(top: 50),
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.check),
                                      Text('Bildirimler Temiz'),
                                    ],
                                  )),
                            )
                ],
              ),
            )
          : LinearProgressIndicator(
              backgroundColor: Renk.wpKoyu,
            ),
    );
  }
}
