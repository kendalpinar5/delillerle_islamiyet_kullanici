import 'package:cloud_firestore/cloud_firestore.dart';

class Cevap {
  String id;
  String soruId;
  String ekleyen;
  Timestamp tarih;
  String cevap;
  int begenme;
  int begenmeme;

  Cevap({
    this.id,
    this.soruId,
    this.ekleyen,
    this.tarih,
    this.cevap,
    this.begenme,
    this.begenmeme,
  });

  Cevap.fromMap(Map<String, dynamic> veri)
      : this(
          id: veri['id'],
          soruId: veri['soruid'],
          ekleyen: veri['ekleyen'],
          tarih: veri['tarih'],
          cevap: veri['cevap'],
          begenme: veri['begenme'],
          begenmeme: veri['begenmeme'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'soruid': this.soruId,
        'ekleyen': this.ekleyen,
        'tarih': this.tarih,
        'cevap': this.cevap,
        'begenme': this.begenme ?? 0,
        'begenmeme': this.begenmeme ?? 0,
      };
}
