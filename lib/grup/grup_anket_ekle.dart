import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/mesaj.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class GrupAnketEkle extends StatefulWidget {
  final Grup grup;

  const GrupAnketEkle({Key key, @required this.grup}) : super(key: key);
  @override
  _GrupAnketEkleState createState() => _GrupAnketEkleState();
}

class _GrupAnketEkleState extends State<GrupAnketEkle> {
  final String tag = "GrupAnketEkle";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _islem = false;
  bool _autoValidate = false;
  bool _gittim = false;

  List<Map> _anket = [
    {"soru": "", "oy_sayisi": 0, "tamam": false},
    {"secenek": "", "oy_sayisi": 0},
  ];

  Future _anketEkle() async {
    _islem = true;
    if (!_gittim) setState(() {});

    Mesaj msj = Mesaj(
      gonderen: "${Fonksiyon.uye.gorunenIsim}",
      yazan: Fonksiyon.uye.uid,
      yazanRsm: Fonksiyon.uye.resim,
      grupid: widget.grup.id,
      metin: 'anket',
      resim: '',
      anket: _anket,
      tarih: FieldValue.serverTimestamp(),
    );

    await Firestore.instance
        .collection('gruplar')
        .document(widget.grup.id)
        .collection('mesajlar')
        .document(Timestamp.now().millisecondsSinceEpoch.toString())
        .setData(msj.toMap());

    Navigator.pop(context);
  }

  void _validateInputs() {
    if (_formKey.currentState.validate() &&
        _anket.length > 1 &&
        _anket[1]['secenek'].length > 1) {
      _formKey.currentState.save();
      _anketEkle();
    } else {
      _autoValidate = true;
      if (!_gittim) setState(() {});
      Fonksiyon.mesajGoster(_scaffoldKey, "Lütfen tüm alanları doldurun");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Renk.gGri12,
      appBar: AppBar(
        title: Text("Anket Ekle"),
        actions: <Widget>[
          _islem
              ? Center(child: CircularProgressIndicator())
              : IconButton(
                  onPressed: _validateInputs,
                  icon: Icon(Icons.check),
                )
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Soru",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Fonksiyon.ekran.width / 20,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 160.0),
                  child: IntrinsicHeight(
                    child: TextFormField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEAEBEC)),
                        ),
                        fillColor: Renk.beyaz,
                        filled: true,
                        contentPadding: const EdgeInsets.all(12.0),
                        hintText: "Anket için gerekli soruyu buraya yazın...",
                      ),
                      keyboardType: TextInputType.text,
                      onSaved: (deg) {
                        _anket[0]['soru'] = deg;
                      },
                      initialValue: _anket[0]['soru'],
                      validator: Fonksiyon.bosKontrol,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                    ),
                  ),
                ),
                Divider(),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Seçenekler",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Fonksiyon.ekran.width / 20,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    for (int i = 1; i < _anket.length; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(
                                  text: _anket[i]['secenek'],
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFEAEBEC)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFEAEBEC)),
                                  ),
                                  fillColor: Renk.beyaz,
                                  filled: true,
                                  contentPadding: const EdgeInsets.all(12.0),
                                  hintText: "Sorunuz için seçenek ekleyin ...",
                                ),
                                onChanged: (deg) {
                                  _anket[i]['secenek'] = deg;
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (i + 1 == _anket.length)
                                  _anket.add({"secenek": "", "oy_sayisi": 0});
                                else
                                  _anket.removeAt(i);
                                Logger.log(tag,
                                    message: "${_anket.toString()}");
                                if (!_gittim) setState(() {});
                              },
                              icon: Icon(
                                i + 1 == _anket.length
                                    ? Icons.add
                                    : Icons.remove,
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
