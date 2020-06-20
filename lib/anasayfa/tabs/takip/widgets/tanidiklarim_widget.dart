import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/profil_ex/profil_ex.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class TanidiklarimWidget extends StatefulWidget {
  final Uye uye;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function yenile;

  const TanidiklarimWidget({Key key, this.uye, this.scaffoldKey, this.yenile})
      : super(key: key);
  @override
  _TanidiklarimWidgetState createState() => _TanidiklarimWidgetState();
}

class _TanidiklarimWidgetState extends State<TanidiklarimWidget> {
  bool bekleniyor = false;

  _uyeKaldir(Uye uye) async {
    setState(() => bekleniyor = true);

    if (!Fonksiyon.kaldirdigimTanArklar.contains(uye.uid))
      Fonksiyon.kaldirdigimTanArklar.add(uye.uid);
    if (widget.yenile() != null) widget.yenile();
    await Future.delayed(Duration(seconds: 1));

    setState(() => bekleniyor = false);
  }

  Future _arkIstekGonder(Uye _uye) async {
    setState(() => bekleniyor = true);

    List g = [];
    await Firestore.instance
        .collection('uyeler')
        .document(_uye.uid)
        .get()
        .then((onValue) {
      g = onValue.data['arkIstekleri'] ?? [];
      if (!g.contains(Fonksiyon.uye.uid)) {
        g.add(Fonksiyon.uye.uid);
        Firestore.instance
            .collection('uyeler')
            .document(onValue.documentID)
            .updateData({'arkIstekleri': g}).then((onValue) {
          Fonksiyon.bildirimGonder(
              bMesaj: '',
              bBaslik: '',
              alici: _uye.uid,
              gonderen: Fonksiyon.uye.uid,
              tur: 'arkadaslik',
              baslik: 'Arkadaşlık isteği',
              mesaj:
                  '${Fonksiyon.uye.gorunenIsim} size arkadaşlık isteği gönderdi..',
              jeton: [_uye.bildirimjetonu]);
        });
      }
    });

    if (widget.yenile() != null) widget.yenile();
    await Future.delayed(Duration(seconds: 1));
    setState(() => bekleniyor = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
        height: MediaQuery.of(context).size.height / 3.5,
        width: MediaQuery.of(context).size.width / 2.5,
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfilSyfEx(
                              gUye: widget.uye,
                            )));
              },
              child: Container(
                height: MediaQuery.of(context).size.height / 5.5,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(widget.uye.resim), fit: BoxFit.cover),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 5, top: 5),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.uye.gorunenIsim,
                style: TextStyle(
                    color: Renk.siyah,
                    fontSize: MediaQuery.of(context).size.width / 22),
              ),
            ),
            bekleniyor
                ? Center(
                    child: LinearProgressIndicator(),
                  )
                : Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          child: FlatButton(
                            color: Renk.wp,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onPressed: () {
                              _arkIstekGonder(widget.uye);
                            },
                            child: Icon(
                              Icons.person_add,
                              color: Renk.beyaz,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        child: FlatButton(
                            color: Renk.gKirmizi,
                            padding: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            onPressed: () {
                              _uyeKaldir(widget.uye);
                            },
                            child: Icon(
                              Icons.delete,
                              color: Renk.beyaz,
                            )),
                      )
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
