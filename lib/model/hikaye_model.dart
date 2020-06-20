import 'package:cloud_firestore/cloud_firestore.dart';

class Hikaye {
  String id;
  String ekleyen;
  List resim;
  Timestamp tarih;

  int goruntulenme;
  bool onay;

  Hikaye({
    this.id,
    this.ekleyen,
    this.resim,
    this.tarih,
    this.goruntulenme,
    this.onay,
  });

  Hikaye.fromMap(Map<String, dynamic> veri)
      : this(
          id: veri['id'],
          ekleyen: veri['ekleyen'],
          resim: veri['resim'],
          tarih: veri['tarih'],
          goruntulenme: veri['goruntulenme'],
          onay: veri['onay'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'ekleyen': this.ekleyen,
        'resim': this.resim,
        'tarih': this.tarih,
        'goruntulenme': this.goruntulenme ?? 0,
        'onay': this.onay ?? false,
      };
}
