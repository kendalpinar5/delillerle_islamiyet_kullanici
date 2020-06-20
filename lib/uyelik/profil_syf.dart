import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/akis_veri_ekle.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/widgets/akis_veri_widget.dart';
import 'package:delillerleislamiyet/model/akis_veri_model.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';
import 'package:delillerleislamiyet/uyelik/arkadas_listesi.dart';
import 'package:delillerleislamiyet/uyelik/profile_item.dart';

class ProfilSyf extends StatefulWidget {
  @override
  _ProfilSyfState createState() => _ProfilSyfState();
}

class _ProfilSyfState extends State<ProfilSyf> {
  final String tag = Yazi.profilSayfasi;
  final TextEditingController _editingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Firestore _db = Firestore.instance;
  final ScrollController _scrollController = ScrollController();

  Box _kutu;
  Uye user;
  File _file;

  bool _rYukleniyor = false;
  bool _gittim = false;
  List<AkisVeri> _akisVeri = [];
  DocumentSnapshot sonDoc;

  bool _islem = false;

  double _sY = 0;
  double _sO = 0;
  bool _ark = false;
  bool _istek = false;
  _degistir(String s) {
    _editingController.text = user.toMap()[s];
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: TextFormField(
            controller: _editingController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: s,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("İptal"),
            ),
            FlatButton(
              onPressed: () {
                if (s == "referans" && _editingController.text.length != 6) {
                  Fonksiyon.mesajGoster(
                    _scaffoldKey,
                    "Lütfen referans kodunu 6 hane olacak şekilde girin!",
                  );
                } else {
                  Map use = user.toMap();
                  use[s] = _editingController.text;
                  user = Uye.fromMap(use);

                  Logger.log(tag, message: "$user");
                  Navigator.pop(context);
                  if (!_gittim) setState(() {});
                }
              },
              child: Text("Onay"),
            ),
          ],
        );
      },
    );
  }

  Future _resimSec() async {
    _rYukleniyor = true;
    if (!_gittim) setState(() {});

    _file = await FilePicker.getFile(type: FileType.image);
    _rYukleniyor = false;
    if (!_gittim) setState(() {});
  }
/* 
  _konumSecimiYap(LatLng ll) async {
    Map adrs = await Fonksiyon.adresbul(ll.latitude, ll.longitude);
    if (adrs != null && adrs['status'] == "OK") {
      List adres = adrs['results'];
      adres =
          adres.map((f) => f['address_components'][0]['long_name']).toList();

      user.yeniAdres = {
        'adres': adres,
        'enlem': ll.latitude,
        'boylam': ll.longitude,
      };
      await Firestore.instance
          .collection('kullanicilar')
          .document(user.uid)
          .updateData({'yeni_adres': user.yeniAdres});
    }
    if (!_gittim) setState(() {});
  } */

  Future profiliGuncelle() async {
    _rYukleniyor = true;
    if (!_gittim) setState(() {});

    StorageReference storageRef;

    if (_file != null) {
      storageRef = FirebaseStorage.instance.ref().child(
            "profilresimleri/${Random().nextInt(10000000).toString()}.jpg",
          );
      File compressedFile;
      ImageProperties properties = await FlutterNativeImage.getImageProperties(_file.path);
      compressedFile = await FlutterNativeImage.compressImage(
        _file.path,
        quality: 80,
        targetWidth: 500,
        targetHeight: (properties.height * 600 / properties.width).round(),
      );

      if (storageRef != null) {
        final StorageUploadTask uploadTask = storageRef.putFile(
          compressedFile,
          StorageMetadata(
            contentType: "image/jpg",
          ),
        );
        final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
        if (user.resim != Linkler.thumbResim) {
          //  resimSil(user.resim);
        }
        user.resim = (await downloadUrl.ref.getDownloadURL());
        kullaniciGuncelle();
        Logger.log(tag, message: 'URL Is ${user.resim}');
      }
    } else {
      kullaniciGuncelle();
    }
    _rYukleniyor = false;
    if (!_gittim) setState(() {});
  }

