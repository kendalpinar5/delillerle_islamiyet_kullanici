import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/medrese/konular/med_konu_detay.dart';
import 'package:delillerleislamiyet/model/med_konu_model.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class MedKonuBenzerWidget extends StatefulWidget {
  final MedKonular veri;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String gKonuResim;

  const MedKonuBenzerWidget(
      {Key key, this.veri, this.scaffoldKey, this.gKonuResim})
      : super(key: key);
  @override
  _MedKonuBenzerWidgetState createState() => _MedKonuBenzerWidgetState();
}

class _MedKonuBenzerWidgetState extends State<MedKonuBenzerWidget> {
  final String tag = 'MedKonuBenzerWidget';
  final Firestore _db = Firestore.instance;
  MedKonular _veri;

  Future okunma() async {
    _veri.okunma++;

    await _db
        .collection('medrese_kitaplari')
        .document(widget.veri.konuKitapId)
        .collection('konular')
        .document(widget.veri.konuId)
        .updateData(_veri.toMap());
    setState(() {});
  }

  @override
  void initState() {
    _veri = widget.veri;

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
                builder: (context) => MedKonuDetay(
                  gKonu: _veri,
                  gKonuResim: widget.gKonuResim,
                ),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Card(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        Linkler.medKitap + widget.gKonuResim,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.maxFinite,
                      margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _veri.konuBaslik,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
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
                                        color: Renk.gGri.withOpacity(0.8),
                                        fontStyle: FontStyle.normal,
                                        fontSize: 13),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  child: Text(
                                    'görüntülenme',
                                    style: TextStyle(
                                        color: Renk.gGri.withOpacity(0.8),
                                        fontStyle: FontStyle.normal,
                                        fontSize: 12),
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
                                    "${Fonksiyon.zamanFarkiBul(_veri.konuTarih.toDate())} önce",
                                    style: TextStyle(
                                        color: Renk.gGri.withOpacity(0.8),
                                        fontStyle: FontStyle.normal,
                                        fontSize: 12),
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
