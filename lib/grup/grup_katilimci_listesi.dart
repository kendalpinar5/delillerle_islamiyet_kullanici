import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';

class GrupKatilimciListesi extends StatefulWidget {
  final Grup grup;

  const GrupKatilimciListesi({Key key, this.grup}) : super(key: key);

  @override
  _GrupKatilimciListesiState createState() => _GrupKatilimciListesiState();
}

class _GrupKatilimciListesiState extends State<GrupKatilimciListesi> {
  final String tag = "GrupKatilimciListesi";

  int katilimciSayisi = 0;
  bool _isleniyor = false;

  List<DocumentSnapshot> veri = [];
  Grup grup;
  DocumentSnapshot doc;

  Future getUsers() async {
    veri = [];
    _isleniyor = true;
    setState(() {});
    QuerySnapshot qs = await Firestore.instance
        .collection('grup_katilanlar')
        .where('grup', isEqualTo: grup.id)
        .getDocuments();

    katilimciSayisi = qs.documents.length;

    qs.documents.forEach((f) {
      getProfile(f.data['katilimci']).whenComplete(() {
        if (veri.length == katilimciSayisi) {
          _isleniyor = false;
          setState(() {});
        }
      });
    });
  }

  Future getProfile(String uid) async {
    doc =
        await Firestore.instance.collection('uyeler').document(uid).get();
    Logger.log(tag, message: "firestore cevabı: ${doc.data}");
    veri.add(doc);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    grup = widget.grup;
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    final double genislik = Fonksiyon.ekran.width;
    return Scaffold(
      backgroundColor: Renk.gGri12,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              height: genislik / 4,
              color: Renk.gGri12,
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Container(
                    height: genislik / 4,
                    width: genislik / 4,
                    child: CachedNetworkImage(
                      imageUrl: grup.resim ?? Linkler.thumbResim,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: double.maxFinite,
                            child: Text(
                              grup.baslik.toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: genislik / 28,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "${Yazi.katilimciSayi}: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                    fontSize: genislik / 35),
                              ),
                              Text(
                                " ${grup.katilimcisayisi}",
                                style: TextStyle(fontSize: genislik / 40),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _isleniyor
                ? CircularProgressIndicator()
                : SingleChildScrollView(
                    child: Column(
                      children: veri.map((user) {
                        return Card(
                          child: Container(
                            width: genislik,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Row(
                                children: <Widget>[
                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Renk.beyaz,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Renk.gGri19,
                                            blurRadius: 5.0,
                                          ),
                                        ],
                                        shape: BoxShape.circle,
                                      ),
                                      height: 50,
                                      width: 50,
                                      padding: EdgeInsets.all(5),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: user['resim'] ??
                                              "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png",
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 30),
                                  Text(
                                    "${user['isim']} ${user['soyisim']}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Spacer(flex: 2),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
