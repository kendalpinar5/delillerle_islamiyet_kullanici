import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:delillerleislamiyet/anasayfa/hikayeler/hikaye_ekle_giris.dart';
import 'package:delillerleislamiyet/anasayfa/hikayeler/widgets/hikaye_widget.dart';
import 'package:delillerleislamiyet/animasyon/kaydirma.dart';
import 'package:delillerleislamiyet/model/hikaye_model.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class Hikayeler extends StatefulWidget {
  final List gHikaye;
  final Function hikayeGetir;

  const Hikayeler({Key key, this.gHikaye, this.hikayeGetir}) : super(key: key);
  @override
  _HikayelerState createState() => _HikayelerState();
}

class _HikayelerState extends State<Hikayeler> {
  final String tag = "AkisSayfasi";

  bool _gittim = false;
  final ScrollController _scrollController = ScrollController();
  List _hikayeler = [];
  DocumentSnapshot sonDoc;
  Hikaye hikayem;
  bool _islem = false;

  double _sY = 0;
  double _sO = 0;

  _hikaye() {
    _islem = true;
    if (!_gittim) setState(() {});
    widget.hikayeGetir();
    _islem = false;
    setState(() {});
  }

  @override
  void initState() {
    _hikayeler = widget.gHikaye;
    _scrollController.addListener(() {
      _sO = _scrollController.offset;
      _sY = _scrollController.position.maxScrollExtent;

      if (_sO + 100 > _sY && !_islem) {
        _hikaye();
      }
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: Renk.beyaz,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HikayeEkleGiris(),
                ),
              ),
              child: Container(
                  height: MediaQuery.of(context).size.height / 4,
                  width: MediaQuery.of(context).size.width / 3.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: NetworkImage(
                          Fonksiyon.uye.resim,
                        ),
                        fit: BoxFit.cover),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: Renk.beyaz,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.plus,
                              color: Renk.wpKoyu,
                              size: 18,
                            ),
                            onPressed: () {}),
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          width: double.maxFinite,
                          alignment: Alignment.bottomCenter,
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Text(
                            'Hikayene Ekleme Yap',
                            style: TextStyle(color: Renk.beyaz, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 0; i < _hikayeler.length; i++)
                  FadeAnimation(
                    1,
                    HikayeWidget(
                      gHik: Hikaye.fromMap(_hikayeler[i]
                          .map((k, v) =>
                              k == 'tarih' ? MapEntry(k, Timestamp.fromMillisecondsSinceEpoch(v)) : MapEntry(k, v))
                          .cast<String, dynamic>()),
                    ),
                  ),
              ],
            ),
            _islem
                ? Center(
                    child: CircularProgressIndicator(backgroundColor: Renk.beyaz),
                  )
                : SizedBox(
                    width: 100,
                  )
          ],
        ),
      ),
    );
  }
}
