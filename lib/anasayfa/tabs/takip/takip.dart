import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/widgets/akis_veri_widget.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/takip/widgets/tanidiklarim_widget.dart';
import 'package:delillerleislamiyet/model/akis_veri_model.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Takip extends StatefulWidget {
  const Takip({Key key}) : super(key: key);
  @override
  _TakipState createState() => _TakipState();
}

class _TakipState extends State<Takip> {
  final String tag = "Takip";

  final Firestore _db = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  List _akisVeri = [];
  DocumentSnapshot sonDoc;
  Box _kutu = Hive.box('anasayfa');
  bool _islem = false;

  double _sY = 0;
  double _sO = 0;

  bool _gittim = false;

  Future taniyorOlabileceklerin() async {
    Fonksiyon.tanidiklarim = [];
    for (int i = 0; i < Fonksiyon.uye.arkadaslar.length; i++) {
      DocumentSnapshot ds = await _db.collection('uyeler').document(Fonksiyon.uye.arkadaslar[i]).get();

      for (int i = 0; i < ds.data['arkadaslar'].length; i++) {
        //arkadaşlarımın arkadasları dönüyor

        List g = [];
        DocumentSnapshot ds3 = await _db.collection('uyeler').document(ds.data['arkadaslar'][i]).get();

        //DS3 ARK DETAY

        g = ds3.data['arkIstekleri'] ?? [];

        if (ds.data['arkadaslar'][i] != Fonksiyon.uye.uid &&
            !Fonksiyon.uye.arkadaslar.contains(ds.data['arkadaslar'][i]) &&
            !Fonksiyon.uye.arkIstekleri.contains(ds.data['arkadaslar'][i]) &&
            !Fonksiyon.kaldirdigimTanArklar.contains(ds.data['arkadaslar'][i]) &&
            !g.contains(Fonksiyon.uye.uid)) {
          await _kCek(ds.data['arkadaslar'][i]).then((onValue) {
            Fonksiyon.tanidiklarim.add(onValue);
          });
        }
      }
    }

    if (Hive.isBoxOpen('anasayfa')) _kutu.put('taniyorolabileceklerim', Fonksiyon.tanidiklarim);
  }

  Future _kCek(String uId) async {
    DocumentSnapshot ds = await _db.collection('uyeler').document(uId).get();

    return ds.data;
  }

  Future _takipGetir() async {
    Fonksiyon.uye.arkadaslar.add(Fonksiyon.uye.uid);

    if (!_gittim) setState(() => _islem = true);

    QuerySnapshot qs;
    if (Fonksiyon.uye.arkadaslar != null) if (sonDoc == null) {
      _akisVeri = [];
      qs = await _db
          .collection('akis_verileri')
          .where('onay', isEqualTo: true)
          .where('ekleyen', whereIn: Fonksiyon.uye.arkadaslar)
          .orderBy('tarih', descending: true)
          .limit(10)
          .getDocuments();
    } else {
      qs = await _db
          .collection('akis_verileri')
          .where('onay', isEqualTo: true)
          .where('ekleyen', whereIn: Fonksiyon.uye.arkadaslar)
          .orderBy('tarih', descending: true)
          .startAfterDocument(sonDoc)
          .limit(10)
          .getDocuments();
    }

    if (qs.documents.isNotEmpty) sonDoc = qs.documents.last;
    for (DocumentSnapshot ds in qs.documents) {
      _akisVeri.add(ds.data.map((key, value) =>
          key == 'tarih' ? MapEntry(key, (value as Timestamp).millisecondsSinceEpoch) : MapEntry(key, value)));
    }

    _kutu.put('takipVerileri', _akisVeri);

    Fonksiyon.uye.arkadaslar.remove(Fonksiyon.uye.uid);

    if (!_gittim) setState(() => _islem = false);
  }

  @override
  void initState() {
    super.initState();
    taniyorOlabileceklerin();

    _takipGetir();
    _scrollController.addListener(() {
      _sO = _scrollController.offset;
      _sY = _scrollController.position.maxScrollExtent;

      if (_sO + 220 > _sY && !_islem) _takipGetir();
    });
  }

  @override
  void dispose() {
    _gittim = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Renk.gGri12,
        body: RefreshIndicator(
          backgroundColor: Renk.wpAcik,
          color: Renk.beyaz,
          onRefresh: () async {
            taniyorOlabileceklerin();

            _takipGetir();
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (Fonksiyon.tanidiklarim.length > 0)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: Renk.beyaz,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 30,
                              margin: EdgeInsets.only(left: 10, top: 3),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Tanıyor olabileceğin Kişiler',
                                style: TextStyle(color: Renk.wpKoyu, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ValueListenableBuilder(
                                      valueListenable: _kutu.listenable(keys: ['taniyorolabileceklerim']),
                                      builder: (context, box, widget) {
                                        List _taniyorolabileceklerim =
                                            box.get('taniyorolabileceklerim', defaultValue: []);
                                        return Row(
                                          children: <Widget>[
                                            for (int i = 0; i < _taniyorolabileceklerim.length; i++)
                                              TanidiklarimWidget(
                                                uye: Uye.fromMap(_taniyorolabileceklerim[i]),
                                                scaffoldKey: _scaffoldKey,
                                                yenile: taniyorOlabileceklerin,
                                              )
                                          ],
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ValueListenableBuilder(
                        valueListenable: _kutu.listenable(keys: ['takipVerileri']),
                        builder: (context, box, widget) {
                          List _akisVeri = box.get('takipVerileri', defaultValue: []);
                          return Column(
                            children: <Widget>[
                              for (int i = 0; i < _akisVeri.length; i++)
                                AkisVeriWidget(
                                  veri: AkisVeri.fromMap(_akisVeri[i]
                                      .map((k, v) => k == 'tarih'
                                          ? MapEntry(k, Timestamp.fromMillisecondsSinceEpoch(v))
                                          : MapEntry(k, v))
                                      .cast<String, dynamic>()),
                                  scaffoldKey: _scaffoldKey,
                                ),
                              if (_akisVeri.length < 1)
                                Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Container(
                                    child: Text(
                                      'Henüz arkadaşınız olmadığı için herhangi bir veri bulunamadı!!!',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                            ],
                          );
                        })
                  ],
                ),
                _islem
                    ? Center(
                        child: CircularProgressIndicator(backgroundColor: Renk.beyaz),
                      )
                    : SizedBox(
                        height: 200,
                      )
              ],
            ),
          ),
        )
        /*  : CardListSkeleton(
              style: SkeletonStyle(
                  theme: SkeletonTheme.Light,
                  isShowAvatar: true,
                  isCircleAvatar: true,
                  barCount: 3,
                  borderRadius: BorderRadius.circular(10)),
            ), */
        /*  floatingActionButton: PopupMenuButton<String>(
        icon: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              color: Renk.wpAcik, borderRadius: BorderRadius.circular(50)),
          child: Icon(
            Icons.sort_by_alpha,
            color: Renk.beyaz,
          ),
        ),
        tooltip: "sırala",
        onSelected: (key) {
          Map m = _kriterler.firstWhere((test) => test.containsValue(key));
          if (!_gittim && m.length > 0) {
            _aramaKriteri = m['deger'];
            _aramaYonu = m['yon'];
            _takipGetir();
          }
        },
        itemBuilder: (_) => <PopupMenuEntry<String>>[
          for (Map m in _kriterler)
            PopupMenuItem(
              value: m['deger'],
              child: Text(m['kriter']),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, */
        );
  }
}
