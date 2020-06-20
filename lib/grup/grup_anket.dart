import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/mesaj.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class GrupAnket extends StatefulWidget {
  final Mesaj mesaj;
  final Function f;

  const GrupAnket({Key key, @required this.mesaj, this.f}) : super(key: key);
  @override
  _GrupAnketState createState() => _GrupAnketState();
}

class _GrupAnketState extends State<GrupAnket> {
  final String tag = "GrupAnket";
  List _anket;
  bool _tamam = false;
  bool _gittim = false;

  oyVer(int i) async {
    _anket[0]['oy_sayisi']++;
    _anket[i]['oy_sayisi']++;

    await Firestore.instance
        .collection('gruplar')
        .document(widget.mesaj.grupid)
        .collection('mesajlar')
        .document(widget.mesaj.id)
        .updateData({
      'anket': _anket,
      'oy_verenler': FieldValue.arrayUnion([Fonksiyon.uye.uid])
    });

    _tamam = true;
    if (!_gittim) setState(() {});
    Logger.log(tag, message: "tamam: $_tamam");
  }

  @override
  void initState() {
    super.initState();
    _anket = widget.mesaj.anket;
    _tamam = widget.mesaj.oyVerenler.contains(Fonksiyon.uye.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 3),
        Text(
          "${_anket[0]['soru']}",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 3),
        Text(
          "Anonim Anket",
          style: TextStyle(fontSize: 12.0, color: Renk.siyah.withAlpha(100)),
        ),
        SizedBox(height: 3),
        if (_tamam)
          for (int i = 1; i < _anket.length; i++)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 41.0,
                    height: 41.0,
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${(100 * _anket[i]['oy_sayisi'] / _anket[0]['oy_sayisi']).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${_anket[i]['secenek']}"),
                        SizedBox(height: 3),
                        FractionallySizedBox(
                          widthFactor: (0.98 *
                                  _anket[i]['oy_sayisi'] /
                                  _anket[0]['oy_sayisi']) +
                              0.02,
                          child: Card(
                            margin: EdgeInsets.symmetric(horizontal: 0.0),
                            color: Renk.yesil,
                            child: Container(height: 5.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
        else
          for (int i = 1; i < _anket.length; i++)
            InkWell(
              onTap: () => oyVer(i),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 0.2)),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 40.0,
                      height: 40.0,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.5, color: Renk.yesil),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: Center(),
                      ),
                    ),
                    SizedBox(width: 4.0),
                    Expanded(child: Text("${_anket[i]['secenek']}")),
                  ],
                ),
              ),
            )
      ],
    );
  }
}
