import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

import 'soz.dart';
import 'soz_ekle.dart';
import 'soz_widget.dart';

class GununSozu extends StatefulWidget {
  final Function menum;

  const GununSozu({Key key, this.menum}) : super(key: key);
  @override
  _GununSozuState createState() => _GununSozuState();
}

class _GununSozuState extends State<GununSozu> {
  final String tag = "GununSozu";
  final Firestore _db = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  List<Soz> sozler = [];
  DocumentSnapshot sonDoc;

  bool _islem = false;

  double _sY = 0;
  double _sO = 0;

  Future sozleriGetir() async {
    setState(() => _islem = true);
    QuerySnapshot qs;
    if (sonDoc == null)
      qs = await _db
          .collection('gunun_sozleri')
          .where('onay', isEqualTo: true)
          .orderBy('tarih', descending: true)
          .limit(10)
          .getDocuments();
    else
      qs = await _db
          .collection('gunun_sozleri')
          .where('onay', isEqualTo: true)
          .orderBy('tarih', descending: true)
          .startAfterDocument(sonDoc)
          .limit(10)
          .getDocuments();
    if (qs.documents.isNotEmpty) sonDoc = qs.documents.last;
    for (DocumentSnapshot ds in qs.documents) {
      sozler.add(Soz.fromJson(ds.data));
    }
    setState(() => _islem = false);
  }

  @override
  void initState() {
    sozleriGetir();

    _scrollController.addListener(() {
      _sO = _scrollController.offset;
      _sY = _scrollController.position.maxScrollExtent;
      Logger.log(tag, message: "_sO: $_sO / _sY: $_sY");
      Logger.log(tag, message: "${_scrollController.position.outOfRange}");
      if (_sO + 220 > _sY && !_islem) sozleriGetir();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Renk.beyaz,
          ),
          onPressed: widget.menum,
        ),
        title: _islem
            ? Center(
                child: CircularProgressIndicator(backgroundColor: Renk.beyaz),
              )
            : Text("Günün Sözü"),
        centerTitle: true,
        actions: <Widget>[
          if (Fonksiyon.admin())
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) {
                  return SozEkle();
                }));
              },
              icon: Icon(Icons.add),
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            for (Soz soz in sozler)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: SozWidget(soz: soz, scaffoldKey: _scaffoldKey),
              ),
          ],
        ),
      ),
    );
  }
}
