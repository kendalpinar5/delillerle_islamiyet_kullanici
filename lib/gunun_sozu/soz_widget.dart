import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

import 'soz.dart';
import 'soz_ekle.dart';

class SozWidget extends StatefulWidget {
  final Soz soz;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SozWidget({Key key, @required this.soz, this.scaffoldKey})
      : super(key: key);
  @override
  _SozWidgetState createState() => _SozWidgetState();
}

class _SozWidgetState extends State<SozWidget> {
  final String tag = "SozWidget";
  final Firestore _db = Firestore.instance;
  Soz _soz;

  Future sozuGuncelle() async {
    await _db
        .collection('gunun_sozleri')
        .document(_soz.id)
        .updateData(_soz.toJson());
    setState(() {});
  }

  @override
  void initState() {
    _soz = widget.soz;

    if (_soz.begenme.contains(Fonksiyon.uye.uid))
      Fonksiyon.begenenSozler.add(_soz.id);
    if (_soz.begenmeme.contains(Fonksiyon.uye.uid))
      Fonksiyon.begenmeyenSozler.add(_soz.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Paylaşan: ${_soz.paylasan}",
                  style: TextStyle(fontSize: 12.0),
                ),
                SizedBox(width: 4.0),
                Text(
                  "${DateFormat('dd-MM-yyyy').format(_soz.tarih.toDate())}",
                  style: TextStyle(fontSize: 12.0),
                ),
                if (Fonksiyon.admin())
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) {
                        return SozEkle(soz: _soz);
                      }));
                    },
                    child: Text("düzenle"),
                  ),
              ],
            ),
            SizedBox(height: 12.0),
            SelectableText(
              _soz.soz,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerRight,
              child: Text("${_soz.yazar}"),
            ),
            SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(width: 4.0),
                Expanded(
                  child: OutlineButton.icon(
                    padding: EdgeInsets.all(0.0),
                    label: Text(
                      "${_soz.paylasma ?? 0}",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    icon: Icon(Icons.share),
                    onPressed: () async {
                      await Share.share("${_soz.soz}\n${_soz.yazar}");
                      _soz.paylasma++;
                      await sozuGuncelle();
                      Logger.log(tag, message: "soz paylaşıldı");
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: OutlineButton(
                    padding: EdgeInsets.all(0.0),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: "${_soz.soz}\n ${_soz.yazar}"),
                      );
                      Fonksiyon.mesajGoster(
                        widget.scaffoldKey,
                        "Söz panoya kopyalandı",
                      );
                      Clipboard.getData("text/plain").then((onValue) {
                        Logger.log(tag, message: "${onValue.text}");
                      });
                    },
                    child: Icon(Icons.content_copy),
                  ),
                ),
                SizedBox(width: 4.0),

                /*  Flexible(
                  child: OutlineButton.icon(
                    padding: EdgeInsets.all(0.0),
                    label: Text(
                      "${_soz.begenme.length}",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {
                      if (!Fonksiyon.begenmeyenSozler
                          .contains(
                              _soz.id)) if (!Fonksiyon.begenenSozler
                          .contains(_soz.id)) {
                        _soz.begenme.add(Fonksiyon.uye.uid);
                        sozuGuncelle();
                        Fonksiyon.begenenSozler.add(_soz.id);
                      }
                    },
                  ),
                ), */
                /*  Flexible(
                  child: OutlineButton.icon(
                    padding: EdgeInsets.all(0.0),
                    label: Text(
                      "${_soz.begenmeme.length}",
                      style: TextStyle(fontSize: 16.0),
                    ),
                    icon: Icon(Icons.thumb_down),
                    onPressed: () {
                      if (!Fonksiyon.begenenSozler
                          .contains(
                              _soz.id)) if (!Fonksiyon.begenmeyenSozler
                          .contains(_soz.id)) {
                        _soz.begenmeme.add(Fonksiyon.uye.uid);
                        sozuGuncelle();
                        Fonksiyon.begenmeyenSozler.add(_soz.id);
                      }
                    },
                  ),
                ), */
              ],
            ),
          ],
        ),
      ),
    );
  }
}
