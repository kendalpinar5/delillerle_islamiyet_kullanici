import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/profil_ex/profil_ex.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/uyelik/arkadas_listesi.dart';
import 'package:flutter/material.dart';

class ArkadaslarWidgets extends StatefulWidget {
  @override
  _ArkadaslarWidgetsState createState() => _ArkadaslarWidgetsState();
}

class _ArkadaslarWidgetsState extends State<ArkadaslarWidgets> {
  final String tag = 'ArkadaslarWidgets';
  StreamController<List<Uye>> _controller = StreamController<List<Uye>>();
  bool _gittim = false;

  List<Uye> _arklar = [];
  final Firestore _db = Firestore.instance;
  Future _arkCek() async {
    for (String uID in Fonksiyon.uye.arkadaslar) {
      DocumentSnapshot ds = await _db.collection('uyeler').document(uID).get();
      if (ds.exists) {
        _arklar.add(Uye.fromMap(ds.data));
        _controller.add(_arklar);
      }
    }

    if (!_gittim) setState(() {});
  }
  /* Future _arkCek() async {
    _arklar = [];
    Logger.log('_arklar', message: Fonksiyon.uye.arkadaslar.length.toString());

    Fonksiyon.uye.arkadaslar.forEach((element) async {
      Logger.log('_arklar', message: element.toString());
      await _kCek(element).then((value) {
        Logger.log('ark ustu', message: value.gorunenIsim);
        _arklar.add(value);
      });
    });
    setState(() {});
    /*  await _db.collection('uyeler').document(Fonksiyon.uye.uid).get().then((value) {
      List<dynamic> gArk = [];

      gArk = value.data['arkadaslar'];
      gArk.forEach((element) async {
        Logger.log(tag, message: element);
       
      });
    });

    */

    Logger.log('_arklar', message: _arklar.length.toString());
  }

  Future<Uye> _kCek(String id) async {
    DocumentSnapshot ds = await _db.collection('uyeler').document(id).get();

    Uye aU = Uye.fromMap(ds.data);
    return aU;
  } */

  @override
  void initState() {
    _arkCek();

    super.initState();
  }

  @override
  void dispose() {
    _gittim = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _controller.stream,
      builder: (c, AsyncSnapshot<List<Uye>> s) {
        if (s.hasData)
          return Column(
            children: <Widget>[
              Container(
                height: 200,
                margin: EdgeInsets.only(left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Arkadaşlar',
                      style: TextStyle(
                        color: Renk.siyah,
                        fontSize: MediaQuery.of(context).size.width / 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(_arklar.length.toString() + ' arkadaş'),
                    Expanded(
                      child: GridView.count(
                        scrollDirection: Axis.vertical,
                        crossAxisCount: 3,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: 0.8,
                        children: <Widget>[
                          for (Uye u in s.data)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ProfilSyfEx(
                                              gUye: u,
                                            )));
                              },
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  alignment: Alignment.bottomLeft,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(image: NetworkImage(u.resim), fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20)),
                                      gradient: new LinearGradient(
                                          colors: [
                                            Renk.siyah,
                                            Renk.gGri12,
                                          ],
                                          begin: const FractionalOffset(0.0, 0.0),
                                          end: const FractionalOffset(1.0, 0.0),
                                          stops: [0.0, 1.0],
                                          tileMode: TileMode.clamp),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        u.gorunenIsim,
                                        style: TextStyle(
                                          color: Renk.beyaz,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: FlatButton(
                  shape: RoundedRectangleBorder(side: BorderSide(color: Renk.gGri, width: 0.5)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArkadasListesi())),
                  color: Renk.gGri12,
                  child: Container(
                    width: double.maxFinite,
                    alignment: Alignment.center,
                    child: Text(
                      'Tümünü Gör',
                      style: TextStyle(color: Renk.siyah),
                    ),
                  ),
                ),
              )
            ],
          );

        return Container(
          child: Text('Beğenilen ürün yok!!'),
        );
      },
    );
  }
}
