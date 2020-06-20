import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:delillerleislamiyet/medrese/konular/widgets/med_konu_benzer_widget.dart';
import 'package:delillerleislamiyet/medrese/konular/widgets/med_konu_yorum_widget.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/model/med_konu_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:delillerleislamiyet/model/med_konu_yorum.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class MedKonuDetay extends StatefulWidget {
  final MedKonular gKonu;
  final String gKonuResim;

  MedKonuDetay({
    this.gKonu,
    this.gKonuResim,
  });

  @override
  _MedKonuDetayState createState() => _MedKonuDetayState();
}

class _MedKonuDetayState extends State<MedKonuDetay> {
  final Firestore _db = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isPlay = false;
  double volume = 1.0;
  Uye _uye;

  String toplamYazi = "0:00:00:00";
  String anlikYazi = "0:00:00:00";

  int toplamSure = 0;
  int anlikSure = 0;

  double slide = 0.0;
  int textSize = 16;
  AudioPlayer advancedPlayer = new AudioPlayer();

  void boyutArttir() {
    textSize++;
    setState(() {});
  }

  void boyutAzalt() {
    textSize--;
    setState(() {});
  }

  playPause() {
    if (isPlay) {
      setState(() {
        advancedPlayer.pause();
        isPlay = false;
      });
    } else {
      setState(() {
        advancedPlayer
            .play("http://malibayram.com/flutterdilillerle/admin/audio/ders/" + widget.gKonu.konuSes)
            .then((onValue) {
          advancedPlayer.setVolume(volume);
          debugPrint(onValue.toString());

          advancedPlayer.durationHandler = (Duration d) {
            toplamYazi = d.toString();
            toplamSure = d.inMilliseconds;
            setState(() {});
          };

          advancedPlayer.positionHandler = (Duration d) {
            anlikYazi = d.toString();
            anlikSure = d.inMilliseconds;

            slide = (anlikSure / toplamSure);

            if (anlikSure >= toplamSure - 1000) {
              advancedPlayer.stop();
              anlikSure = 0;
              toplamSure = 0;
              slide = 0.0;
              isPlay = false;
            }

            setState(() {});
          };
        });
        isPlay = true;
      });
    }
  }

  _geri() {
    advancedPlayer.seek(new Duration(milliseconds: anlikSure - 5000));
  }

  _ileri() {
    advancedPlayer.seek(new Duration(milliseconds: anlikSure + 5000));
  }

  Future _uyeCek() async {
    await Firestore.instance.collection('uyeler').document(widget.gKonu.konuEkleyen).get().then((onValue) {
      _uye = Uye.fromMap(onValue.data);
    });

    setState(() {});
  }

  Future<List<MedKonular>> _benzerGetir() async {
    QuerySnapshot querySnapshot = await _db
        .collection('medrese_kitaplari')
        .document(widget.gKonu.konuKitapId)
        .collection('konular')
        .orderBy('okunma', descending: true)
        .limit(3)
        .getDocuments();

    return querySnapshot.documents.map((d) => MedKonular.fromMap(d.data)).toList();
  }

  Future<List<MedKonuYorum>> _yorumGetir() async {
    QuerySnapshot querySnapshot = await _db
        .collection('medrese_kitaplari')
        .document(widget.gKonu.konuKitapId)
        .collection('konular')
        .document(widget.gKonu.konuId)
        .collection('yorumlar')
        .orderBy('tarih', descending: true)
        .getDocuments();

    return querySnapshot.documents.map((d) => MedKonuYorum.fromMap(d.data)).toList() ?? [];
  }

