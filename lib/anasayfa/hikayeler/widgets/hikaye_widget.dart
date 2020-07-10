import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/anasayfa/hikayeler/hikaye_bak.dart';
import 'package:delillerleislamiyet/model/hikaye_model.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class HikayeWidget extends StatefulWidget {
  final Hikaye gHik;

  const HikayeWidget({Key key, this.gHik}) : super(key: key);
  @override
  _HikayeWidgetState createState() => _HikayeWidgetState();
}

class _HikayeWidgetState extends State<HikayeWidget> {
  Uye _uye;
  bool resimYok = false;

  goruntulenme() async {
    widget.gHik.goruntulenme++;
    await Firestore.instance.collection('hikayeler').document(widget.gHik.id).updateData(widget.gHik.toMap());
  }

  Future _kCek() async {
    DocumentSnapshot ds = await Firestore.instance.collection('uyeler').document(widget.gHik.ekleyen).get();
    _uye = Uye.fromMap(ds.data);
    setState(() {});
  }

  @override
  void initState() {
    if (widget.gHik.resim.length < 1) {
      resimYok = true;
    }
    _kCek();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (resimYok) {
        } else {
          goruntulenme();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => HikayeBak(
                        gHik: widget.gHik,
                        gUye: _uye,
                      )));
        }
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3),
          height: MediaQuery.of(context).size.height / 4,
          width: MediaQuery.of(context).size.width / 3.5,
          decoration: BoxDecoration(
            color: Renk.gGri,
            borderRadius: BorderRadius.circular(30),
            image: DecorationImage(
                image: NetworkImage(
                  resimYok ? 'https://www.teb.org.tr/images/no-photo.png' : widget.gHik.resim[0],
                ),
                fit: BoxFit.fitWidth),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _uye == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      height: 40,
                      width: 40,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Renk.beyaz, width: 2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          image: DecorationImage(
                              image: NetworkImage(
                                _uye.resim,
                              ),
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
              Expanded(
                child: Container(
                  height: 40,
                  width: double.maxFinite,
                  alignment: Alignment.bottomLeft,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: _uye == null
                      ? Center(
                          child: LinearProgressIndicator(),
                        )
                      : Text(
                          _uye.gorunenIsim,
                          style: TextStyle(color: Renk.beyaz, fontWeight: FontWeight.normal),
                        ),
                ),
              ),
            ],
          )),
    );
  }
}
