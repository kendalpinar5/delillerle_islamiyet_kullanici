import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/saglayici.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';
//import 'package:senv2yayin/utils/linkler.dart';

class KayitOlSyf extends StatefulWidget {
  final Box kutu;

  const KayitOlSyf({Key key, @required this.kutu}) : super(key: key);
  @override
  _KayitOlSyfState createState() => _KayitOlSyfState();
}

class _KayitOlSyfState extends State<KayitOlSyf> {
  final String tag = "Kayit Sayfasi";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Saglayici saglayici;

  TextEditingController _pass1Controller = TextEditingController();

  double genislik = Fonksiyon.ekran.width;

  bool _gskabulEdildi = true;
  bool _kkkabulEdildi = true;
  bool _autoValidate = false;
  bool _isleniyor = false;

  String _isim;
  String _soyisim;
  // String _phone;
  String _email;
  String _pass;
  // String _referansKodu;

  Future _kayitYap() async {
    dialogAc();
    FocusScope.of(context).requestFocus(new FocusNode());
    Firestore fireStore = Firestore.instance;
    try {
      AuthResult ar = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _pass,
      );

      if (ar.user != null) {
        DocumentSnapshot veri = await _eslestir(ar.user.uid);

        if (veri.exists) {
          Fonksiyon.uye = Uye.fromMap(veri.data);
          widget.kutu.put('kullanici', Fonksiyon.uye.toMap());
          Navigator.popUntil(context, ModalRoute.withName('/'));
        } else {
          Uye uye = Uye(
              uid: ar.user.uid,
              gorunenIsim: "$_isim $_soyisim",
              email: _email,
              telefon: '',
              kayitTarih: Timestamp.now().toString(),
              arkadaslar: ['nwxqtKsJgiPjM8rfeBhh9s7vKfl1', 'l6MqVDFmYGNdwoAUsFdsoFZyOsn1'],
              arkIstekleri: [],
              gonderiSayisi: 0

              //  referans: _referansKodu ?? "",
              );

          await fireStore.collection('uyeler').document(ar.user.uid).setData(uye.toMap());
          Fonksiyon.uye = uye;

          widget.kutu.put('kullanici', Fonksiyon.uye.toMap());

          Navigator.popUntil(context, ModalRoute.withName('/'));
        }
      }
    } on PlatformException catch (e) {
      Logger.log(tag, message: e.toString());
      var onValue = e.code;
      if (onValue.contains("ERROR")) {
        String hata;
        if (onValue == "ERROR_EMAIL_ALREADY_IN_USE") {
          hata = Yazi.emailHata;
        } else {
          hata = Yazi.bilinmeyenHata;
        }
        _snackGoster(hata);
        dialogKapat();
      }
    } catch (e) {
      Logger.log(tag, message: e.toString());
    }
  }

  _snackGoster(String hata) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 50),
        content: Text(hata),
        action: SnackBarAction(
          label: Yazi.tamam,
          textColor: Renk.gKirmizi,
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  dialogAc() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        _isleniyor = true;
        return Dialog(
          child: Container(
            height: genislik / 2,
            width: genislik / 2,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Renk.gKirmizi,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  dialogKapat() {
    if (_isleniyor) {
      _isleniyor = false;
      Navigator.pop(context);
    }
  }

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_gskabulEdildi && _kkkabulEdildi) {
        _kayitYap();
      } else {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              Yazi.sozlesmeOnay,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  Future<DocumentSnapshot> _eslestir(String useruid) async {
    return await Firestore.instance.collection('uyeler').document(useruid).get();
  }

  @override
  void dispose() {
    _pass1Controller.dispose();

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
            title: Text(Yazi.kayitOl),
            centerTitle: true,
            backgroundColor: Renk.wp,
            leading: IconButton(
              tooltip: Yazi.geriGit,
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
          body: Theme(
            data: ThemeData(unselectedWidgetColor: Renk.gGri),
            child: Container(
              height: double.maxFinite,
              color: Renk.beyaz,
              child: Form(
                key: _formKey,
                autovalidate: _autoValidate,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                          ),
                          child: Image.asset(
                            'assets/images/icon.png',
                            width: (genislik / 4) * 1,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "İsim",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: genislik / 20,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            fillColor: Color(0xFFEAEBEC),
                            filled: true,
                            contentPadding: const EdgeInsets.all(12.0),
                          ),
                          keyboardType: TextInputType.text,
                          validator: Fonksiyon.bosKontrol,
                          onSaved: (deg) {
                            _isim = deg;
                          },
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Soyisim",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: genislik / 20,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            fillColor: Color(0xFFEAEBEC),
                            filled: true,
                            contentPadding: const EdgeInsets.all(12.0),
                          ),
                          keyboardType: TextInputType.text,
                          validator: Fonksiyon.bosKontrol,
                          onSaved: (deg) {
                            _soyisim = deg;
                          },
                        ),
                        /*  Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Yazi.telNo,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: genislik / 20,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            fillColor: Color(0xFFEAEBEC),
                            filled: true,
                            contentPadding: const EdgeInsets.all(12.0),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: Fonksiyon.phoneKontrol,
                          onSaved: (deg) {
                            _phone = deg;
                          },
                        ), 
                        Text(
                          "Başına ülke kodunuzu da yazarak telefon numaranızı girin! Örn: +905323233232",
                        ),*/
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Yazi.emailAdresi,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: genislik / 20,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            fillColor: Color(0xFFEAEBEC),
                            filled: true,
                            contentPadding: const EdgeInsets.all(12.0),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: Fonksiyon.emailKontrol,
                          onSaved: (deg) {
                            _email = deg;
                          },
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Yazi.sifre,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: genislik / 20,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _pass1Controller,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            fillColor: Color(0xFFEAEBEC),
                            filled: true,
                            contentPadding: const EdgeInsets.all(12.0),
                          ),
                          obscureText: true,
                          validator: Fonksiyon.sifreKontrol,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Yazi.sifreTekrar,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: genislik / 20,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            fillColor: Color(0xFFEAEBEC),
                            filled: true,
                            contentPadding: const EdgeInsets.all(12.0),
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: (deg) {
                            if (deg != _pass1Controller.text) {
                              return Yazi.sifreEslesmiyor;
                            } else {
                              return null;
                            }
                          },
                          onSaved: (deg) {
                            _pass = deg;
                          },
                        ),
                        /*  Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Referans Kodu",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: genislik / 20,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                            ),
                            fillColor: Color(0xFFEAEBEC),
                            filled: true,
                            contentPadding: const EdgeInsets.all(12.0),
                          ),
                          onSaved: (deg) {
                            _referansKodu = deg;
                          },
                        ),
                        Text(
                          "Uygulamayla tanışmanızı sağlayan kişinin biliyorsanız Referans kodunu girerek kendisinin ekstra puanlar kazanmasını sağlayabilirsiniz. Hatırlamıyorsanız sonradan da profil düzenleme sayfanızdan ekleyebilirsiniz.",
                        ), */
                        SizedBox(height: 18.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 20.0,
                                child: Icon(
                                  Icons.error,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    Yazi.sifreOzellik,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.0),
                        /*   Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 20.0,
                                child: Checkbox(
                                  activeColor: Color(0xFF333333),
                                  onChanged: (bool value) {
                                    _gskabulEdildi = value;
                                    setState(() {});
                                  },
                                  value: _gskabulEdildi,
                                ),
                              ),
                              /* Expanded(
                                child: HtmlWidget(
                                  '<a style="color:#333333; text-decoration: none;" href="${Linkler.kullaniciSozlesmesi}"><b>Kullanım Koşulları</b></a>\'nı ve <a style="color:#333333; text-decoration: none;" href="${Linkler.gizlilikPolitikasi}"><b>Gizlilik Sözleşmesi</b></a>\'ni okudum ve kabul ediyorum',
                                ),
                              ), */
                            ],
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 20.0,
                                child: Checkbox(
                                  activeColor: Color(0xFF333333),
                                  onChanged: (bool value) {
                                    _kkkabulEdildi = value;
                                    setState(() {});
                                  },
                                  value: _kkkabulEdildi,
                                ),
                              ),
                              /* Expanded(
                                child: HtmlWidget(
                                  '<a style="color:#333333; text-decoration: none;" href="${Linkler.kisiselBilgiler}"><b>Kişisel Verilere İlişkin Beyan ve Rıza Onay Formu</b></a>\'nu okudum ve kabul ediyorum',
                                ),
                              ), */
                            ],
                          ),
                        ), */
                        SizedBox(height: 20.0),
                        Container(
                          width: double.maxFinite,
                          child: RaisedButton(
                            onPressed: () {
                              Logger.log(tag, message: Yazi.kayitTikla);
                              _validateInputs();
                            },
                            color: Renk.wpKoyu,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                Yazi.kayitOl,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: genislik / 20,
                                  color: Renk.beyaz,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
