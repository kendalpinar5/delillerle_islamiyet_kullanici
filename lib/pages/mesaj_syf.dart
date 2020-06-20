import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/mesaj.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class MesajSyf extends StatefulWidget {
  final Function menum;

  const MesajSyf({Key key, this.menum}) : super(key: key);
  @override
  _MesajSyfState createState() => _MesajSyfState();
}

class _MesajSyfState extends State<MesajSyf> {
  final String tag = "MesajSyf";
  final Firestore _db = Firestore.instance;
  List<DocumentSnapshot> _datalar;
  List<Mesaj> _mesajlar;
  List<Grup> _gruplar;
  bool _dataGeldi = false;

  getMesajlar() async {
    _mesajlar = [];
    _gruplar = [];
    QuerySnapshot querySnapshot;
    try {
      querySnapshot = await _db
          .collection('grup_katilanlar')
          .where('katilimci', isEqualTo: Fonksiyon.uye.uid)
          .getDocuments();
      _datalar = querySnapshot.documents;
      Grup grup;
      for (DocumentSnapshot document in _datalar) {
        String grpID = document.data['grup'];
        Mesaj msj = await getMesaj(grpID);
        Logger.log(tag, message: "${msj?.toMap().toString()}");
        if (msj != null) {
          if (msj.yazan != Fonksiyon.uye.uid) {
            if (!_mesajlar.toString().contains(msj.toMap().toString())) {
              Grup grp = await getGrup(grpID);
              if (grp != grup) {
                grup = grp;
                _mesajlar.add(msj);
                _gruplar.add(grp);
              }
            }
          }
        }
      }
      Logger.log(tag, message: "mesaj sayisi: ${_mesajlar.length}");
      _dataGeldi = true;
      setState(() {});
    } on PlatformException catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    }
  }

  Future<Grup> getGrup(String id) async {
    DocumentSnapshot documentSnapshot;
    try {
      documentSnapshot = await _db.collection('gruplar').document(id).get();
      return Grup.fromMap(documentSnapshot.data, documentSnapshot.documentID);
    } on PlatformException catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    }
    return null;
  }

  Future<Mesaj> getMesaj(String grup) async {
    QuerySnapshot querySnapshot;
    try {
      querySnapshot = await _db
          .collection('grup_mesajlar')
          .where('grupid', isEqualTo: grup)
          .getDocuments();
      return Mesaj.fromMap(
        querySnapshot.documents.reversed.toList()[0].data,
        querySnapshot.documents.reversed.toList()[0].documentID,
      );
    } on PlatformException catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    }
    return null;
  }

  @override
  void initState() {
    getMesajlar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Renk.beyaz,
          ),
          onPressed: widget.menum,
        ),
        title: Text("Son Mesajlar"),
      ),
      body: Container(
        color: Renk.beyaz,
        child: Center(
          child: !_dataGeldi
              ? CircularProgressIndicator()
              : ListView.builder(
                  itemCount: _mesajlar.length,
                  itemBuilder: (ctx, i) {
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/grup_detay',
                          arguments: {"grup": _gruplar[i]},
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Gönderen: ${_mesajlar[i]?.gonderen ?? ''}"),
                              Text("Mesaj: ${_mesajlar[i]?.metin ?? ''}"),
                              Text("Grup: ${_gruplar[i].baslik}"),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
