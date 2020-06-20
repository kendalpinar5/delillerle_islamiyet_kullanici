import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:delillerleislamiyet/model/med_kitap_model.dart';
import 'package:delillerleislamiyet/sohbetler/sohbet_konulari.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class Sohbetler extends StatefulWidget {
  @override
  _SohbetlerState createState() => _SohbetlerState();
}

class _SohbetlerState extends State<Sohbetler> {
  final Firestore _db = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int gridSayi = 4;
  MediaQueryData queryData;

  Future<List<MedKitaplar>> _makaleGetir() async {
    QuerySnapshot querySnapshot =
        await _db.collection('sohbet_kitaplari').getDocuments();

    return querySnapshot.documents
        .map((d) => MedKitaplar.fromMap(d.data))
        .toList();
  }

  @override
  void initState() {
    super.initState();
  }

  /*  Future _ver() async {
    QuerySnapshot qs =
        await Firestore.instance.collection('sohbet_kitaplari').getDocuments();

    for (DocumentSnapshot ds in qs.documents) {
      await Firestore.instance
          .collection('sohbet_kitaplari')
          .document(ds.documentID)
          .collection('sohbetler')
          .getDocuments()
          .then((onValue) {
        for (DocumentSnapshot ds2 in onValue.documents) {
          Firestore.instance
              .collection('sohbet_kitaplari')
              .document(ds.documentID)
              .collection('sohbetler')
              .document(ds2.documentID)
              .updateData(
                  {'konu_kitap_id': ds.documentID, 'konu_id': ds2.documentID});
        }
      });
    }
  } */

  @override
  void dispose() {
    super.dispose();
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
          'Sohbet Oku/Dinle',
          style: TextStyle(color: Renk.wpKoyu),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<MedKitaplar>>(
        future: _makaleGetir(),
        builder: (_, als) {
          if (als.connectionState == ConnectionState.active)
            return LinearProgressIndicator();
          if (als.hasData) {
            return new GridView.builder(
                itemCount: als.data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.width * 1.8),
                ),
                itemBuilder: (context, i) {
                  return Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SohbetKonulari(
                              gKitap: als.data[i],
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
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        Linkler.medKitap +
                                            als.data[i].kitapResim),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IntrinsicHeight(
                            child: Container(
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
                                      als.data[i].kitapAdi,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                28,
                                        fontWeight: FontWeight.normal,
                                      ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        Text('${als.data[i].konSayisi}'),
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Container(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0),
                                                    child: Text(
                                                      als.data[i].kitapAdi,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0,
                                                          left: 8.0,
                                                          bottom: 5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Container(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 5.0),
                                                            child: Text(
                                                              als.data[i]
                                                                  .kitapAciklama,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              maxLines: 12,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    28,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        height: 150.0,
                                                        width: 100.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            fit:
                                                                BoxFit.fitWidth,
                                                            image: CachedNetworkImageProvider(
                                                                Linkler.medKitap +
                                                                    als.data[i]
                                                                        .kitapResim),
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
          }
          return SizedBox();
        },
      ),
    );
  }
}
