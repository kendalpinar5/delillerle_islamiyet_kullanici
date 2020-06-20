import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/yeni_grup/yeni_grup_detay.dart';

class OnayBekleyen extends StatefulWidget {
  final String sayfa;

  const OnayBekleyen({Key key, @required this.sayfa}) : super(key: key);
  @override
  _OnayBekleyenState createState() => _OnayBekleyenState();
}

class _OnayBekleyenState extends State<OnayBekleyen> {
  final String tag = "OnayBekleyen";
  final Firestore _db = Firestore.instance;

  String _sayfa;

  Future<List<DocumentSnapshot>> _getEtkinlikler() async {
    QuerySnapshot querySnapshot;
    Query query = _db
        .collection('etkinlikler')
        .where('yeni_tarih', isGreaterThanOrEqualTo: Timestamp.now());

    if (Fonksiyon.uye.rutbe < 30)
      query = _db
          .collection('etkinlikler')
          .where('yeni_tarih', isGreaterThanOrEqualTo: Timestamp.now())
          .where('il', isEqualTo: Fonksiyon.uye.il);

    try {
      querySnapshot = await query.getDocuments();
      return querySnapshot.documents;
    } on PlatformException catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    }
    return null;
  }

  Future<List<DocumentSnapshot>> _getGruplar() async {
    QuerySnapshot querySnapshot;
    Query query = _db.collection('gruplar');
    if (Fonksiyon.uye.rutbe < 30)
      query = _db
          .collection('gruplar')
          .where('seviye', isLessThanOrEqualTo: Fonksiyon.uye.rutbe)
          .where('il', isEqualTo: Fonksiyon.uye.il);
    try {
      querySnapshot = await query.getDocuments();
      return querySnapshot.documents;
    } on PlatformException catch (e) {
      Logger.log(tag, message: "PlatformException catch: ${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "catch: ${e.toString()}");
    }
    return null;
  }

  @override
  void initState() {
    _sayfa = widget.sayfa;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: Text('Onaylama Sayfası')),
          body: Container(
            child: FutureBuilder(
              future: _sayfa == "grup" ? _getGruplar() : _getEtkinlikler(),
              builder: (ctx, AsyncSnapshot<List<DocumentSnapshot>> q) {
                if (q.connectionState == ConnectionState.active) {
                  return LinearProgressIndicator();
                } else if (q.hasData) {
                  if (q.data.length > 0) {
                    List<DocumentSnapshot> veri = q.data;
                    double yukseklik =
                        veri.length * Fonksiyon.ekran.width / 2 + veri.length * 12;

                    String d = _sayfa == "grup" ? 'gruplar' : 'etkinlikler';
                    String onay = _sayfa == "grup" ? 'y_onay' : 'yonay';

                    return Container(
                      height: yukseklik,
                      child: ListView(
                        children: veri.map((document) {
                          bool bekle = false;
                          return ListTile(
                            onTap: () {
                             Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => YeniGrupDetay(
                                          grup: Grup.fromMap(
                                            document.data,
                                            document.documentID,
                                          ),
                                          onaydan: true,
                                        ),
                                      ),
                                    );
                              Logger.log(tag, message: "Elemana Git");
                            },
                            title: Text(document.data['baslik']),
                            trailing: IconButton(
                              onPressed: bekle
                                  ? null
                                  : () async {
                                      bekle = true;
                                      setState(() {});
                                      Logger.log(tag,
                                          message: "Elemanı Onayla 1");
                                      Logger.log(tag,
                                          message:
                                              "Elemanı Onayla ${document?.data[onay]}");
                                      bool dOnay = document.data[onay] ?? false;
                                      document.data[onay] = !dOnay;

                                      await _db
                                          .collection(d)
                                          .document(document.documentID)
                                          .updateData({onay: !dOnay});
                                      bekle = false;
                                      setState(() {});
                                    },
                              icon: bekle
                                  ? Icon(Icons.sync)
                                  : document.data[onay] ?? false
                                      ? Icon(Icons.visibility,
                                          color: Renk.yesil)
                                      : Icon(
                                          Icons.visibility_off,
                                          color: Renk.gKirmizi,
                                        ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text("Onay bekleyen etkinlik bulunmuyor!"),
                    );
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }
}
