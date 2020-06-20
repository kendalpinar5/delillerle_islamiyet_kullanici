import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delillerleislamiyet/forum/konu_ekle.dart';
import 'package:delillerleislamiyet/forum/konu_syf.dart';
import 'package:delillerleislamiyet/model/konu.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class ForumSyf extends StatefulWidget {
  @override
  _ForumSyfState createState() => _ForumSyfState();
}

class _ForumSyfState extends State<ForumSyf> {
  final String tag = "ForumSyf";
  final Firestore _db = Firestore.instance;

  Future<List<Konu>> konulariAl() async {
    QuerySnapshot querySnapshot;
    try {
      querySnapshot = await _db
          .collection('forum')
          .orderBy('sorusayisi', descending: true)
          .getDocuments();

      return querySnapshot.documents
          .map((f) => Konu.fromMap(f.data, f.documentID))
          .toList();
    } on PlatformException catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    }
    return null;
  }

  konuEkle([Konu k]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => ForumKonuEkle(konu: k)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Renk.beyaz,
        title: Text(
          "Munazara Forum",
          style: TextStyle(color: Renk.wpKoyu),
        ),
        centerTitle: true,
        actions: <Widget>[
          if (Fonksiyon.admin())
            IconButton(
              onPressed: konuEkle,
              icon: Icon(Icons.add),
              tooltip: "ekle",
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: FutureBuilder(
            future: konulariAl(),
            builder: (ctx, AsyncSnapshot<List<Konu>> q) {
              if (q.connectionState == ConnectionState.active)
                return LinearProgressIndicator();
              else if (q.hasData) {
                return GridView.builder(
                  itemCount: q.data.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (c, i) {
                    Konu konu = q.data[i];
                    return Stack(
                      children: <Widget>[
                        Container(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          margin: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(konu.resim),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Renk.gGri,
                                spreadRadius: 1.0,
                                blurRadius: 3.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            margin: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Renk.forumRenkleri[i].withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: FlatButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => KonuSyf(konu: konu),
                                ),
                              ),
                              onLongPress: Fonksiyon.admin()
                                  ? () => konuEkle(konu)
                                  : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 8.0),
                                  Row(
                                    children: <Widget>[
                                      Spacer(),
                                      Icon(Icons.message, color: Renk.beyaz),
                                      Text(
                                        "${konu.sorusayisi}",
                                        style: TextStyle(color: Renk.beyaz),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    konu.baslik,
                                    style: TextStyle(
                                      color: Renk.beyaz,
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              20,
                                    ),
                                  ),
                                  SizedBox(
                                      height: 8.0, width: double.maxFinite),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
