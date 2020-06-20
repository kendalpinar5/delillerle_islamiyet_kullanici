import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/animasyon/kaydirma.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';
import 'package:delillerleislamiyet/uyelik/kayit_ol_syf.dart';

class GirisYapSyf extends StatefulWidget {
  final Box kutu;

  const GirisYapSyf({Key key, @required this.kutu}) : super(key: key);
  @override
  _GirisYapSyfState createState() => _GirisYapSyfState();
}

class _GirisYapSyfState extends State<GirisYapSyf> {
  final String tag = Yazi.girisSayfasi;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;

  bool _autoValidate = false;
  bool _islemde = false;
  bool _gittim = false;

  String _email;
  String _pass;

  double genislik = Fonksiyon.ekran.width;

  Future _googleIleDevamEt() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        try {
          final AuthResult ar = await _auth.signInWithCredential(credential);
          if (ar.user != null) {
            DocumentSnapshot veri = await _eslestir(ar.user.uid);

            if (veri.exists) {
              Fonksiyon.uye = Uye.fromMap(veri.data);

              widget.kutu.put('kullanici', Fonksiyon.uye.toMap());
              Navigator.popUntil(context, ModalRoute.withName('/'));
            } else {
              Uye uye = Uye(
                  uid: ar.user.uid,
                  gorunenIsim: ar.user.displayName ?? '',
                  email: ar.user.email ?? '',
                  telefon: ar.user.phoneNumber ?? '',
                  resim: ar.user.photoUrl ?? '',
                  arkadaslar: ['nwxqtKsJgiPjM8rfeBhh9s7vKfl1', 'l6MqVDFmYGNdwoAUsFdsoFZyOsn1'],
                  arkIstekleri: [],
                  gonderiSayisi: 0);

              await firestore.collection('uyeler').document(ar.user.uid).setData(uye.toMap());
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
          }
        } catch (e) {
          Logger.log(tag, message: e.toString());
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
      }
    } catch (e) {
      Logger.log(tag, message: e.toString());
    }
  }

  Future _girisYap() async {
    if (!_gittim) setState(() => _islemde = true);

    Logger.log(tag, message: Yazi.gIslemiBasladi);
    try {
      AuthResult ar = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _pass,
      );
      if (ar.user != null) {
        Logger.log(tag, message: ar.user.uid);

        DocumentSnapshot veri = await _eslestir(ar.user.uid);
        Fonksiyon.uye = Uye.fromMap(veri.data);

        widget.kutu.put('kullanici', Fonksiyon.uye.toMap());

        Navigator.popUntil(context, ModalRoute.withName('/'));
        setState(() {});
      } else {}
    } on PlatformException catch (e) {
      Logger.log(tag, message: e.toString());
      var v = e.code;
      if (v.toString().substring(0, 5) == 'ERROR') {
        switch (v) {
          case 'ERROR_USER_NOT_FOUND':
            _snackGoster(Yazi.kullaniciBulunamadi);
            break;
          case 'ERROR_WRONG_PASSWORD':
            _snackGoster(Yazi.sifreYanlis);
            break;
          case 'ERROR_TOO_MANY_REQUESTS':
            _snackGoster(Yazi.fazlaDeneme);
            break;
          default:
            _snackGoster(v);
        }
      }
    } catch (e) {
      Logger.log(tag, message: e.toString());
    }
    if (!_gittim) setState(() => _islemde = false);
  }

  _snackGoster(String hata) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
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

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _girisYap();
    } else {
      if (!_gittim) setState(() => _autoValidate = true);
    }
  }

  Future<DocumentSnapshot> _eslestir(String useruid) async {
    return await Firestore.instance.collection('uyeler').document(useruid).get();
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
          body: Container(
            height: double.maxFinite,
            color: Renk.wpKoyu,
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FadeAnimation(
                        1.5,
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.all(30),
                          decoration: BoxDecoration(
                              color: Renk.wp,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Renk.beyaz, width: 10)),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                          ),
                          child: Image.asset(
                            'assets/images/icon.png',
                            width: (genislik / 6) * 4,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Yazi.emailAdresi,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: genislik / 20,
                              color: Renk.beyaz,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          fillColor: Renk.beyaz,
                          filled: true,
                          contentPadding: const EdgeInsets.all(12.0),
                          errorStyle: TextStyle(color: Renk.beyaz),
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
                              color: Renk.beyaz,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          fillColor: Renk.beyaz,
                          filled: true,
                          contentPadding: const EdgeInsets.all(12.0),
                          errorStyle: TextStyle(color: Renk.beyaz),
                        ),
                        obscureText: true,
                        validator: Fonksiyon.sifreKontrol,
                        textInputAction: TextInputAction.done,
                        onSaved: (deg) {
                          _pass = deg;
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FlatButton(
                          onPressed: () {
                            Logger.log(tag, message: Yazi.sifremiUnuttumTikla);
                            /*  Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SifreUnuttum()),
                            ); */
                          },
                          child: Text(
                            Yazi.sifremiUnuttum,
                            style: TextStyle(color: Renk.beyaz),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        width: double.maxFinite,
                        child: RaisedButton(
                          onPressed: () {
                            Logger.log(tag, message: Yazi.girisYapTikla);
                            _validateInputs();
                          },
                          color: Renk.gGri,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _islemde
                                ? CircularProgressIndicator()
                                : Text(
                                    Yazi.girisYap,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: genislik / 20.0,
                                      color: Renk.beyaz,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            color: Renk.wp,
                            onPressed: _googleIleDevamEt,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.google,
                                  size: genislik / 20,
                                  color: Renk.beyaz,
                                ),
                                Text(
                                  "oogle ile giriş yap",
                                  style: TextStyle(
                                    fontSize: genislik / 20,
                                    color: Renk.beyaz,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20.0),
                      FlatButton(
                        onPressed: () {
                          Logger.log(tag, message: Yazi.kayitTikla);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KayitOlSyf(kutu: widget.kutu),
                            ),
                          );
                        },
                        child: Text(
                          Yazi.kayitOl,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: genislik / 20,
                            color: Renk.beyaz,
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
    );
  }
}
