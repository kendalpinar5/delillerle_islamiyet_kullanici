import 'package:cloud_firestore/cloud_firestore.dart';

class Soru {
  String id;
  String konuId;
  String ekleyen;
  Timestamp tarih;
  String baslik;
  String aciklama;
  int begenme;
  int begenmeme;
  int cevapsayisi;

  Soru({
    this.id,
    this.konuId,
    this.ekleyen,
    this.tarih,
    this.baslik,
    this.aciklama,
    this.begenme,
    this.begenmeme,
    this.cevapsayisi,
  });

  Soru.fromMap(Map<String, dynamic> veri)
      : this(
          id: veri['id'],
          konuId: veri['konuid'],
          ekleyen: veri['ekleyen'],
          tarih: veri['tarih'],
          baslik: veri['baslik'],
          aciklama: veri['aciklama'],
          begenme: veri['begenme'],
          begenmeme: veri['begenmeme'],
          cevapsayisi: veri['cevapsayisi'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'konuid': this.konuId,
        'ekleyen': this.ekleyen,
        'tarih': this.tarih,
        'baslik': this.baslik,
        'aciklama': this.aciklama,
        'begenme': this.begenme ?? 0,
        'begenmeme': this.begenmeme ?? 0,
        'cevapsayisi': this.cevapsayisi ?? 0,
      };
}