  Future ekle() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        MedKonuYorum _yorum = MedKonuYorum();
        bool hata = false;
        return StatefulBuilder(
          builder: (ctx, setstate) {
            return AlertDialog(
              title: Text("Yorum Ekle & Soru Sor?"),
              content: Container(
                width: double.maxFinite,
                child: Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 160.0),
                      child: IntrinsicHeight(
                        child: TextField(
                          decoration: InputDecoration(labelText: "Yorum & Sorunuz?"),
                          onChanged: (v) {
                            _yorum.cevap = v;
                            if (_yorum.cevap.length <= 5)
                              hata = true;
                            else
                              hata = false;
                            setstate(() {});
                          },
                          expands: true,
                          minLines: null,
                          maxLines: null,
                        ),
                      ),
                    ),
                    hata ? Text("Lütfen en az 5 karakter girin!") : Container(),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    if (_yorum.cevap != null) {
                      if (_yorum.cevap.length > 5) {
                        Timestamp t = Timestamp.now();
                        _yorum.ekleyen = Fonksiyon.uye.uid;
                        _yorum.veriId = widget.gKonu.konuId;
                        _yorum.tarih = t;

                        _db
                            .collection('medrese_kitaplari')
                            .document(widget.gKonu.konuKitapId)
                            .collection('konular')
                            .document(widget.gKonu.konuId)
                            .collection('yorumlar')
                            .add(_yorum.toMap())
                            .then((onValue) {
                          _db
                              .collection('medrese_kitaplari')
                              .document(widget.gKonu.konuKitapId)
                              .collection('konular')
                              .document(widget.gKonu.konuId)
                              .collection('yorumlar')
                              .document(onValue.documentID)
                              .updateData({'id': onValue.documentID});
                        });
                        if (widget.gKonu.yorumSayisi == null) widget.gKonu.yorumSayisi = 0;
                        widget.gKonu.yorumSayisi++;

                        _db
                            .collection('medrese_kitaplari')
                            .document(widget.gKonu.konuKitapId)
                            .collection('konular')
                            .document(widget.gKonu.konuId)
                            .updateData(widget.gKonu.toMap());

                        setState(() {});

                        Navigator.pop(context);
                      } else {
                        hata = true;
                        setState(() {});
                      }
                    } else {
                      hata = true;
                      setState(() {});
                    }
                  },
                  child: Text("Ekle"),
                ),
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("İptal"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    _uyeCek();
    super.initState();
  }

