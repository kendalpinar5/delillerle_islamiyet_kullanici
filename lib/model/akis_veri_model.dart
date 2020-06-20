import 'package:cloud_firestore/cloud_firestore.dart';

class AkisVeri {
  String id;
  String baslik;
  String aciklama;
  String kategori;
  String resim;
  String ekleyen;
  List paylasanlar;
  List begenenler;
  List begenmeyenler;
  int okunma;
  int cevapSayisi;
  bool onay;
  Timestamp tarih;

  AkisVeri({
    this.id,
    this.baslik,
    this.aciklama,
    this.kategori,
    this.resim,
    this.ekleyen,
    this.paylasanlar,
    this.begenenler,
    this.begenmeyenler,
    this.okunma,
    this.cevapSayisi,
    this.onay,
    this.tarih,
  });

  AkisVeri.fromMap(Map<String, dynamic> veri)
      : this(
          id: veri['id'],
          baslik: veri['baslik'],
          aciklama: veri['aciklama'],
          kategori: veri['kategori'],
          resim: veri['resim'],
          ekleyen: veri['ekleyen'],
          paylasanlar: veri['paylasanlar'],
          begenenler: veri['begenenler'],
          begenmeyenler: veri['begenmeyenler'],
          okunma: veri['okunma'],
          cevapSayisi: veri['cevapSayisi'],
          onay: veri['onay'],
          tarih: veri['tarih'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'baslik': this.baslik,
        'aciklama': this.aciklama,
        'kategori': this.kategori,
        'resim': this.resim,
        'ekleyen': this.ekleyen,
        'paylasanlar': this.paylasanlar??[],
        'begenenler': this.begenenler??[],
        'begenmeyenler': this.begenmeyenler??[],
        'okunma': this.okunma??0,
        'cevapSayisi': this.cevapSayisi??0,
        'onay': this.onay??false,
        'tarih': this.tarih,
      };
}
