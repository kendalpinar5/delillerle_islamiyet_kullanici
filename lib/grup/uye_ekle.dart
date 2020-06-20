import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class GrupUyeEkle extends StatefulWidget {
  final Function f;
  final List<String> k;

  const GrupUyeEkle({Key key, this.f, this.k}) : super(key: key);
  @override
  _GrupUyeEkleState createState() => _GrupUyeEkleState();
}

class _GrupUyeEkleState extends State<GrupUyeEkle> {
  final String tag = "GrupUyeEkle";
  final Firestore _db = Firestore.instance;
  Box _kutu;

  List<Uye> _uyeler = [];
  List<Uye> _aramaSql = [];

  List<String> katilanlar;

  bool _islem = false;
  bool _sonucYok = false;
  double yukseklik;

  void filtrele(String ara) {
    _aramaSql = [];
    if (ara.length > 0) {
      _sonucYok = false;
      for (Uye u in _uyeler) {
        String uu = "${u.toMap()}";
        if (uu.toLowerCase().contains(ara.toLowerCase()) ||
            uu.toUpperCase().contains(ara.toUpperCase())) {
          _aramaSql.add(u);
        }
      }
      if (_aramaSql.length == 0) _sonucYok = true;
    } else {
      _sonucYok = false;
      _aramaSql = [];
    }
    setState(() {});
  }

  Future _getKullanicilar([int limit]) async {
    QuerySnapshot querySnapshot;
    DocumentSnapshot ds1;
    try {
      if (limit != null) {
        Uye u1 = Uye.fromMap(_kutu.get(limit));
        ds1 = await _db.collection('uyeler').document(u1.uid).get();

        querySnapshot = await _db
            .collection('uyeler')
            .orderBy('timestamp', descending: true)
            .startAfterDocument(ds1)
            .getDocuments();
      } else {
        querySnapshot = await _db.collection('uyeler').getDocuments();
      }

      Logger.log(tag,
          message: "serverUyeSayisi, ${querySnapshot.documents.length}");
      if (ds1.documentID != querySnapshot.documents.last.documentID)
        for (DocumentSnapshot ds in querySnapshot.documents) {
          Timestamp tsmp = ds.data['timestamp'];
          Uye u = Uye.fromMap(ds.data);
          _kutu.put(tsmp.millisecondsSinceEpoch, u.toMap());
        }
    } on PlatformException catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    } catch (e) {
      Logger.log(tag, message: "${e.toString()}");
    }
  }

  Future _girisIslem() async {
    _islem = true;
    setState(() {});
    _kutu = await Hive.openBox('localUyeler');

    QuerySnapshot qs = await _db
        .collection('uyeler')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .getDocuments();

    Timestamp tsmp = qs.documents[0].data['timestamp'];

    if (_kutu.get(tsmp.millisecondsSinceEpoch) == null) {
      if (_kutu.keys.isEmpty)
        await _getKullanicilar();
      else {
        await _getKullanicilar(_kutu.keys.last);
      }
    }

    _uyeler = _kutu.values
        .map((f) => Uye.fromMap(f))
        .where((test) => test.rutbe < 100)
        .toList();
    _uyeler.sort((a, b) => a.rutbe.compareTo(b.rutbe));

    _islem = false;
    setState(() {});
  }

  @override
  void initState() {
    katilanlar = widget.k ?? [];
    _girisIslem();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Uye> sonuyeler = _aramaSql.length > 0 ? _aramaSql : _uyeler;
    yukseklik =
        sonuyeler.length * Fonksiyon.ekran.width / 2 + sonuyeler.length * 16;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Filtrele',
            hintStyle: TextStyle(color: Renk.beyaz),
          ),
          style: TextStyle(color: Renk.beyaz),
          onChanged: (a) {
            filtrele(a);
          },
        ),
      ),
      body: _islem
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: yukseklik,
              child: _sonucYok
                  ? Center(child: Text("Sonuç Bulunamadı"))
                  : ListView(
                      children: sonuyeler.map((document) {
                        return Column(
                          children: <Widget>[
                            ListTile(
                              leading: ClipOval(
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  child: CachedNetworkImage(
                                    imageUrl: document.resim ??
                                        "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png",
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Container(
                                height: 47,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "${document.gorunenIsim} - ",
                                      style: TextStyle(
                                        color: Renk.gGri,
                                        fontSize: 16.0,
                                      ),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      "tel: ${document.telefon}",
                                      style: TextStyle(
                                        color: Renk.gGri,
                                        fontSize: 12.0,
                                      ),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      "email: ${document.email}",
                                      style: TextStyle(
                                        color: Renk.gGri,
                                        fontSize: 12.0,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  if (katilanlar.contains(document.uid))
                                    katilanlar.remove(document.uid);
                                  else
                                    katilanlar.add(document.uid);

                                  widget.f(
                                    document.uid,
                                    katilanlar.contains(document.uid),
                                  );
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.check,
                                  color: katilanlar.contains(document.uid)
                                      ? Renk.yesil
                                      : Renk.gGri19,
                                ),
                              ),
                            ),
                            Divider(color: Renk.gKirmizi),
                          ],
                        );
                      }).toList(),
                    ),
            ),
    );
  }
}
