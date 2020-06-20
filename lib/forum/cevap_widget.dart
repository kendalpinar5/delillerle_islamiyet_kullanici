import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/model/cevap.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class CevapWidget extends StatefulWidget {
  final Cevap cevap;
  final Function fonk;
  final Function begen;

  const CevapWidget({
    Key key,
    @required this.cevap,
    @required this.fonk,
    this.begen,
  }) : super(key: key);
  @override
  _CevapWidgetState createState() => _CevapWidgetState();
}

class _CevapWidgetState extends State<CevapWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(),
            Row(
              children: <Widget>[
                SizedBox(height: 16.0),
                FutureBuilder(
                  future: widget.fonk(widget.cevap.ekleyen),
                  builder: (ct, AsyncSnapshot<Map> m) {
                    if (m.hasData) {
                      Uye uye = Uye.fromMap(m.data);
                      return Text(
                        uye.gorunenIsim,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      );
                    }
                    return CircularProgressIndicator();
                  },
                ),
                Spacer(),
                Text(
                                      "${Fonksiyon.zamanFarkiBul(widget.cevap.tarih.toDate())} önce",

                ),
              ],
            ),
            SizedBox(height: 4.0),
            Text(widget.cevap.cevap),
            SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  onPressed: widget.begen != null
                      ? () => setState(() {
                            widget.begen(widget.cevap, true);
                          })
                      : null,
                  icon: Icon(Icons.thumb_up, size: 18),
                ),
                Text("${widget.cevap.begenme}"),
                SizedBox(width: 12.0),
                IconButton(
                  onPressed: widget.begen != null
                      ? () => setState(() {
                            widget.begen(widget.cevap, false);
                          })
                      : null,
                  icon: Icon(
                    Icons.thumb_down,
                    size: 18,
                    color: Renk.gGri,
                  ),
                ),
                Text("${widget.cevap.begenmeme}"),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Container(height: 0.3, color: Renk.siyah),
      ],
    );
  }
}
