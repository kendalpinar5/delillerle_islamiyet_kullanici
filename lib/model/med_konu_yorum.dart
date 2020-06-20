import 'package:cloud_firestore/cloud_firestore.dart';

class MedKonuYorum {
  String id;
  String veriId;
  String ekleyen;
  Timestamp tarih;
  String cevap;
  String verilenCevap;
  int begenme;
  int begenmeme;


  MedKonuYorum({
    this.id,
    this.veriId,
    this.ekleyen,
    this.tarih,
    this.cevap,
    this.verilenCevap,
    this.begenme,
    this.begenmeme,
  });

  MedKonuYorum.fromMap(Map<String, dynamic> veri)
      : this(
          id: veri['id'],
          veriId: veri['veriId'],
          ekleyen: veri['ekleyen'],
          tarih: veri['tarih'],
          cevap: veri['cevap'],
          verilenCevap: veri['verilenCevap'],
          begenme: veri['begenme'],
          begenmeme: veri['begenmeme'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'veriId': this.veriId,
        'ekleyen': this.ekleyen,
        'tarih': this.tarih,
        'cevap': this.cevap,
        'verilenCevap': this.verilenCevap,
        'begenme': this.begenme ?? 0,
        'begenmeme': this.begenmeme ?? 0,
      };
}
