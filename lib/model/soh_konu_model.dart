import 'package:cloud_firestore/cloud_firestore.dart';

class SohKonular {
  String konuId;
  String konuKitapId;
  String konuBaslik;
  String konuAciklama;
  String konuResim;
  String konuSes;
  String konuEkleyen;
  int okunma;
  Timestamp konuTarih;

  SohKonular(
      {this.konuId,
      this.konuKitapId,
      this.konuBaslik,
      this.konuAciklama,
      this.konuResim,
      this.konuSes,
      this.konuEkleyen,
      this.okunma,
      this.konuTarih});

  SohKonular.fromMap(Map<String, dynamic> json)
      : this(
          konuId: json['konu_id'],
          konuKitapId: json['konu_kitap_id'],
          konuBaslik: json['konu_baslik'],
          konuAciklama: json['konu_aciklama'],
          konuResim: json['konu_resim'],
          konuSes: json['konu_ses'],
          konuEkleyen: json['konu_ekleyen'],
          okunma: json['okunma'],
          konuTarih: json['konu_tarih'],
        );

  Map<String, dynamic> toMap() => {
        'konu_id': this.konuId,
        'konu_kitap_id': this.konuKitapId,
        'konu_baslik': this.konuBaslik,
        'konu_aciklama': this.konuAciklama,
        'konu_resim': this.konuResim,
        'konu_ses': this.konuSes,
        'konu_ekleyen': this.konuEkleyen,
        'okunma': this.okunma,
        'konu_tarih': this.konuTarih,
      };
}
