import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:delillerleislamiyet/model/med_kitap_model.dart';
import 'package:delillerleislamiyet/model/soh_konu_model.dart';
import 'package:delillerleislamiyet/sohbetler/sohbet_konu_detay.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:intl/intl.dart';

class SohbetKonulari extends StatefulWidget {
  final MedKitaplar gKitap;
  SohbetKonulari({this.gKitap});

  @override
  _SohbetKonulariState createState() => _SohbetKonulariState();
}

class _SohbetKonulariState extends State<SohbetKonulari> {
  final Firestore _db = Firestore.instance;

  Future<List<SohKonular>> _konulariAl() async {
    QuerySnapshot querySnapshot = await _db
        .collection('sohbet_kitaplari')
        .document(widget.gKitap.kitapId)
        .collection('sohbetler')
        .orderBy('konu_tarih', descending: true)
        .getDocuments();

    return querySnapshot.documents
        .map((d) => SohKonular.fromMap(d.data))
        .toList();
  }

  Future okunma(String kId) async {
    await _db
        .collection('sohbet_kitaplari')
        .document(widget.gKitap.kitapId)
        .collection('sohbetler')
        .document(kId)
        .get()
        .then((onValue) {
      _db
          .collection('sohbet_kitaplari')
          .document(widget.gKitap.kitapId)
          .collection('sohbetler')
          .document(kId)
          .updateData({'okunma': onValue.data['okunma'] + 1});
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Renk.beyaz,
        title: Text(
          widget.gKitap.kitapAdi,
          style: TextStyle(color: Renk.wpKoyu),
          maxLines: 1,
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Renk.wpKoyu,
            ),
            onPressed: () => Navigator.pop(context)),
        elevation: 4.0,
      ),
      body: FutureBuilder<List<SohKonular>>(
          future: _konulariAl(),
          builder: (_, als) {
            if (als.connectionState == ConnectionState.active)
              return LinearProgressIndicator();
            if (als.hasData) {
              if (als.data.length < 1)
                return Center(
                    child: Container(
                  child: Text('Henüz konu eklenmedi!!!'),
                ));

              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < als.data.length; i++)
                      Container(
                        child: InkWell(
                          onTap: () {
                            okunma(als.data[i].konuId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SohKonuDetay(
                                  gKonu: als.data[i],
                                  gKonuResim: widget.gKitap.kitapResim,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 6.0,
                            child: Container(
                              height: 98.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 70.0,
                                    alignment: Alignment.center,
                                    child: CachedNetworkImage(
                                      height: double.maxFinite,
                                      fit: BoxFit.cover,
                                      imageUrl: Linkler.medKitap +
                                          widget.gKitap.kitapResim,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Container(
                                          height: 30.0,
                                          width: double.maxFinite,
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.only(top: 2.0),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              als.data[i].konuBaslik,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                        als.data[i].konuAciklama == ''
                                            ? Spacer()
                                            : Container(
                                                height: 43.0,
                                                width: double.maxFinite,
                                                alignment: Alignment.center,
                                                margin: EdgeInsets.only(
                                                    left: 5.0, right: 5.0),
                                                child: Text(
                                                  als.data[i].konuAciklama,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black87,
                                                    fontStyle: FontStyle.normal,
                                                  ),
                                                ),
                                              ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 3.0),
                                              child: Icon(
                                                Icons.date_range,
                                                size: 14.0,
                                              ),
                                            ),
                                            Container(
                                              height: 20.0,
                                              alignment: Alignment.centerLeft,
                                              margin:
                                                  EdgeInsets.only(left: 3.0),
                                              child: Text(
                                                DateFormat('dd MMM yyyy')
                                                    .format(als
                                                        .data[i].konuTarih
                                                        .toDate())
                                                    .toString(),
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5.0, right: 5.0),
                                                    child: Icon(
                                                      FontAwesomeIcons.eye,
                                                      size: 14.0,
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 20.0,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    margin: EdgeInsets.only(
                                                        left: 3.0, right: 5.0),
                                                    child: Text(
                                                      als.data[i].okunma
                                                          .toString(),
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.black54,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                        ),
                      )
                  ],
                ),
              );
            }

            return LinearProgressIndicator(
              backgroundColor: Renk.wpKoyu,
            );
          }),
    );
  }
}
