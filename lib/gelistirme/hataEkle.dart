import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class HataEkle extends StatefulWidget {
  @override
  _BilgilendirmeEkleState createState() => _BilgilendirmeEkleState();
}

class _BilgilendirmeEkleState extends State<HataEkle> {
  final String tag = "HataEkle";
  List<File> _files = [];

  String _baslik = "";
  String _aciklama = "";
  bool _isleniyor = false;

  void _resmiGoster(Widget w) {
    showDialog(
      context: context,
      builder: (ctx) {
        return FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Container(
            width: double.maxFinite,
            child: w,
          ),
        );
      },
    );
  }

  void _resimSec() {
    FilePicker.getFile(type: FileType.image).then((onValue) {
      if (onValue != null) {
        Logger.log(tag, message: onValue.path);
        _files.add(onValue);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.wp.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: Text("Hata Bildir")),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Hatanın daha iyi anlaşılması için mümkünsa hataya ait ekran görüntülerini alıp iletinize ekleyin.",
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    children: <Widget>[
                      for (File f in _files)
                        Container(
                          width: (Fonksiyon.ekran.width - 56.0) / 5,
                          height: (Fonksiyon.ekran.width - 56.0) / 5,
                          margin: EdgeInsets.all(4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                  child: InkWell(
                                    onTap: () => _resmiGoster(
                                      Image.file(f, fit: BoxFit.cover),
                                    ),
                                    child: Image.file(f, fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  bottom: 2.0,
                                  right: 2.0,
                                  child: InkWell(
                                    onTap: () =>
                                        setState(() => _files.remove(f)),
                                    child: Container(
                                      color: Renk.gGri19,
                                      child: Icon(
                                        Icons.delete,
                                        color: Renk.gKirmizi,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      Container(
                        width: (Fonksiyon.ekran.width - 56.0) / 5,
                        height: (Fonksiyon.ekran.width - 56.0) / 5,
                        margin: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Renk.gGri19),
                        ),
                        child: InkWell(
                          onTap: _resimSec,
                          child: Icon(Icons.add_a_photo, color: Renk.gGri19),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24.0),
                  child: _isleniyor
                      ? Center(child: CircularProgressIndicator())
                      : OutlineButton(
                          highlightedBorderColor: Renk.gKirmizi,
                          onPressed: () async {
                            if (_baslik.length > 0 &&
                                _aciklama.length > 0 &&
                                !_isleniyor) {
                              setState(() => _isleniyor = true);
                              List<String> resimler = [];

                              if (_files.length > 0) {
                                for (File f in _files) {
                                  String mZaman = Timestamp.now()
                                      .microsecondsSinceEpoch
                                      .toString();
                                  String sonuc = await Fonksiyon.resimYukle(
                                    file: f,
                                    klasor: 'gelistirme/hata_bildirim',
                                    isim: mZaman,
                                  );
                                  resimler.add(sonuc);
                                }
                              }

                              Firestore.instance
                                  .collection('gelistirme')
                                  .document('hata')
                                  .collection('icerik')
                                  .add({
                                'baslik': _baslik,
                                'aciklama': _aciklama,
                                'tarih': FieldValue.serverTimestamp(),
                                'yayinlayan': Fonksiyon.uye.uid,
                                'yayinlayan_adi': Fonksiyon.uye.gorunenIsim,
                                'onay': Fonksiyon.admin(),
                                'begenme': 0,
                                'katilanlar': [],
                                'resimler': resimler
                              }).whenComplete(() => setState(() {
                                        _baslik = "";
                                        _aciklama = "";
                                        _isleniyor = false;
                                        Navigator.pop(context);
                                        Fluttertoast.showToast(
                                          msg:
                                              'Bildirdiğiniz hatalar yöneticiler tarafından kontrol edilmek üzere sunucuya gönderildi. İncelemeden sonra yayınlanacaktır.',
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