/*   resimSil(String res) {
    RegExp desen = RegExp("profilresimleri%2F(.*?).jpg");
    Match ma = desen.firstMatch(res);

    FirebaseStorage.instance
        .ref()
        .child('profilresimleri/${ma.group(1)}.jpg')
        .delete()
        .whenComplete(() {
      Logger.log(tag, message: "eşleşen: ${ma.group(1)}");
    });
  } */

  kullaniciGuncelle() {
    Firestore.instance.collection('uyeler').document(user.uid).updateData(user.toMap()).whenComplete(() {
      Fonksiyon.uye = user;
      _rYukleniyor = false;
      _kutu.put('kullanici', user.toMap());
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text('İşleminiz başarıyla gerçekleşti.')),
      );
      if (!_gittim) setState(() {});
    });
    FirebaseAuth.instance.currentUser().then((u) {
      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = user.gorunenIsim;
      updateInfo.photoUrl = user.resim;
      u.updateProfile(updateInfo);
    });
  }

  secim(List s) {
    user.ilgiAlanlari = s;
    //if (!_gittim) setState(() {});
  }

  Future<void> _signOut(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await FirebaseAuth.instance.signOut();
      bool googleSignedIn = await googleSignIn.isSignedIn();
      if (googleSignedIn) {
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }

      Fonksiyon.uye = null;
      _kutu.delete('kullanici');
    } catch (e) {
      Logger.log(tag, message: e.toString());
    }
  }

  Future _hesabiSil() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        String isim = "";
        bool siliniyor = false;
        return StatefulBuilder(
          builder: (_, setstate) {
            return AlertDialog(
              title: Text("Hesap Silme Uyarısı"),
              content: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Hesabınızı silmeniz halinde sunucularımızdaki tüm hesap bilgileriniz silinecektir. Hesabınızı silme işlemini onaylamak için soluk metni kutucuğa yazın.",
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: Fonksiyon.seoYap(user.gorunenIsim),
                      ),
                      onChanged: (v) => setstate(() => isim = v),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                if (!siliniyor)
                  FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("İptal"),
                  ),
                if (!siliniyor)
                  FlatButton(
                    onPressed: isim == Fonksiyon.seoYap(user.gorunenIsim)
                        ? () {
                            setstate(() => siliniyor = true);
                            Logger.log(tag, message: "Silme işlemi başladı");
                            Future.delayed(Duration(seconds: 4)).whenComplete(
                              () => setstate(() => siliniyor = false),
                            );
                            Firestore.instance
                                .collection('silinen_kullanicilar')
                                .document(user.uid)
                                .setData(user.toMap())
                                .whenComplete(() {
                              Firestore.instance
                                  .collection('kullanicilar')
                                  .document(user.uid)
                                  .delete()
                                  .whenComplete(() {
                                setstate(() => siliniyor = false);
                                Navigator.pop(context);
                                _signOut(context).whenComplete(() {
                                  _kutu.delete('kullanici');

                                  Navigator.popUntil(
                                    context,
                                    ModalRoute.withName('/'),
                                  );
                                });
                              });
                            });
                          }
                        : null,
                    child: Text("Hesabı Sil"),
                  ),
                if (siliniyor)
                  SizedBox(
                    width: double.maxFinite,
                    child: LinearProgressIndicator(),
                  )
              ],
            );
          },
        );
      },
    );
  }

  Future _giris() async {
    _kutu = await Hive.openBox('kayitaraci');
    user = Uye.fromMap(Map<String, dynamic>.from(_kutu.get('kullanici')));

    if (user.element == "Hidrojen") {
      user.element = "Bronz_5";
      Firestore.instance.collection('uyeler').document(user.uid).updateData({'element': "Bronz_5"});
    }

    Firestore.instance.collection('uyeler').document(user.uid).get().then((DocumentSnapshot ds) {
      user = Uye.fromMap(ds.data);
      Fonksiyon.uye = user;
      _kutu.put('kullanici', user.toMap());
      if (!_gittim) setState(() {});
    });
  }

