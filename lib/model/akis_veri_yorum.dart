import 'package:cloud_firestore/cloud_firestore.dart';

class AkisVeriYorum {
  String id;
  String veriId;
  String ekleyen;
  Timestamp tarih;
  String cevap;
  int begenme;
  int begenmeme;


  AkisVeriYorum({
    this.id,
    this.veriId,
    this.ekleyen,
    this.tarih,
    this.cevap,
    this.begenme,
    this.begenmeme,
  });

  AkisVeriYorum.fromMap(Map<String, dynamic> veri)
      : this(
          id: veri['id'],
          veriId: veri['veriId'],
          ekleyen: veri['ekleyen'],
          tarih: veri['tarih'],
          cevap: veri['cevap'],
          begenme: veri['begenme'],
          begenmeme: veri['begenmeme'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'veriId': this.veriId,
        'ekleyen': this.ekleyen,
        'tarih': this.tarih,
        'cevap': this.cevap,
        'begenme': this.begenme ?? 0,
        'begenmeme': this.begenmeme ?? 0,
      };
}
