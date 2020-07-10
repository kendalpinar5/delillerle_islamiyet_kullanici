import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Ayarlar extends StatefulWidget {
  final Function yenile;

  const Ayarlar({Key key, this.yenile}) : super(key: key);

  @override
  _AyarlarState createState() => _AyarlarState();
}

class _AyarlarState extends State<Ayarlar> {
  final String tag = "Ayarlar";
  

  final TextEditingController _editingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  bool _inProcess = false;
  final picker = ImagePicker();


  Box _kutu;
  Uye user;
  File _file;
  bool _gittim = false;

  bool _rYukleniyor = false;
  bool degisiyor = false;
  _resimSec(ImageSource source) async {
    Logger.log(tag, message: 'geldi');
    setState(() {
      _inProcess = true;
    });
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Delillerle İslamiyet',
              toolbarColor: Renk.wp,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      if (croppedFile != null)
        setState(() {
          _file = croppedFile;

          _inProcess = false;
        });
      else
        setState(() {
          _inProcess = false;
        });
    } else {
      setState(() {
        _inProcess = false;
      });
    }
  }

  void _cameraGalery() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Renk.wp,
                  child: IconButton(
                    icon: Icon(
                      FontAwesomeIcons.images,
                      color: Renk.beyaz,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _resimSec(ImageSource.gallery);
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  color: Renk.wpAcik,
                  child: IconButton(
                    icon: Icon(
                      FontAwesomeIcons.camera,
                      color: Renk.beyaz,
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      _resimSec(ImageSource.camera);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

                  Logger.log('tag', message: "$user");
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
        Logger.log('tag', message: 'URL Is ${user.resim}');
      }
    } else {
      kullaniciGuncelle();
    }
    if (widget.yenile != null) widget.yenile();
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
      Logger.log('tag', message: e.toString());
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
                            Logger.log('tag', message: "Silme işlemi başladı");
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

  @override
  void initState() {
    _giris();

    super.initState();
  }

  @override
  void dispose() {
    _gittim = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("${Yazi.profilSayfasi}"),
            actions: <Widget>[
              /*  IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Ayarlar()));
                  }) */
            ],
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
              : Stack(
                  children: <Widget>[
                    Container(
                      color: Renk.beyaz,
                      height: double.maxFinite,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: ClampingScrollPhysics(),
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 275,
                              margin: EdgeInsets.only(bottom: 10),
                              child: Stack(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Card(
                                        elevation: 10,
                                        margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Renk.wpKoyu,
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                                            /*  image: DecorationImage(
                                                image: NetworkImage(
                                                  user.resim,
                                                ),
                                                fit: BoxFit.fill), */
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: MediaQuery.of(context).size.width / 2 - 75,
                                    child: Stack(
                                      children: <Widget>[
                                        InkWell(
                                          onTap: _cameraGalery,
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
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.maxFinite,
                              color: Renk.wpKoyu,
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
                            /*  IntrinsicWidth(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _renkAc = !_renkAc;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 20, top: 20),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: Color(Fonksiyon.temaRengi),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 30,
                                        height: 30,
                                        margin: EdgeInsets.only(left: 15),
                                        decoration: BoxDecoration(
                                          color: Renk.beyaz,
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10, right: 20),
                                        child: Text(
                                          'TEMA RENK AYARLARI',
                                          style: TextStyle(color: Renk.beyaz, fontSize: 20),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _renkAc
                                ? Container(
                                    margin: EdgeInsets.only(right: 5, left: 5, top: 15),
                                    height: 50,
                                    width: double.maxFinite,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Renk.siyah, width: 1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                                      height: MediaQuery.of(context).size.width / 4.5,
                                      child: GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 1,
                                          childAspectRatio: 1,
                                        ),
                                        shrinkWrap: false,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _renkler.length,
                                        itemBuilder: (BuildContext ctxt, int index) {
                                          //.toString().split("x")[1].replaceAll(')', '')
                                          int renk = _renkler[index];
                                          bool ekli = ekliRenk == renk;

                                          return Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: InkWell(
                                              onTap: () {
                                                if (ekli)
                                                  Logger.log(
                                                    'tag',
                                                    message: "$renk ${int.parse("0x$renk") + 0xff999999}",
                                                  );
                                                else {
                                                  _renkDegis(_renkler[index]).then((value) {
                                                    Fonksiyon.temaRengi = _renkler[index];
                                                    ekliRenk = _renkler[index];
                                                    setState(() {});
                                                  });
                                                }

                                                Logger.log(
                                                  'tag',
                                                  message: "$renk ${int.parse("0x$renk") + 0xff999999}",
                                                );
                                              },
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Renk.siyah,
                                                    width: 0.5,
                                                  ),
                                                  color: Color(renk),
                                                  borderRadius: BorderRadius.circular(50.0),
                                                ),
                                                child: ekli
                                                    ? Icon(
                                                        Icons.check,
                                                        color: Color(
                                                          0xffffffff,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                : SizedBox(), */
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
                                        style: TextStyle(color: Renk.siyah),
                                      ),
                              ),
                            ),
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
                          ],
                        ),
                      ),
                    ),
                    _inProcess
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.98,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Center()
                  ],
                ),
        ),
      ),
    );
  }
}