/* 
  var url = "http://malibayram.com/flutterdilillerle/kon.php";

  Future _veriCek() async {
    var res = await http.get(url);
    var decodejson = jsonDecode(res.body);
    SohKonular _so = SohKonular();

    Logger.log(tag, message: decodejson['sohbetler'].length.toString());
    for (int i = 0; i < decodejson['sohbetler'].length; i++) {
      _so.konuId = decodejson['sohbetler'][i]['sohbet_id'].toString();
      _so.konuKitapId =
          decodejson['sohbetler'][i]['sohbet_kitap_id'].toString();
      _so.konuBaslik = decodejson['sohbetler'][i]['sohbet_adi'].toString();
      _so.konuAciklama =
          decodejson['sohbetler'][i]['sohbet_aciklama'].toString();
      _so.konuResim = decodejson['sohbetler'][i]['sohbet_resim'].toString();
      _so.konuEkleyen = Fonksiyon.uye.uid;
      _so.konuSes = decodejson['sohbetler'][i]['sohbet_ses'].toString();
      _so.okunma = int.parse(decodejson['sohbetler'][i]['okunma'].toString());
      _so.konuTarih = Timestamp.now();

      Logger.log(tag,
          message: decodejson['sohbetler'][i]['kitap_id'].toString());

      QuerySnapshot qs = await Firestore.instance
          .collection('sohbet_kitaplari')
          .where('kitap_id', isEqualTo: _so.konuKitapId)
          .getDocuments();
      for (DocumentSnapshot ds in qs.documents) {
        await Firestore.instance
            .collection('sohbet_kitaplari')
            .document(ds.documentID)
            .collection('sohbetler')
            .add(_so.toMap());
      }
    }

    /*  QuerySnapshot qs =
        await Firestore.instance.collection('akis_verileri').getDocuments();

    for (DocumentSnapshot ds in qs.documents) {
      Logger.log(tag, message: 'bittii' + ds.documentID);
      await Firestore.instance
          .collection('akis_verileri')
          .document(ds.documentID)
          .updateData({'resim': ''});
    } */

    // Firestore.instance.collection('akis_verileri').add(data);
  }
 */
  Future _makaleGetir() async {
    setState(() => _islem = true);
    QuerySnapshot qs;
    if (sonDoc == null)
      qs = await _db
          .collection('akis_verileri')
          .where('ekleyen', isEqualTo: Fonksiyon.uye.uid)
          .where('onay', isEqualTo: true)
          .orderBy('tarih', descending: true)
          .limit(5)
          .getDocuments();
    else
      qs = await _db
          .collection('akis_verileri')
          .where('ekleyen', isEqualTo: Fonksiyon.uye.uid)
          .where('onay', isEqualTo: true)
          .orderBy('tarih', descending: true)
          .startAfterDocument(sonDoc)
          .limit(5)
          .getDocuments();
    if (qs.documents.isNotEmpty) sonDoc = qs.documents.last;
    for (DocumentSnapshot ds in qs.documents) {
      _akisVeri.add(AkisVeri.fromMap(ds.data));
    }
    setState(() => _islem = false);
  }

  yenile() {
    _akisVeri = [];
    sonDoc = null;
    _makaleGetir();
    setState(() {});
  }

  @override
  void initState() {
    _giris();
    _makaleGetir();
    _scrollController.addListener(() {
      _sO = _scrollController.offset;
      _sY = _scrollController.position.maxScrollExtent;

      if (_sO + 220 > _sY && !_islem) _makaleGetir();
    });
    super.initState();
  }

  @override
  void dispose() {
    _gittim = true;

    super.dispose();
  }

  int islemSayisi = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("${Yazi.profilSayfasi}"),
            /* actions: <Widget>[
              IconButton(
                onPressed: () async {
                  Logger.log(tag, message: "İşlem başladı ${ks.length}");
                  /* for (Map k in ks) {
                    QuerySnapshot qs = await Firestore.instance
                        .collection('kullanicilar')
                        .where('email',
                            isEqualTo: "${k['email']}".toLowerCase())
                        .getDocuments();

                    for (DocumentSnapshot ds in qs.documents) {
                      Logger.log(tag, message: "${ds.data['gorunen_isim']}");
                      Logger.log(tag, message: "${k['isim']}");
                      await Firestore.instance
                          .collection('kullanicilar')
                          .document(ds.documentID)
                          .updateData({
                        'gorunen_isim': "${k['isim']}",
                        "il": "${k['il']}",
                        "rutbe": 21,
                      });
                    }
                    setState(() => islemSayisi++);
                  } */
                  Logger.log(tag, message: "İşlem bitti");
                },
                icon: Icon(Icons.airline_seat_flat_angled),
              ),
            ], */
          ),
          body: user == null
              ? Center(child: CircularProgressIndicator())
              : Container(
                  color: Renk.gGri12,
                  height: double.maxFinite,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.maxFinite,
                          color: Renk.wp,
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              children: <Widget>[
                                ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: 20),
                                  child: InkWell(
                                    onTap: () {
                                      _degistir("gorunen_isim");
                                    },
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: <Widget>[
                                        Text(
                                          "${user.gorunenIsim}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Renk.beyaz,
                                            fontSize: 26.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Container(
                                          color: Colors.black54,
                                          child: Icon(
                                            Icons.edit,
                                            size: 14,
                                            color: Renk.beyaz,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _degistir("unvan"),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: <Widget>[
                                      Text(
                                        "${user.unvan}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Renk.beyaz,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black54,
                                        child: Icon(
                                          Icons.edit,
                                          size: 10,
                                          color: Renk.beyaz,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.3, 0.7],
                              colors: [
                                Renk.wp,
                                Renk.gGri9,
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          "Gönderiler",
                                          style: TextStyle(
                                            color: Renk.beyaz,
                                            fontSize: Fonksiyon.ekran.width / 30,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        child: Text(
                                      user.gonderiSayisi.toString(),
                                      style: TextStyle(
                                        color: Renk.gKirmizi,
                                        fontSize: Fonksiyon.ekran.width / 26,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              Stack(
                                children: <Widget>[
                                  InkWell(
                                    onTap: _resimSec,
                                    child: Container(
                                      height: 150,
                                      width: 150,
                                      padding: EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                        color: Renk.beyaz,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Renk.gGri,
                                            blurRadius: 10.0,
                                          ),
                                        ],
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: _file == null
                                            ? CachedNetworkImage(
                                                imageUrl: user.resim,
                                                placeholder: (context, url) => CircularProgressIndicator(),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(_file, fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      alignment: Alignment.bottomCenter,
                                      child: IconButton(icon: Icon(Icons.photo_camera), onPressed: null),
                                    ),
                                  )
                                ],
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => ArkadasListesi())),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: Text(
                                            "Arkadaşlar",
                                            style: TextStyle(
                                              color: Renk.beyaz,
                                              fontSize: Fonksiyon.ekran.width / 30,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          user.arkadaslar.length.toString(),
                                          style: TextStyle(
                                            color: Renk.gKirmizi,
                                            fontSize: Fonksiyon.ekran.width / 26,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: FutureBuilder(
                            future: Firestore.instance
                                .collection('saglik_mutluluk')
                                .where('kisi_id', isEqualTo: user.uid)
                                .getDocuments(),
                            builder: (_, AsyncSnapshot<QuerySnapshot> asq) {
                              if (asq.hasData) {
                                if (asq.data.documents.length > 0) {
                                  List<DocumentSnapshot> docs = asq.data.documents;
                                  double saglik =
                                      (docs.fold(0.0, (prev, elem) => prev + elem.data['saglik']) / docs.length);
                                  double mutluluk =
                                      (docs.fold(0.0, (prev, elem) => prev + elem.data['mutluluk']) / docs.length);
                                  return Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text('Sağlık ortalaması: '),
                                              ),
                                            ),
                                            Stack(
                                              children: <Widget>[
                                                CircularProgressIndicator(
                                                  value: saglik / 10,
                                                  backgroundColor: Renk.gGri19,
                                                ),
                                                Positioned.fill(
                                                  child: Center(
                                                    child: Text(
                                                      "${saglik.toStringAsFixed(1)}",
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text('Mutluluk ortalaması: '),
                                              ),
                                            ),
                                            Stack(
                                              children: <Widget>[
                                                CircularProgressIndicator(
                                                  value: mutluluk / 10,
                                                  backgroundColor: Renk.gGri19,
                                                ),
                                                Positioned.fill(
                                                  child: Center(
                                                    child: Text(
                                                      "${mutluluk.toStringAsFixed(1)}",
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                } else
                                  return SizedBox();
                              }
                              return LinearProgressIndicator();
                            },
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              color: Renk.beyaz,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Renk.gGri, width: 0.5),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            "${user.puan ?? ''}",
                                            style: TextStyle(fontSize: MediaQuery.of(context).size.width / 30),
                                          ),
                                          Container(
                                            child: Text(
                                              'Puan',
                                              style: TextStyle(
                                                  color: Renk.gGri.withOpacity(0.7),
                                                  fontSize: MediaQuery.of(context).size.width / 38),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            "${user.element ?? ''}",
                                            style: TextStyle(fontSize: MediaQuery.of(context).size.width / 30),
                                          ),
                                          Container(
                                            child: Text(
                                              "Seviye",
                                              style: TextStyle(
                                                  color: Renk.gGri.withOpacity(0.7),
                                                  fontSize: MediaQuery.of(context).size.width / 38),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: double.maxFinite,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                color: Renk.wpAcik,
                                onPressed: () {
                                  // _veriCek();
                                  profiliGuncelle();
                                },
                                child: _rYukleniyor
                                    ? CircularProgressIndicator(
                                        backgroundColor: Renk.beyaz,
                                      )
                                    : Text(
                                        "Değişiklikleri Kaydet",
                                        style: TextStyle(color: Renk.beyaz),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8.0),
                                      child: FlatButton(
                                        color: Renk.wp,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        onPressed: () {},
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              FontAwesomeIcons.plusCircle,
                                              color: Renk.beyaz,
                                              size: MediaQuery.of(context).size.width /
                                                  (MediaQuery.of(context).size.width / 18),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              'Hikayene Ekleme Yap',
                                              style: TextStyle(
                                                color: Renk.beyaz,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  FlatButton(
                                    padding: EdgeInsets.all(0),
                                    color: Renk.gGri.withOpacity(0.2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    onPressed: () {},
                                    child: Icon(
                                      FontAwesomeIcons.ellipsisH,
                                      color: Renk.siyah,
                                      size:
                                          MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width / 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.maxFinite,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: FlatButton(
                                color: Renk.beyaz,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Renk.wpKoyu, width: 2),
                                    borderRadius: BorderRadius.circular(10)),
                                onPressed: () =>
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => ArkadasListesi())),
                                child: Text(
                                  'Arkadaş Listesi',
                                  style: TextStyle(color: Renk.wpKoyu),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  Renk.beyaz.withAlpha(22),
                                  BlendMode.screen,
                                ),
                                child: ProfileItem(
                                  ikon: Icons.mail,
                                  yazi: "${user.email}",
                                ),
                              ),
                            ),
                            SizedBox(height: 12.0),

                            /*  InkWell(
                              onTap: () {
                                if (!user.telOnay) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TelDogrula(uye: user),
                                    ),
                                  );
                                }
                              },
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  Renk.beyaz
                                      .withAlpha(user.telOnay ? 22 : 0),
                                  BlendMode.screen,
                                ),
                                child: ProfileItem(
                                  ikon: Icons.phone,
                                  yazi:
                                      "${user.telefon} Onaylı ${user.telOnay ? '' : 'Değil'}",
                                ),
                              ),
                            ),
                            SizedBox(height: 12.0), */

                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              height: 40.0,
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Renk.gGri19,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                                color: Renk.beyaz,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(Icons.nature),
                                  ),
                                  Flexible(
                                    child: FlatButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/alan_sec',
                                        arguments: {
                                          'Fnks': secim,
                                          'secilenler': user.ilgiAlanlari,
                                        },
                                      ),
                                      child: Text(
                                        user.ilgiAlanlari.length > 0
                                            ? "${user.ilgiAlanlari.reversed}"
                                            : "İlgi alanlarınızı seçin",
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.0),
                            /*  

                          hesabı sil kısmı taşınacak
                          
                           FlatButton(
                              onPressed: _hesabiSil,
                              child: Text(
                                "Hesabımı Sil",
                                style: TextStyle(
                                  color: Renk.gKirmizi,
                                  fontSize: Fonksiyon.ekran.width / 26,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.0), */
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => AkisVeriEkle(
                                              yenile: yenile,
                                            )));
                              },
                              child: Container(
                                height: 90,
                                width: double.maxFinite,
                                color: Renk.beyaz,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      height: 30,
                                      width: double.maxFinite,
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(right: 10, bottom: 5, top: 5),
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        'Gönderiler',
                                        style: TextStyle(color: Renk.siyah, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          height: 40,
                                          width: 40,
                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(50),
                                              image: DecorationImage(
                                                  image: NetworkImage(Fonksiyon.uye.resim), fit: BoxFit.cover)),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 30,
                                            width: double.maxFinite,
                                            alignment: Alignment.centerLeft,
                                            margin: EdgeInsets.only(right: 10),
                                            padding: EdgeInsets.only(left: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Renk.siyah, width: 1),
                                            ),
                                            child: Text('Yazı paylaş...'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                for (int i = 0; i < _akisVeri.length; i++)
                                  AkisVeriWidget(
                                    veri: _akisVeri[i],
                                    scaffoldKey: _scaffoldKey,
                                  ),
                                if (_akisVeri.length < 1)
                                  Container(
                                    child: Text('Henuz bişey paylaşılmadı'),
                                  )
                              ],
                            ),
                            _islem
                                ? Center(
                                    child: CircularProgressIndicator(backgroundColor: Renk.beyaz),
                                  )
                                : SizedBox(
                                    height: 200,
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