  @override
  void dispose() {
    advancedPlayer.stop();
    isPlay = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Renk.beyaz,
              title: Text(
                widget.gKonu.konuBaslik,
                maxLines: 1,
                style: TextStyle(
                  color: Renk.wpKoyu,
                  fontSize: 16.0,
                ),
              ),
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Renk.wpKoyu,
                  ),
                  onPressed: () => Navigator.pop(context)),
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Image.network(
                  Linkler.medKitap + widget.gKonuResim,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ];
        },
        body: ListView(
          padding: const EdgeInsets.all(3.0),
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.all(3.0),
                    child: Card(
                      elevation: 6.0,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 3.0),
                                        child: Icon(
                                          Icons.date_range,
                                          size: 14.0,
                                        ),
                                      ),
                                      Text(
                                        "${Fonksiyon.zamanFarkiBul(widget.gKonu.konuTarih.toDate())} önce",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _uye == null
                                ? Expanded(
                                    child: LinearProgressIndicator(),
                                  )
                                : Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        child: Text(
                                          "Ekleyen: " + _uye.gorunenIsim,
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        child: IconButton(
                          color: Colors.black,
                          onPressed: () => boyutAzalt(),
                          icon: Icon(FontAwesomeIcons.searchMinus),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 45.0,
                          margin: EdgeInsets.only(left: 3.0, right: 3.0),
                          child: Card(
                            elevation: 6.0,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: FlatButton(
                                        onPressed: () {
                                          ekle();
                                        },
                                        color: Renk.beyaz,
                                        child: Text(
                                          "Yorum Ekle / Soru Sor ?",
                                          style: TextStyle(color: Renk.wpKoyu),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: IconButton(
                          color: Colors.black,
                          onPressed: () => boyutArttir(),
                          icon: Icon(FontAwesomeIcons.searchPlus),
                        ),
                      ),
                    ],
                  ),
                  widget.gKonu.konuSes != ""
                      ? Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0, bottom: 5.0),
                              height: 30.0,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 8.0,
                                    left: 8.0,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Image.asset("assets/images/ses1.png"),
                                      Expanded(
                                        child: Slider(
                                          activeColor: Colors.black,
                                          inactiveColor: Colors.grey.shade400,
                                          value: volume,
                                          onChanged: (newValue) {
                                            setState(() {
                                              volume = newValue;
                                              advancedPlayer.setVolume(volume);
                                            });
                                          },
                                        ),
                                      ),
                                      Image.asset("assets/images/ses2.png"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0, bottom: 5.0),
                              height: 30.0,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 8.0,
                                    left: 8.0,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        anlikYazi.substring(2, 7),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          activeColor: Colors.black,
                                          inactiveColor: Colors.grey.shade400,
                                          value: slide,
                                          onChanged: (newValue) {
                                            setState(() {
                                              slide = newValue;
                                              debugPrint("değişiyor");
                                              if (toplamSure > 1) {
                                                advancedPlayer
                                                    .seek(new Duration(milliseconds: (toplamSure * newValue).toInt()));
                                              } else {
                                                slide = 0.0;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      Text(
                                        toplamYazi.substring(2, 7),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            isPlay == true
                                ? Card(
                                    child: Container(
                                      height: 30,
                                      decoration: BoxDecoration(border: Border.all(color: Renk.wpAcik, width: 0.5)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            child: FlatButton(
                                              onPressed: () {
                                                _geri();
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(right: 8.0),
                                                    child: Text(
                                                      "-5",
                                                    ),
                                                  ),
                                                  Icon(
                                                    FontAwesomeIcons.backward,
                                                    size: MediaQuery.of(context).size.width / 22,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: FlatButton(
                                              onPressed: () {
                                                _ileri();
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    FontAwesomeIcons.forward,
                                                    size: MediaQuery.of(context).size.width / 22,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(left: 8.0),
                                                    child: Text(
                                                      "+5",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 0.0,
                                  ),
                          ],
                        )
                      : Container(
                          height: 0.0,
                        ),
                  widget.gKonu.konuAciklama != ""
                      ? Container(
                          margin: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0, bottom: 5.0),
                          child: Card(
                            color: Color(0xffeee5de),
                            elevation: 6.0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  /*  Card(
                                    margin: EdgeInsets.only(bottom: 15.0),
                                    elevation: 3.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        widget.gKonu.konuBaslik + "  Arapça",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  ), */
                                  Container(
                                    width: double.maxFinite,
                                    child: Text(
                                      widget.gKonu.konuAciklama,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: textSize.toDouble(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 0.0,
                        ),
                  widget.gKonu.konuAciklama2 != ""
                      ? Container(
                          margin: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 20.0),
                          child: Card(
                            elevation: 6.0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Card(
                                    margin: EdgeInsets.only(bottom: 15.0),
                                    elevation: 3.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        widget.gKonu.konuBaslik,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.maxFinite,
                                    child: Text(
                                      widget.gKonu.konuAciklama2,
                                      style: TextStyle(
                                        fontSize: textSize.toDouble(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 0.0,
                        ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'İlginizi Çekebilir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Renk.wpKoyu,
                      ),
                    ),
                  ),
                  FutureBuilder<List<MedKonular>>(
                    future: _benzerGetir(),
                    builder: (_, als) {
                      if (als.connectionState == ConnectionState.active) return LinearProgressIndicator();
                      if (als.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            for (MedKonular veri in als.data)
                              MedKonuBenzerWidget(veri: veri, scaffoldKey: _scaffoldKey, gKonuResim: widget.gKonuResim),
                          ],
                        );
                      }
                      return SizedBox();
                    },
                  ),
                  InkWell(
                    onTap: () => ekle(),
                    child: Container(
                      height: 60,
                      width: double.maxFinite,
                      color: Renk.beyaz,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 40,
                            width: 40,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                image: DecorationImage(image: NetworkImage(Fonksiyon.uye.resim), fit: BoxFit.cover)),
                          ),
                          Expanded(
                            child: Container(
                              height: 40,
                              width: double.maxFinite,
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Renk.gGri19, width: 0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Yorum Ekle / Soru Sor ?",
                                    style: TextStyle(
                                      color: Renk.gGri,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.send,
                                      color: Renk.wpAcik,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.gKonu.yorumSayisi != null)
                    if (widget.gKonu.yorumSayisi < 1)
                      Container(
                        height: 100,
                      ),
                  if (widget.gKonu.yorumSayisi != null)
                    if (widget.gKonu.yorumSayisi > 0)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Tüm Yorumlar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Renk.wpKoyu,
                          ),
                        ),
                      ),
                  FutureBuilder<List<MedKonuYorum>>(
                    future: _yorumGetir(),
                    builder: (_, als) {
                      if (als == null) return SizedBox();
                      if (als.connectionState == ConnectionState.active) return LinearProgressIndicator();
                      if (als.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            for (MedKonuYorum _yorum in als.data)
                              MedKonuYorumWidget(
                                yorum: _yorum,
                                scaffoldKey: _scaffoldKey,
                              ),
                            SizedBox(
                              height: 100,
                            )
                          ],
                        );
                      }

                      return SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.gKonu.konuSes != ""
          ? FloatingActionButton(
              elevation: 6.0,
              backgroundColor: isPlay ? Renk.wpAcik : Renk.beyaz,
              child: new Icon(
                isPlay ? Icons.pause : Icons.play_arrow,
                color: isPlay ? Renk.beyaz : Renk.wpKoyu,
              ),
              onPressed: () {
                playPause();
              },
            )
          : Container(),
    );
  }
}
