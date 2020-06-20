//import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class AlanSec extends StatefulWidget {
  @override
  _AlanSecState createState() => _AlanSecState();
}

class _AlanSecState extends State<AlanSec> {
  final String tag = "AlanSec";
  Function secim;

  List secilenler = [];
  bool _bas = true;

  Future<List<String>> alanlariAl() async {
    //  QuerySnapshot querySnapshot;
    try {
      //    querySnapshot = await Firestore.instance.collection('ilgi_alanlari').getDocuments();
      return ['Akaid', 'Tefsir', 'Fıkıh', 'Hadis', 'Tecvid / Talim', 'Tasavvuf', 'Reddiyeler', 'Genel'];
    } on PlatformException catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    }
    return null;
  }

  @override
  void didChangeDependencies() {
    if (_bas) {
      final Map args = ModalRoute.of(context).settings.arguments;
      secim = args['Fnks'];
      for (String ss in args['secilenler']) {
        secilenler.add(ss.trim());
      }
      _bas = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("İlgi Alanlar Seçimi"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  secim(secilenler);
                  Navigator.pop(context);
                },
                child: Text(
                  "Tamam",
                  style: TextStyle(color: Renk.beyaz),
                ),
              ),
            ],
          ),
          body: Center(
            child: FutureBuilder(
              future: alanlariAl(),
              builder: (ctx, AsyncSnapshot<List<String>> q) {
                if (q.connectionState == ConnectionState.active) {
                  return LinearProgressIndicator();
                } else if (q.hasData) {
                  List<String> veri = q.data;
                  return ListView.builder(
                    itemCount: veri.length,
                    itemBuilder: (c, i) {
                      return InkWell(
                        onTap: () {
                          if (secilenler.contains(veri[i]))
                            secilenler.remove(veri[i]);
                          else
                            secilenler.add(veri[i]);
                          setState(() {});
                        },
                        child: Card(
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            child: Text(
                              veri[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          color: secilenler.contains(veri[i]) ? Renk.yesil2 : Renk.gGri12,
                        ),
                      );
                    },
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ),
      ),
    );
  }
}
