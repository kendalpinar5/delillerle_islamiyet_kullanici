import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

import 'soz.dart';

class SozEkle extends StatefulWidget {
  final Soz soz;

  const SozEkle({Key key, this.soz}) : super(key: key);
  @override
  _SozEkleState createState() => _SozEkleState();
}

class _SozEkleState extends State<SozEkle> {
  final String tag = "SozEkle";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Firestore _db = Firestore.instance;
  final Uye _uye = Fonksiyon.uye;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Soz _soz;

  bool _autoValidate = false;
  bool _isleniyor = false;

  Future _selectDate() async {
    DateTime simdi = DateTime.now();

    DateTime picked = await showDatePicker(
      context: context,
      initialDate: _soz.tarih?.toDate() ?? simdi,
      firstDate: DateTime(2020),
      lastDate: DateTime(2073),
      locale: Locale('tr', 'TR'),
    );
    if (picked != null) {
      bool uygun = picked.isAfter(
        simdi.subtract(Duration(hours: simdi.hour + 1)),
      );
      if (uygun) {
        _soz.tarih = Timestamp.fromDate(picked);

        setState(() {});
      } else {
        Fonksiyon.mesajGoster(
          _scaffoldKey,
          "Geçmiş bir tarihi başlanlıç olarak seçemezsiniz",
        );
      }
    }
  }

  Future _kayitYap() async {
    _isleniyor = true;
    setState(() {});

    _soz.paylasan = _uye.gorunenIsim;
    if (_soz.id == null) {
      String time =
          Timestamp.now().millisecondsSinceEpoch.toString().substring(8);
      _soz.id = _uye.uid + time;
      await _db
          .collection('gunun_sozleri')
          .document(_soz.id)
          .setData(_soz.toJson());
    } else {
      await _db
          .collection('gunun_sozleri')
          .document(_soz.id)
          .updateData(_soz.toJson());
    }
    _isleniyor = false;
    setState(() {});
    await Future.delayed(Duration(milliseconds: 200));
    Navigator.pop(context);
  }

  void _validateInputs() {
    if (_formKey.currentState.validate() && _soz.tarih != null) {
      _formKey.currentState.save();
      _kayitYap();
    } else {
      setState(() {
        _autoValidate = true;
      });
      Fonksiyon.mesajGoster(_scaffoldKey, "Lütfen tüm alanları doldurun");
    }
  }

  @override
  void initState() {
    _soz = widget.soz ?? Soz();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
            ),
            title: Text("Söz ${widget.soz == null ? 'Ekle' : 'Düzenle'}"),
            actions: <Widget>[
              _isleniyor
                  ? Center(child: CircularProgressIndicator())
                  : IconButton(
                      onPressed: () {
                        Logger.log(tag, message: "Söz Kaydet tıklandı");
                        _validateInputs();
                      },
                      icon: Icon(Icons.check),
                    ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                autovalidate: _autoValidate,
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Başlık",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: Fonksiyon.ekran.width / 20,
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
                        fillColor: Renk.beyaz,
                        filled: true,
                        contentPadding: const EdgeInsets.all(12.0),
                        hintText: "Soz başlığını yazın",
                      ),
                      keyboardType: TextInputType.text,
                      onSaved: (deg) {
                        _soz.baslik = deg;
                      },
                      initialValue: _soz.baslik,
                      validator: Fonksiyon.bosKontrol,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Günün Sözü",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: Fonksiyon.ekran.width / 20,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 200.0),
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
                            hintText: "Söz detayını buraya yazın",
                          ),
                          keyboardType: TextInputType.text,
                          onSaved: (deg) {
                            _soz.soz = deg;
                          },
                          initialValue: _soz.soz,
                          validator: Fonksiyon.bosKontrol,
                          expands: true,
                          minLines: null,
                          maxLines: null,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Yazar",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: Fonksiyon.ekran.width / 20,
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
                        fillColor: Renk.beyaz,
                        filled: true,
                        contentPadding: const EdgeInsets.all(12.0),
                        hintText: "Sözün Sahibi...",
                      ),
                      keyboardType: TextInputType.text,
                      onSaved: (deg) {
                        _soz.yazar = deg;
                      },
                      initialValue: _soz.yazar,
                      validator: Fonksiyon.bosKontrol,
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Yayınlanma Tarihi: ",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: Fonksiyon.ekran.width / 20,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            width: Fonksiyon.ekran.width / 3,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Renk.beyaz,
                              borderRadius: BorderRadius.circular(5),
                              border:
                                  Border.all(width: 1.0, color: Renk.gGri19),
                            ),
                            child: Text(
                              _soz.tarih == null
                                  ? "Tarih Seç"
                                  : "${_soz.tarih.toDate().day}/${_soz.tarih.toDate().month}/${_soz.tarih.toDate().year}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
