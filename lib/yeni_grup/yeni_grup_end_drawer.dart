import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/genel/kullanici_liste_oge.dart';
import 'package:delillerleislamiyet/model/ham_uye.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class YeniGrupEndDrawer extends StatefulWidget {
  final Grup grup;
  final Box kutu;
  final Function yenile;

  const YeniGrupEndDrawer({Key key, @required this.grup, @required this.kutu, this.yenile}) : super(key: key);
  @override
  _YeniGrupEndDrawerState createState() => _YeniGrupEndDrawerState();
}

class _YeniGrupEndDrawerState extends State<YeniGrupEndDrawer> {
  final String tag = "YeniGrupEndDrawer";
  final ScrollController _scrollController = ScrollController();

  Grup _grup;
  List<HamUye> _veri = [];
  Box _box;
  Box _kayitAraci;

  List _sessizler;
  List _sesliler;

  bool _dipMi = false;
  bool _isleniyor = false;
  bool _gittim = false;

  int aktifSayi = 0;
  int aktifSayfa = 0;

  bool _yukariButton = false;

  void _scrollToBottom() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: (_scrollController.offset / 10).floor()),
      curve: Curves.easeOut,
    );
  }

  Future<int> _kullaniciListele() async {
    _veri = [];

    for (var f in _grup.katilimcilar)
      if (_veri.length == _grup.katilimcilar.length) {
        _isleniyor = false;
      } else {
        await _getProfile(f);
      }
    if (!_gittim) setState(() {});
    return _grup.katilimcilar.length;
  }

  Future _getProfile(String uid) async {
    Map uyeMap = _box.get(uid);
    if (uyeMap == null) {
      DocumentSnapshot ds = await Firestore.instance.collection('uyeler').document(uid).get();
      if (ds.exists) {
        _box.put(ds.documentID, HamUye.fromJson(ds.data).toJson());
        uyeMap = _box.get(uid);
      }
    }

    if (uyeMap != null) {
      HamUye hUye = HamUye.fromJson(uyeMap);
      if (hUye?.gorunenIsim != null && hUye.gorunenIsim.length > 3) {
        List l = hUye.gorunenIsim.split(' ');
        String kisim1 = l.getRange(0, (l.length / 2).floor()).join(' ');
        String kisim2 = l.getRange((l.length / 2).floor(), l.length).join(' ');

        if (kisim1 == kisim2) {
          Firestore.instance.collection('uyeler').document(uid).updateData({'gorunen_isim': kisim1});
          hUye.gorunenIsim = kisim1;
          _box.put(hUye.uid, hUye.toJson());
        }
      }
      _veri.add(hUye);
    }

    if (!_gittim) setState(() {});
  }

  Future _dahaFazla() async {
    if (aktifSayi < _veri.length - 30) {
      aktifSayi += 30;
      if (aktifSayi > _veri.length - 30) aktifSayi = _veri.length - 30;
      await Future.delayed(Duration(milliseconds: 500));
    }
    _dipMi = false;
    if (!_gittim) setState(() {});
  }

  Future _gruptenVazgec([String uid]) async {
    String id = uid ?? Fonksiyon.uye.uid;
    String bildirimID = Fonksiyon.fcmToken;

    List yeniList = List.from(_grup.katilimcilar);
    yeniList.remove(id);
    _grup.katilimcilar = yeniList;

    Logger.log(tag, message: yeniList.toString());

    _grup.katilimcisayisi = "${_grup.katilimcilar.length}";

    await Firestore.instance.collection('gruplar').document(_grup.id).updateData({
      'katilimcilar': FieldValue.arrayRemove([id]),
      'sesliler': FieldValue.arrayRemove([bildirimID]),
      'sessizler': FieldValue.arrayRemove([bildirimID]),
      'katilimcisayisi': "${_grup.katilimcilar.length}",
    });

    _veri.removeWhere((test) => test.uid == HamUye.fromJson(_box.get(uid)).uid);

    if (!_gittim) setState(() {});

    if (uid == null) {
      List gruplar = List.from(Fonksiyon.uye.gruplar);
      gruplar.remove(_grup.id);
      Fonksiyon.uye.gruplar = gruplar;
      _kayitAraci.put('kullanici', Fonksiyon.uye.toMap());

      Firestore.instance.collection('uyeler').document(Fonksiyon.uye.uid).updateData({
        'gruplar': FieldValue.arrayRemove([_grup.id])
      });
      if(widget.yenile !=null) widget.yenile();
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  Future _baslangicIslemleri() async {
    _grup = widget.grup;
    _sessizler = List.from(_grup.sessizler);
    _sesliler = List.from(_grup.sesliler);
    _box = await Hive.openBox('kullanicilar');
  }

  @override
  void initState() {
    _kayitAraci = widget.kutu;
    _baslangicIslemleri();

    _scrollController.addListener(() {
      if (_scrollController.offset > _scrollController.position.viewportDimension) {
        if (!_yukariButton && !_gittim) setState(() => _yukariButton = true);
      } else {
        if (_yukariButton && !_gittim) setState(() => _yukariButton = false);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _gittim = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Fonksiyon.ekran.width * 4 / 5,
      color: Renk.beyaz,
      child: Stack(
        children: <Widget>[
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels + 50 > scrollInfo.metrics.maxScrollExtent && !_dipMi) {
                _dipMi = true;
                if (!_gittim) setState(() {});
                _dahaFazla();
              }
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverPersistentHeader(
                  delegate: MySliverAppBar(
                    expandedHeight: Fonksiyon.ekran.height / 4,
                    resim: _grup.resim ?? Linkler.grupThumbResim,
                    baslik: _grup.baslik,
                  ),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Renk.gKirmizi,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: DefaultTabController(
                            length: 2,
                            child: TabBar(
                              onTap: (i) {
                                Logger.log(tag, message: "aktif tab: $i");
                                aktifSayfa = i;
                                if (aktifSayfa == 1) {
                                  aktifSayi = 0;
                                  _kullaniciListele();
                                }
                                if (!_gittim) setState(() {});
                              },
                              tabs: <Widget>[
                                Tab(text: "Detay"),
                                Tab(text: "Katılımcılar"),
                              ],
                              indicatorColor: Renk.gKirmizi,
                              labelColor: Renk.gKirmizi,
                            ),
                          ),
                        ),
                        if (aktifSayfa == 1)
                          _isleniyor
                              ? Center(child: CircularProgressIndicator())
                              : Column(
                                  children:
                                      _veri.getRange(0, _veri.length < 30 ? _veri.length : aktifSayi + 30).map((f) {
                                    Logger.log(tag, message: "${_veri.length}");
                                    bool ssIs = false;
                                    return StatefulBuilder(
                                      builder: (c, s) {
                                        return Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: KullaniciListeOge(user: f),
                                            ),
                                            if (Fonksiyon.uye.rutbe > 16 && !ssIs)
                                              IconButton(
                                                onPressed: () {
                                                  ssIs = true;
                                                  s(() {});
                                                  _gruptenVazgec(
                                                    f.uid,
                                                  ).whenComplete(() {
                                                    aktifSayi--;
                                                    ssIs = false;
                                                    s(() {});
                                                  });
                                                },
                                                icon: Icon(Icons.exit_to_app),
                                              ),
                                            if (ssIs)
                                              CircularProgressIndicator(
                                                backgroundColor: Renk.beyaz,
                                              )
                                          ],
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                        if (aktifSayfa == 0)
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(FontAwesomeIcons.flag),
                                    SizedBox(width: 4.0),
                                    Text(
                                      "Grubun Yaşı: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "${Fonksiyon.zamanFarkiBul(_grup.yTarih.toDate())}",
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(FontAwesomeIcons.user),
                                    SizedBox(width: 4.0),
                                    Text(
                                      "Katılımcı Sayısı: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text("${_grup.katilimcisayisi}"),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                margin: EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(FontAwesomeIcons.book),
                                    SizedBox(width: 4.0),
                                    Text(
                                      "Kurallar: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              for (int i = 0; i < _grup.kurallar.length; i++)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(width: 4.0),
                                      Icon(
                                        FontAwesomeIcons.dotCircle,
                                        size: 8,
                                      ),
                                      SizedBox(width: 4.0),
                                      Expanded(
                                        child: Text("${_grup.kurallar[i]}"),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                margin: EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(FontAwesomeIcons.infoCircle),
                                    SizedBox(width: 4.0),
                                    Text(
                                      "Açıklama: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("${_grup.aciklama}"),
                              ),
                              Wrap(
                                children: <Widget>[
                                  for (String a in _grup.anahtarkelimeler.split(',')) Text("#${a.trim()} "),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 8.0),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Icon(FontAwesomeIcons.bell),
                                    SizedBox(width: 4.0),
                                    Text(
                                      "Bildirim: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    Switch(
                                      activeColor: Renk.gKirmizi,
                                      value: _grup.sesliler.contains(Fonksiyon.fcmToken) ||
                                          _grup.sessizler.contains(Fonksiyon.fcmToken),
                                      onChanged: (v) {
                                        Logger.log(tag, message: v.toString());

                                        Map<String, dynamic> m = {
                                          'sessizler': v
                                              ? FieldValue.arrayUnion([Fonksiyon.fcmToken])
                                              : FieldValue.arrayRemove([Fonksiyon.fcmToken]),
                                        };
                                        if (v) {
                                          _sessizler.add(Fonksiyon.fcmToken);
                                        } else {
                                          _sessizler.remove(Fonksiyon.fcmToken);
                                          _sesliler.remove(Fonksiyon.fcmToken);
                                          m['sesliler'] = FieldValue.arrayRemove([Fonksiyon.fcmToken]);
                                        }
                                        _grup.sessizler = _sessizler;
                                        _grup.sesliler = _sesliler;
                                        Firestore.instance
                                            .collection('gruplar')
                                            .document(_grup.id)
                                            .updateData(m)
                                            .whenComplete(() {
                                          if (!_gittim) setState(() {});
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (_grup.sesliler.contains(Fonksiyon.fcmToken) ||
                                  _grup.sessizler.contains(Fonksiyon.fcmToken))
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(FontAwesomeIcons.volumeOff),
                                      SizedBox(width: 4.0),
                                      Text(
                                        "Bildirim Sesi: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Spacer(),
                                      Switch(
                                        activeColor: Renk.gKirmizi,
                                        value: _grup.sesliler.contains(Fonksiyon.fcmToken),
                                        onChanged: (v) {
                                          if (v) {
                                            _sesliler.add(Fonksiyon.fcmToken);
                                            _sessizler.remove(Fonksiyon.fcmToken);
                                          } else {
                                            _sesliler.remove(Fonksiyon.fcmToken);
                                            _sessizler.add(Fonksiyon.fcmToken);
                                          }
                                          _grup.sessizler = _sessizler;
                                          _grup.sesliler = _sesliler;
                                          Firestore.instance.collection('gruplar').document(_grup.id).updateData({
                                            'sesliler': v
                                                ? FieldValue.arrayUnion([Fonksiyon.fcmToken])
                                                : FieldValue.arrayRemove([Fonksiyon.fcmToken]),
                                            'sessizler': !v
                                                ? FieldValue.arrayUnion([Fonksiyon.fcmToken])
                                                : FieldValue.arrayRemove([Fonksiyon.fcmToken]),
                                          }).whenComplete(() {
                                            if (!_gittim) setState(() {});
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        if (aktifSayfa == 0) SizedBox(height: 60.0)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_yukariButton)
            Positioned(
              bottom: 10.0,
              left: 0.0,
              right: 0.0,
              child: Center(
                child: FloatingActionButton(
                  onPressed: _scrollToBottom,
                  child: _dipMi ? CircularProgressIndicator(backgroundColor: Renk.beyaz) : Icon(Icons.arrow_upward),
                ),
              ),
            ),
          if (aktifSayfa == 0)
            Positioned(
              bottom: 10.0,
              left: 0.0,
              right: 0.0,
              child: Center(
                child: FlatButton(
                  onPressed: () => _gruptenVazgec(),
                  child: Text("Gruptan Ayrıl"),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final String resim;
  final String baslik;

  MySliverAppBar({@required this.expandedHeight, @required this.resim, @required this.baslik});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        CachedNetworkImage(
          imageUrl: resim,
          placeholder: (context, url) => new CircularProgressIndicator(),
          errorWidget: (context, url, error) => new Icon(Icons.error),
          fit: BoxFit.cover,
        ),
        Opacity(
          opacity: shrinkOffset / expandedHeight,
          child: Container(
            height: double.maxFinite,
            color: Renk.gGri.withOpacity(shrinkOffset / expandedHeight * 0.7),
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            alignment: Alignment.bottomCenter,
            child: Text(
              baslik,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
