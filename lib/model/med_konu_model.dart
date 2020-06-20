import 'package:cloud_firestore/cloud_firestore.dart';

class MedKonular {
  String konuId;
  String konuKitapId;
  String konuAdi;
  String konuBaslik;
  String konuAciklama;
  String konuAciklama2;
  String konuResim;
  String konuSes;
  String konuEkleyen;
  int okunma;
  int yorumSayisi;
  int konSira;
  Timestamp konuTarih;

  MedKonular(
      {this.konuId,
      this.konuKitapId,
      this.konuAdi,
      this.konuBaslik,
      this.konuAciklama,
      this.konuAciklama2,
      this.konuResim,
      this.konuSes,
      this.konuEkleyen,
      this.okunma,
      this.yorumSayisi,
      this.konSira,
      this.konuTarih});

  MedKonular.fromMap(Map<String, dynamic> json)
      : this(
          konuId: json['konu_id'],
          konuKitapId: json['konu_kitap_id'],
          konuAdi: json['konu_adi'],
          konuBaslik: json['konu_baslik'],
          konuAciklama: json['konu_aciklama'],
          konuAciklama2: json['konu_aciklama2'],
          konuResim: json['konu_resim'],
          konuSes: json['konu_ses'],
          konuEkleyen: json['konu_ekleyen'],
          okunma: json['okunma'],
          yorumSayisi: json['yorumSayisi'] ?? 0,
          konSira: json['konSira'],
          konuTarih: json['konu_tarih'],
        );

  Map<String, dynamic> toMap() => {
        'konu_id': this.konuId,
        'konu_kitap_id': this.konuKitapId,
        'konu_adi': this.konuAdi,
        'konu_baslik': this.konuBaslik,
        'konu_aciklama': this.konuAciklama,
        'konu_aciklama2': this.konuAciklama2,
        'konu_resim': this.konuResim,
        'konu_ses': this.konuSes,
        'konu_ekleyen': this.konuEkleyen,
        'okunma': this.okunma,
        'yorumSayisi': this.yorumSayisi,
        'konSira': this.konSira,
        'konu_tarih': this.konuTarih,
      };
}
