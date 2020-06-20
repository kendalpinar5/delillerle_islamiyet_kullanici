import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/gelistirme/hataEkle.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Hatalar extends StatefulWidget {
  @override
  _HatalarState createState() => _HatalarState();
}

class _HatalarState extends State<Hatalar> {
  void _resmiGoster(Widget w) {
    showDialog(
      context: context,
      builder: (ctx) {
        return FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Container(
            width: double.maxFinite,
            child: w,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Firestore.instance
            .collection('gelistirme')
            .document('hata')
            .collection('icerik')
            .where('onay', isEqualTo: true)
            .orderBy('begenme', descending: true)
            .getDocuments(),
        builder: (_, AsyncSnapshot<QuerySnapshot> asq) {
          if (asq.hasData) {
            List<DocumentSnapshot> docs = asq.data.documents;
            if (docs.length > 0)
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Column(
                    children: docs.map((ds) {
                      bool islem = false;
                      return SizedBox(
                        width: double.maxFinite,
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Stack(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        ds.data['baslik'],
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Renk.gKirmizi,
                                      height: 0.5,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(ds.data['aciklama']),
                                    ),
                                    if (ds.data['resimler'].length > 0)
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Wrap(
                                          children: <Widget>[
                                            for (String rsm
                                                in ds.data['resimler'])
                                              InkWell(
                                                onTap: () => _resmiGoster(
                                                  CachedNetworkImage(
                                                      imageUrl: rsm),
                                                ),
                                                child: Container(
                                                  width:
                                                      (Fonksiyon.ekran.width -
                                                              64.0) /
                                                          5,
                                                  height:
                                                      (Fonksiyon.ekran.width -
                                                              64.0) /
                                                          5,
                                                  margin: EdgeInsets.all(4.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: CachedNetworkImage(
                                                      imageUrl: rsm,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    Container(
                                      color: Renk.gKirmizi,
                                      height: 0.5,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "Yayinlayan: ${ds.data['yayinlayan_adi'] ?? '...'}",
                                              style: TextStyle(
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "${ds.data['tarih'] != null ? DateFormat('dd/MM/yyyy HH:mm').format(ds.data['tarih']?.toDate()) : '...'}",
                                            style: TextStyle(fontSize: 10.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      color: Renk.gKirmizi,
                                      height: 0.5,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: StatefulBuilder(
                                        builder: (_, ststate) {
                                          return Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: islem
                                                    ? Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      )
                                                    : OutlineButton.icon(
                                                        highlightedBorderColor:
                                                            Renk.gKirmizi,
                                                        textColor: ds.data[
                                                                    'katilanlar']
                                                                .contains(
                                                                    Fonksiyon
                                                                        .uye
                                                                        .uid)
                                                            ? Renk.gKirmizi
                                                            : Renk.siyah,
                                                        onPressed: () {
                                                          islem = true;
                                                          ststate(() {});
                                                          if (ds.data[
                                                                  'katilanlar']
                                                              .contains(
                                                                  Fonksiyon.uye
                                                                      .uid)) {
                                                            Firestore.instance
                                                                .collection(
                                                                    'gelistirme')
                                                                .document(
                                                                    'hata')
                                                                .collection(
                                                                    'icerik')
                                                                .document(ds
                                                                    .documentID)
                                                                .updateData({
                                                              'katilanlar':
                                                                  FieldValue
                                                                      .arrayRemove(
                                                                [
                                                                  Fonksiyon
                                                                      .uye.uid
                                                                ],
                                                              ),
                                                              'begenme': ds
                                                                      .data[
                                                                          'katilanlar']
                                                                      .length -
                                                                  1,
                                                            }).whenComplete(() {
                                                              islem = false;
                                                              ststate(() {});
                                                              setState(() {});
                                                            });
                                                          } else {
                                                            Firestore.instance
                                                                .collection(
                                                                    'gelistirme')
                                                                .document(
                                                                    'hata')
                                                                .collection(
                                                                    'icerik')
                                                                .document(ds
                                                                    .documentID)
                                                                .updateData({
                                                              'katilanlar':
                                                                  FieldValue
                                                                      .arrayUnion(
                                                                [
                                                                  Fonksiyon
                                                                      .uye.uid
                                                                ],
                                                              ),
                                                              'begenme': ds
                                                                      .data[
                                                                          'katilanlar']
                                                                      .length +
                                                                  1,
                                                            }).whenComplete(() {
                                                              islem = false;
                                                              ststate(() {});
                                                              setState(() {});
                                                            });
                                                          }
                                                        },
                                                        icon: Text(
                                                            "Aynı Hatayı Alıyorum"),
                                                        label: Text(
                                                          "${ds.data['katilanlar'].length}",
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                if (ds.data['durum'] != null &&
                                    ds.data['durum'] == "basarisiz")
                                  Positioned.fill(
                                    child: Container(
                                      color: Renk.gKirmizi.withOpacity(0.4),
                                      child: Center(
                                        child: Text(
                                          "Maalesef İşlem Başarısızlıkla Sonuçlandırıldı",
                                          style: TextStyle(color: Renk.beyaz),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (ds.data['durum'] != null &&
                                    ds.data['durum'] == "basarili")
                                  Positioned.fill(
                                    child: Container(
                                      color: Renk.yesil.withOpacity(0.4),
                                      child: Center(
                                        child: Text(
                                          "İşlem Başarıyla Sonuçlandırıldı",
                                          style: TextStyle(color: Renk.beyaz),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (ds.data['durum'] != null &&
                                    ds.data['durum'] == "bekleme")
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.amber.withOpacity(0.4),
                                      child: Center(
                                        child: Text(
                                          "İşlem Yöneticiler Tarafından Onaylandı.\nÇalışma Başladı.",
                                          style: TextStyle(color: Renk.beyaz),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            else
              return Center(child: Text('Henüz Ekleme Yok'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HataEkle()),
        ),
        label: Text(
          "Hata Bildir",
          style: TextStyle(color: Renk.beyaz),
        ),
        icon: Icon(
          Icons.add,
          color: Renk.beyaz,
        ),
      ),
    );
  }
}
