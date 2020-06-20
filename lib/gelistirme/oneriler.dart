import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/gelistirme/oneriEkle.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:intl/intl.dart';

class Oneriler extends StatefulWidget {
  @override
  _OnerilerState createState() => _OnerilerState();
}

class _OnerilerState extends State<Oneriler> {
  Query _query = Firestore.instance
      .collection('gelistirme')
      .document('oneri')
      .collection('icerik')
      .orderBy('begenme', descending: true);

  final CollectionReference _collectionReference = Firestore.instance
      .collection('gelistirme')
      .document('oneri')
      .collection('icerik');

  @override
  void initState() {
    if (!Fonksiyon.admin()) _query = _query.where('onay', isEqualTo: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _query.getDocuments(),
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
                          child: InkWell(
                            onLongPress: Fonksiyon.admin()
                                ? () {
                                    _collectionReference
                                        .document(ds.documentID)
                                        .updateData({
                                      'durum': "bekleme"
                                    }).whenComplete(() => setState(() {}));
                                  }
                                : null,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Stack(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                OutlineButton.icon(
                                                  highlightedBorderColor:
                                                      Renk.gKirmizi,
                                                  disabledBorderColor:
                                                      Renk.gKirmizi,
                                                  onPressed:
                                                      ds.data['katilmayanlar']
                                                                  .contains(
                                                                      Fonksiyon
                                                                          .uye
                                                                          .uid) ||
                                                              islem
                                                          ? null
                                                          : () {
                                                              islem = true;
                                                              ststate(() {});
                                                              _collectionReference
                                                                  .document(ds
                                                                      .documentID)
                                                                  .updateData({
                                                                'katilmayanlar':
                                                                    FieldValue
                                                                        .arrayUnion(
                                                                  [
                                                                    Fonksiyon
                                                                        .uye.uid
                                                                  ],
                                                                ),
                                                                'katilanlar':
                                                                    FieldValue
                                                                        .arrayRemove(
                                                                  [
                                                                    Fonksiyon
                                                                        .uye.uid
                                                                  ],
                                                                ),
                                                                'begenmeme': ds
                                                                        .data[
                                                                            'katilmayanlar']
                                                                        .length +
                                                                    1,
                                                                'begenme': ds
                                                                        .data[
                                                                            'katilanlar']
                                                                        .contains(Fonksiyon
                                                                            .uye
                                                                            .uid)
                                                                    ? ds.data['katilanlar'].length -
                                                                        1
                                                                    : ds
                                                                        .data[
                                                                            'katilanlar']
                                                                        .length,
                                                              }).whenComplete(
                                                                      () {
                                                                islem = false;
                                                                ststate(() {});
                                                                setState(() {});
                                                              });
                                                            },
                                                  icon: Icon(Icons.thumb_down),
                                                  label: Text("Katılmıyorum"),
                                                ),
                                                Expanded(
                                                  child: islem
                                                      ? Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        )
                                                      : Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            SizedBox(),
                                                            Center(
                                                              child: Text(
                                                                "${ds.data['begenmeme']}",
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 0.5,
                                                              height: 20.0,
                                                              color:
                                                                  Renk.gKirmizi,
                                                            ),
                                                            Center(
                                                                child: Text(
                                                              "${ds.data['begenme']}",
                                                            )),
                                                            SizedBox(),
                                                          ],
                                                        ),
                                                ),
                                                OutlineButton.icon(
                                                  highlightedBorderColor:
                                                      Renk.gKirmizi,
                                                  disabledBorderColor:
                                                      Renk.gKirmizi,
                                                  onPressed: ds.data[
                                                                  'katilanlar']
                                                              .contains(
                                                                  Fonksiyon.uye
                                                                      .uid) ||
                                                          islem
                                                      ? null
                                                      : () {
                                                          islem = true;
                                                          ststate(() {});
                                                          _collectionReference
                                                              .document(
                                                                  ds.documentID)
                                                              .updateData({
                                                            'katilanlar':
                                                                FieldValue
                                                                    .arrayUnion(
                                                              [
                                                                Fonksiyon
                                                                    .uye.uid
                                                              ],
                                                            ),
                                                            'katilmayanlar':
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
                                                                    .length +
                                                                1,
                                                            'begenmeme': ds
                                                                    .data[
                                                                        'katilmayanlar']
                                                                    .contains(
                                                                        Fonksiyon
                                                                            .uye
                                                                            .uid)
                                                                ? ds
                                                                        .data[
                                                                            'katilmayanlar']
                                                                        .length -
                                                                    1
                                                                : ds
                                                                    .data[
                                                                        'katilmayanlar']
                                                                    .length,
                                                          }).whenComplete(() {
                                                            islem = false;
                                                            ststate(() {});
                                                            setState(() {});
                                                          });
                                                        },
                                                  icon: Icon(Icons.thumb_up),
                                                  label: Text("Katılıyorum"),
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
          MaterialPageRoute(builder: (_) => OneriEkle()),
        ),
        label: Text(
          "Fikir Öner",
          style: TextStyle(color: Renk.beyaz),
        ),
        icon: Icon(Icons.add, color: Renk.beyaz),
      ),
    );
  }
}
