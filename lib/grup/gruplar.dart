import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/grup/grup_olustur.dart';
import 'package:delillerleislamiyet/grup/grup_widget.dart';
import 'package:delillerleislamiyet/pages/onay_bekleyen.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/iller.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class Gruplar extends StatefulWidget {
  @override
  _GruplarState createState() => _GruplarState();
}

class _GruplarState extends State<Gruplar> {
  final String tag = "Gruplar";
  Box _kutu;
  String il = "Türkiye";

  StreamController<List<DocumentSnapshot>> _controller = StreamController<List<DocumentSnapshot>>();

  Future _getGruplar() async {
    List<DocumentSnapshot> getGrups = [];
    if (!_controller.isClosed) _controller.add(getGrups);
    QuerySnapshot querySnapshot;

    try {
      for (String gID in Fonksiyon.uye.gruplar ?? []) {
        DocumentSnapshot ds2 = await Firestore.instance.collection('gruplar').document(gID).get();
        if (!getGrups.map((f) => f.documentID).contains(ds2.documentID)) {
          getGrups.add(ds2);
          if (!_controller.isClosed) _controller.add(getGrups);
        }
      }

      querySnapshot = await Firestore.instance
          .collection('gruplar')
          .where('y_onay', isEqualTo: true)
          .where('seviye', isLessThanOrEqualTo: Fonksiyon.uye.rutbe)
          .where('il', isEqualTo: il)
          .getDocuments();

      for (DocumentSnapshot ds in querySnapshot.documents) {
        if (!getGrups.map((f) => f.documentID).contains(ds.documentID)) {
          if (!getGrups.map((f) => f.documentID).contains(ds.documentID)) {
            getGrups.add(ds);
            if (!_controller.isClosed) _controller.add(getGrups);
          }
        }
      }

      if (il != "Türkiye") {
        querySnapshot = await Firestore.instance
            .collection('gruplar')
            .where('y_onay', isEqualTo: true)
            .where('seviye', isLessThanOrEqualTo: Fonksiyon.uye.rutbe)
            .where('il', isEqualTo: "Türkiye")
            .getDocuments();

        for (DocumentSnapshot ds in querySnapshot.documents) {
          if (!getGrups.map((f) => f.documentID).contains(ds.documentID)) {
            if (!getGrups.map((f) => f.documentID).contains(ds.documentID)) {
              getGrups.add(ds);
              if (!_controller.isClosed) _controller.add(getGrups);
            }
          }
        }
      }
    } on PlatformException catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    }
  }

  _ilFiltrele() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        String secilenIl = "Türkiye";
        return Container(
          child: StatefulBuilder(
            builder: (c, s) {
              return Container(
                height: 40.0,
                child: AlertDialog(
                  title: Text("İl Seçimi Yap"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        for (String ils in IlUlke.ilUlke)
                          ListTile(
                            onTap: () {
                              secilenIl = ils;
                              s(() {});
                            },
                            title: Text(ils),
                            trailing: secilenIl == ils ? Icon(Icons.check) : SizedBox(),
                          ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("İptal"),
                    ),
                    FlatButton(
                      onPressed: () {
                        il = secilenIl;
                        _kutu.put('grupIl', il);
                        _getGruplar();
                        Navigator.pop(context);
                      },
                      child: Text("Tamam"),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  _kontrol() async {
    _kutu = await Hive.openBox('kayitaraci');
    il = _kutu.get('grupIl') ?? "Türkiye";
    _getGruplar();
  }

  @override
  void initState() {
    _kontrol();
    super.initState();
  }

  @override
  void dispose() {
    _controller.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Renk.beyaz,
      body: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<List<DocumentSnapshot>>(
                  stream: _controller.stream,
                  builder: (ctx, q) {
                    if (q.hasData) {
                      List<DocumentSnapshot> veri = q.data;
                      return StaggeredGridView.extentBuilder(
                        maxCrossAxisExtent: Fonksiyon.ekran.width / 4,
                        itemCount: veri.length,
                        itemBuilder: (BuildContext context, int index) {
                          Grup grup = Grup.fromMap(
                            veri[index].data,
                            "${veri[index].documentID}",
                          );

                          return GrupWidget(grup: grup, kutu: _kutu);
                        },
                        staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Fonksiyon.uye.rutbe > -1
          ? PopupMenuButton(
              onSelected: (s) {
                Logger.log(tag, message: "seçilen menü: $s");
                switch (s) {
                  case 0:
                    _ilFiltrele();
                    break;

                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GrupOlustur()),
                    );
                    break;

                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OnayBekleyen(sayfa: "grup"),
                      ),
                    );
                    break;
                }
              },
              child: Card(
                color: Renk.wpKoyu,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.filter_list,
                    color: Renk.beyaz,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              itemBuilder: (_) => <PopupMenuEntry<int>>[
                PopupMenuItem<int>(
                  value: 0,
                  child: Text("İl Seçimi Yap"),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Text("Grup Oluştur"),
                ),
                if (Fonksiyon.uye.rutbe > 20)
                  PopupMenuItem<int>(
                    value: 2,
                    child: Text("Onay Sayfası"),
                  ),
              ],
            )
          : FloatingActionButton(
              onPressed: _ilFiltrele,
              child: Icon(Icons.filter_list),
            ),
    );
  }
}
