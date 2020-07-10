import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/akis_detay.dart';
import 'package:delillerleislamiyet/model/akis_veri_model.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';


class AkisBenzerWidget extends StatefulWidget {
  final AkisVeri veri;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AkisBenzerWidget({Key key, this.veri, this.scaffoldKey}) : super(key: key);
  @override
  _AkisBenzerWidgetState createState() => _AkisBenzerWidgetState();
}

class _AkisBenzerWidgetState extends State<AkisBenzerWidget> {
  final String tag = 'AkisBenzerWidget';
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
  Future _kCek() async {
    DocumentSnapshot ds = await _db.collection('uyeler').document(_veri.ekleyen).get();
    _eUye = Uye.fromMap(ds.data);
    if (!_gittim) setState(() {});
  }

  Future veriGuncelle() async {
    await _db.collection('akis_verileri').document(_veri.id).updateData(_veri.toMap());
    setState(() {});
  }

  Future okunma() async {
    _veri.okunma++;

    await _db.collection('akis_verileri').document(_veri.id).updateData(_veri.toMap());
    setState(() {});
  }

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
    return Card(
      child: Container(
        height: 90,
        width: MediaQuery.of(context).size.width - 10,
        color: Colors.white,
        margin: EdgeInsets.only(bottom: 6.0),
        child: InkWell(
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _veri.resim != "" || _veri.resim == null
                  ? Card(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(_veri.resim),
                          ),
                        ),
                      ),
                    )
                  : _eUye == null
                      ? Center(child: CircularProgressIndicator())
                      : Card(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: new BoxDecoration(
                              image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(_eUye.resim),
                              ),
                            ),
                          ),
                        ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _veri.baslik == ''
                        ? Container(
                            height: 0,
                          )
                        : Container(
                            width: double.maxFinite,
                            margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _veri.baslik,
                              textAlign: TextAlign.left,
                              maxLines: 3,
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                    Spacer(),
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
                                    _kategoriler[int.parse(_veri.kategori) - 1]
                                        .values
                                        .toString()
                                        .replaceAll('(', '')
                                        .replaceAll(')', ''),
                                    style: TextStyle(
                                        color: Renk.gGri.withOpacity(0.8), fontStyle: FontStyle.normal, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
