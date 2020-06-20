import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/model/akis_veri_yorum.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class AkisYorumWidget extends StatefulWidget {
  final AkisVeriYorum yorum;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function begen;

  const AkisYorumWidget({Key key, this.yorum, this.scaffoldKey, this.begen})
      : super(key: key);
  @override
  _AkisYorumWidgetState createState() => _AkisYorumWidgetState();
}

class _AkisYorumWidgetState extends State<AkisYorumWidget> {
  final Firestore _db = Firestore.instance;
  AkisVeriYorum yorum;
  Uye _yUye;
  bool _gittim = false;

  Future _yUyeCek() async {
    DocumentSnapshot ds =
        await _db.collection('uyeler').document(yorum.ekleyen).get();
    _yUye = Uye.fromMap(ds.data);

    if (!_gittim) setState(() {});
  }

  @override
  void dispose() {
    _gittim = true;

    super.dispose();
  }

  @override
  void initState() {
    yorum = widget.yorum;
    _yUyeCek();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: double.maxFinite,
        decoration: BoxDecoration(
            border: Border.all(color: Renk.gGri.withOpacity(0.6), width: 1),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _yUye == null
                    ? Center(child: CircularProgressIndicator())
                    : new Container(
                        margin: EdgeInsets.all(8.0),
                        width: 25.0,
                        height: 25.0,
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: _yUye.resim == null
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : NetworkImage(_yUye.resim),
                          ),
                        ),
                      ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _yUye == null
                          ? Center(
                              child: LinearProgressIndicator(
                              backgroundColor: Renk.wp,
                            ))
                          : Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _yUye.gorunenIsim == ""
                                    ? "isimsiz kullanıcı"
                                    : _yUye.gorunenIsim,
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 5.0, top: 3.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${Fonksiyon.zamanFarkiBul(yorum.tarih.toDate())} önce",
                    style: TextStyle(
                        color: Renk.gGri,
                        fontStyle: FontStyle.normal,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            Container(
              margin:
                  EdgeInsets.only(left: 10.0, top: 3.0, bottom: 10, right: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                yorum.cevap,
                style: TextStyle(
                    color: Renk.siyah,
                    fontStyle: FontStyle.normal,
                    fontSize: 14),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  onPressed: widget.begen != null
                      ? () {
                          widget.begen(yorum, true);

                          setState(() {});
                        }
                      : null,
                  icon: Icon(
                    Icons.thumb_up,
                    size: 18,
                    color: Fonksiyon.begenYorum.contains(yorum.id)
                        ? Renk.wpAcik
                        : Renk.gGri,
                  ),
                ),
                Text("${yorum.begenme}"),
                SizedBox(width: 12.0),
                IconButton(
                  onPressed: widget.begen != null
                      ? () {
                          widget.begen(yorum, false);
                          setState(() {});
                        }
                      : null,
                  icon: Icon(
                    Icons.thumb_down,
                    size: 18,
                    color: Fonksiyon.begenmeYorum.contains(yorum.id)
                        ? Renk.wpAcik
                        : Renk.gGri,
                  ),
                ),
                Text("${yorum.begenmeme}"),
                SizedBox(width: 12.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
