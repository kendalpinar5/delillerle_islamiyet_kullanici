import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/profil_ex/profil_ex.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class ArkadasListesi extends StatefulWidget {
  @override
  _ArkadasListesiState createState() => _ArkadasListesiState();
}

class _ArkadasListesiState extends State<ArkadasListesi> {
  final Firestore _db = Firestore.instance;
  final ScrollController _scrollController = ScrollController();
  List<Uye> _uyeler = [];

  DocumentSnapshot sonDoc;

  bool _islem = false;

  double _sY = 0;
  double _sO = 0;

  bool _gittim = false;

  Future _arkCek() async {
    _uyeler = [];
    if (!_gittim) setState(() => _islem = true);
    for (int i = 0; i < Fonksiyon.uye.arkadaslar.length; i++) {
      await _kCek(Fonksiyon.uye.arkadaslar[i]);
    }

    if (!_gittim) setState(() => _islem = false);
  }

  Future _kCek(String uId) async {
    DocumentSnapshot ds = await _db.collection('uyeler').document(uId).get();
    _uyeler.add(Uye.fromMap(ds.data));
  }

  Future _arkCikar(Uye uye) async {
    List g = [];

    await Firestore.instance.collection('uyeler').document(uye.uid).get().then((onValue) {
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
      if (b.contains(uye.uid)) {
        b.remove(uye.uid);
        b.join(', ');
        Firestore.instance.collection('uyeler').document(onValue.documentID).updateData({'arkadaslar': b});
        Fonksiyon.uye.arkadaslar = b;
      }
    });

    _uyeler.remove(uye);
    setState(() {});
  }

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

  @override
  void initState() {
    _arkCek();
    _scrollController.addListener(() {
      _sO = _scrollController.offset;
      _sY = _scrollController.position.maxScrollExtent;

      if (_sO + 220 > _sY && !_islem) _arkCek();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Renk.gGri12,
      appBar: AppBar(
        backgroundColor: Renk.beyaz,
        title: Text(
          'Arkadaş Listesi',
          style: TextStyle(color: Renk.wpKoyu),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Renk.wpKoyu,
            ),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _uyeler != null
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
                      for (int i = 0; i < _uyeler.length; i++)
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 2),
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          color: Renk.beyaz,
                          width: double.maxFinite,
                          child: Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      _resimAc(_uyeler[i].resim);
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      margin: EdgeInsets.only(right: 5),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Renk.wpAcik, width: 1),
                                        borderRadius: BorderRadius.circular(20),
                                        image:
                                            DecorationImage(image: NetworkImage(_uyeler[i].resim), fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ProfilSyfEx(
                                                    gUye: _uyeler[i],
                                                  )));
                                    },
                                    child: Container(
                                      child: Text(
                                        _uyeler[i].gorunenIsim,
                                        style: TextStyle(color: Renk.siyah, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Renk.gKirmizi, width: 1),
                                    borderRadius: BorderRadius.circular(50)),
                                margin: EdgeInsets.only(right: 10),
                                child: FlatButton(
                                    padding: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                    child: Icon(
                                      Icons.delete,
                                      color: Renk.gKirmizi,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _arkCikar(_uyeler[i]);
                                    }),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                  _islem
                      ? Center(
                          child: LinearProgressIndicator(backgroundColor: Renk.beyaz),
                        )
                      : _uyeler.length > 0
                          ? SizedBox(
                              height: 200,
                            )
                          : Text('Arkadaşınız yok!!')
                ],
              ),
            )
          : LinearProgressIndicator(
              backgroundColor: Renk.wpKoyu,
            ),
    );
  }
}
