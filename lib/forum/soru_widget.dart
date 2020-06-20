import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/model/soru.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class SoruWidget extends StatefulWidget {
  final Soru soru;
  final Function fonk;
  final Function begen;

  const SoruWidget({
    Key key,
    @required this.soru,
    @required this.fonk,
    this.begen,
  }) : super(key: key);

  @override
  _SoruWidgetState createState() => _SoruWidgetState();
}

class _SoruWidgetState extends State<SoruWidget> {
  bool _gittim = false;

  @override
  void dispose() {
    _gittim = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            FutureBuilder(
              future: widget.fonk(widget.soru.ekleyen),
              builder: (ct, AsyncSnapshot<Map> m) {
                if (m.hasData) {
                  Uye uye = Uye.fromMap(m.data);
                  return Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            height: 30.0,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: uye.resim ?? Linkler.thumbResim,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text("${uye.gorunenIsim}", maxLines: 1),
                          ),
                          Text(
                            "${Fonksiyon.zamanFarkiBul(widget.soru.tarih.toDate())} önce",
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return CircularProgressIndicator();
              },
            ),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.soru.baslik,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.soru.aciklama),
            ),
            SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(Icons.message),
                Text("${widget.soru.cevapsayisi}"),
                Spacer(),
                if (Fonksiyon.admin() ||
                    widget.soru.ekleyen == Fonksiyon.uye.uid)
                  FlatButton(
                    textColor: Renk.gKirmizi,
                    onPressed: () {
                      Firestore.instance
                          .collection('forum')
                          .document(widget.soru.konuId)
                          .collection('sorular')
                          .document(widget.soru.id)
                          .delete()
                          .whenComplete(() {
                        Fluttertoast.showToast(
                            msg:
                                "Soru başarıyla silindi. Sayfaya tekrar geldiğinizde soruyu görmeyeceksiniz. :)");
                        if (!_gittim) setState(() {});
                      });
                    },
                    child: Text('Soruyu Sil'),
                  ),
                if (widget.soru.ekleyen != Fonksiyon.uye.uid &&
                    !Fonksiyon.admin())
                  FlatButton(
                    textColor: Renk.gKirmizi,
                    onPressed: () {
                      Firestore.instance
                          .collection('forum')
                          .document(widget.soru.konuId)
                          .collection('sorular')
                          .document(widget.soru.id)
                          .updateData({
                        'sikayetler': FieldValue.arrayUnion([Fonksiyon.uye.uid])
                      }).whenComplete(() {
                        Fluttertoast.showToast(
                            msg:
                                "Şikayetiniz yetkililer tarafından değerlendirilmek üzere alınmıştır. Katkınız için teşekkür ederiz.");

                        if (!_gittim) setState(() {});
                      });
                    },
                    child: Text('Soruyu Şikayet Et'),
                  ),
                IconButton(
                  onPressed: widget.begen != null
                      ? () {
                          if (!_gittim)
                            setState(() {
                              widget.begen(true);
                            });
                        }
                      : null,
                  icon: Icon(Icons.thumb_up, color: Renk.siyah),
                ),
                Text("${widget.soru.begenme}"),
                SizedBox(width: 12.0),
                IconButton(
                  onPressed: widget.begen != null
                      ? () {
                          if (!_gittim)
                            setState(() {
                              widget.begen(false);
                            });
                        }
                      : null,
                  icon: Icon(Icons.thumb_down, color: Renk.gGri),
                ),
                Text("${widget.soru.begenmeme}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
