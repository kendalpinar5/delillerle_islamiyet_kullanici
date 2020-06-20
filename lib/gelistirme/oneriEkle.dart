import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class OneriEkle extends StatefulWidget {
  @override
  _BilgilendirmeEkleState createState() => _BilgilendirmeEkleState();
}

class _BilgilendirmeEkleState extends State<OneriEkle> {
  String _baslik = "";
  String _aciklama = "";
  bool _isleniyor = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: Text("Fikir Öner")),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Başlık",
                    ),
                    onChanged: (String v) => _baslik = v,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IntrinsicHeight(
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Açıklama",
                      ),
                      maxLines: null,
                      minLines: null,
                      expands: true,
                      onChanged: (String v) => _aciklama = v,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24.0),
                  child: _isleniyor
                      ? Center(child: CircularProgressIndicator())
                      : OutlineButton(
                          highlightedBorderColor: Renk.gKirmizi,
                          onPressed: () {
                            if (_baslik.length > 0 &&
                                _aciklama.length > 0 &&
                                !_isleniyor) {
                              setState(() => _isleniyor = true);

                              Firestore.instance
                                  .collection('gelistirme')
                                  .document('oneri')
                                  .collection('icerik')
                                  .add({
                                'baslik': _baslik,
                                'aciklama': _aciklama,
                                'tarih': FieldValue.serverTimestamp(),
                                'yayinlayan': Fonksiyon.uye.uid,
                                'yayinlayan_adi': Fonksiyon.uye.gorunenIsim,
                                'onay': Fonksiyon.admin(),
                                'begenme': 0,
                                'begenmeme': 0,
                                'katilanlar': [],
                                'katilmayanlar': [],
                              }).whenComplete(() => setState(() {
                                        _baslik = "";
                                        _aciklama = "";
                                        _isleniyor = false;
                                        Navigator.pop(context);
                                        Fluttertoast.showToast(
                                          msg:
                                              'Öneriniz yöneticiler tarafından kontrol edilmek üzere sunucuya gönderildi. İncelemeden sonra yayınlanacaktır.',
                                          toastLength: Toast.LENGTH_LONG,
                                          
                                        );
                                      }));
                            } else
                              Fluttertoast.showToast(
                                msg: 'Lütfen tüm alanları doldurun',
                              );
                          },
                          child: Text("Onay İçin Gönder"),
                        ),
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "* Olumsuz bir durumun oluşmaması adına buradan gönderilen iletiler; yayınlanmadan önce yöneticiler tarafından incelenmektedir.",
                      style: TextStyle(
                        color: Renk.gGri,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
