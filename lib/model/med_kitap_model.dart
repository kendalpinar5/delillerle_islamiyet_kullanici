import 'package:cloud_firestore/cloud_firestore.dart';

class MedKitaplar {
  String kitapId;
  String kitapAdi;
  String kitapBaslik;
  String kitapAciklama;
  String kitapResim;
  String kitapEkleyen;
  int durum;
  int konSayisi;
  Timestamp kitapTarih;

  MedKitaplar(
      {this.kitapId,
      this.kitapAdi,
      this.kitapBaslik,
      this.kitapAciklama,
      this.kitapResim,
      this.kitapEkleyen,
      this.durum,
      this.konSayisi,
      this.kitapTarih});

  MedKitaplar.fromMap(Map<String, dynamic> json)
      : this(
          kitapId: json['kitap_id'],
          kitapAdi: json['kitap_adi'],
          kitapBaslik: json['kitap_baslik'],
          kitapAciklama: json['kitap_aciklama'],
          kitapResim: json['kitap_resim'],
          kitapEkleyen: json['kitap_ekleyen'],
          durum: json['durum'],
          konSayisi: json['konSayisi'],
          kitapTarih: json['kitap_tarih'],
        );

  Map<String, dynamic> toMap() => {
        'kitap_id': this.kitapId,
        'kitap_adi': this.kitapAdi,
        'kitap_baslik': this.kitapBaslik,
        'kitap_aciklama': this.kitapAciklama,
        'kitap_resim': this.kitapResim,
        'kitap_ekleyen': this.kitapEkleyen,
        'durum': this.durum,
        'konSayisi': this.konSayisi,
        'kitap_tarih': this.kitapTarih,
      };
}
