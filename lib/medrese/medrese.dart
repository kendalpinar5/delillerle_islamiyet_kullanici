import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/medrese/konular/med_kitap_konu.dart';
import 'package:delillerleislamiyet/model/med_kitap_model.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter/rendering.dart';
import 'dart:async';

class MedKitap extends StatefulWidget {
  @override
  _MedKitapState createState() => _MedKitapState();
}

class _MedKitapState extends State<MedKitap> {
  final Firestore _db = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Box _kutu;
  List _kitaplar = [];
  int gridSayi = 4;

  MediaQueryData queryData;
  bool islem = false;

  Future _makaleGetir() async {
    if (Hive.isBoxOpen('medresekitaplari'))
      _kutu = Hive.box('medresekitaplari');
    else
      _kutu = await Hive.openBox('medresekitaplari');

    setState(() => islem = true);

    QuerySnapshot querySnapshot = await _db.collection('medrese_kitaplari').getDocuments();

    for (DocumentSnapshot ds in querySnapshot.documents) {
      _kitaplar.add(ds.data.map((key, value) =>
          key == 'kitap_tarih' ? MapEntry(key, (value as Timestamp).millisecondsSinceEpoch) : MapEntry(key, value)));
    }

    _kutu.put('medresekitaplari', _kitaplar);

    setState(() => islem = false);
  }

  Future<Box> _kutuAc() async {
    if (Hive.isBoxOpen('medrese'))
      _kutu = Hive.box('medrese');
    else
      _kutu = await Hive.openBox('medrese');
    return _kutu;
  }

  @override
  void dispose() {
    _kutu.compact();
    _kutu.close();

    super.dispose();
  }

  @override
  void initState() {
    _makaleGetir();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    if (queryData.size.width <= 320) {
      gridSayi = 3;
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Renk.beyaz,
        title: Text(
          'Medrese Dersleri',
          style: TextStyle(color: Renk.wpKoyu),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _kutuAc(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Logger.log('future içi', message: snapshot.data.get('slaytlar').toString());
            Logger.log('future içi', message: snapshot.data.get('slaytIdler').toString());

            return Center();
          }

          if (snapshot.hasData) {
            return Container(
              child: ValueListenableBuilder(
                  valueListenable: _kutu.listenable(keys: ['medresekitaplari']),
                  builder: (context, box, widget) {
                    List _akisVeri = box.get('medresekitaplari', defaultValue: []);

                    return GridView.builder(
                        itemCount: _akisVeri.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio:
                              MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width * 1.8),
                        ),
                        itemBuilder: (context, i) {
                          MedKitaplar _kit = MedKitaplar.fromMap(_akisVeri[i]
                              .map((k, v) => k == 'kitap_tarih'
                                  ? MapEntry(k, Timestamp.fromMillisecondsSinceEpoch(v))
                                  : MapEntry(k, v))
                              .cast<String, dynamic>());

                          return Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MedKitapKonu(
                                      gKitap: MedKitaplar.fromMap(_akisVeri[i]
                                          .map((k, v) => k == 'kitap_tarih'
                                              ? MapEntry(k, Timestamp.fromMillisecondsSinceEpoch(v))
                                              : MapEntry(k, v))
                                          .cast<String, dynamic>()),
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Card(
                                      margin: EdgeInsets.all(0),
                                      elevation: 10.0,
                                      child: Container(
                                        height: double.maxFinite,
                                        width: double.maxFinite,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: CachedNetworkImageProvider(Linkler.medKitap + _kit.kitapResim)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 45.0,
                                    width: double.maxFinite,
                                    child: Card(
                                      margin: EdgeInsets.all(0),
                                      elevation: 1.0,
                                      child: Container(
                                        alignment: Alignment.center,
                                        color: Renk.beyaz,
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            _kit.kitapAdi,
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.ltr,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontSize: MediaQuery.of(context).size.width / 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Container(
                                      height: 35,
                                      color: Renk.beyaz,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                              child: Container(
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    FontAwesomeIcons.folder,
                                                    size: 20,
                                                  ),
                                                ),
                                                Text('${_kit.konSayisi}'),
                                              ],
                                            ),
                                          )),
                                          Container(
                                            height: double.maxFinite,
                                            color: Colors.grey.shade400,
                                            alignment: Alignment.center,
                                            child: IconButton(
                                              color: Renk.beyaz,
                                              icon: Icon(
                                                FontAwesomeIcons.questionCircle,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                showModalBottomSheet<void>(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Center(
                                                          child: Container(
                                                            width: double.maxFinite,
                                                            color: Renk.wp,
                                                            alignment: Alignment.center,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 10.0),
                                                              child: Text(
                                                                _kit.kitapAdi,
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Renk.beyaz,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: MediaQuery.of(context).size.width / 25,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: Renk.gGri12,
                                                          height: 5,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(right: 8.0, left: 8.0, bottom: 5.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: <Widget>[
                                                              Expanded(
                                                                child: Container(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(5.0),
                                                                    child: Text(
                                                                      _kit.kitapAciklama,
                                                                      textAlign: TextAlign.left,
                                                                      style: TextStyle(
                                                                        color: Colors.black,
                                                                        fontStyle: FontStyle.italic,
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width / 28,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                alignment: Alignment.topCenter,
                                                                height: 150.0,
                                                                width: 100.0,
                                                                decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                    fit: BoxFit.fitWidth,
                                                                    image: CachedNetworkImageProvider(
                                                                        Linkler.medKitap + _kit.kitapResim),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  }),
            );
          }
          return LinearProgressIndicator(
            backgroundColor: Renk.wpAcik,
          );
        },
      ),
    );
  }
}
