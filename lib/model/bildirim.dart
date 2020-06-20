import 'package:cloud_firestore/cloud_firestore.dart';

class Bildirim {
  String id;
  String gonderen;
  String alici;
  String tur;
  String baslik;
  String aciklama;
  Timestamp tarih;

  Bildirim({
    this.id,
    this.gonderen,
    this.alici,
    this.tur,
    this.baslik,
    this.aciklama,
    this.tarih,
  });

  Bildirim.fromMap(Map<String, dynamic> veri)
      : this(
          id: veri['id'],
          gonderen: veri['gonderen'],
          alici: veri['alici'],
          tur: veri['tur'],
          baslik: veri['baslik'] ?? '',
          aciklama: veri['aciklama'] ?? '',
          tarih: veri['tarih'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'gonderen': this.gonderen,
        'alici': this.alici,
        'tur': this.tur ?? "",
        'baslik': this.baslik ?? '',
        'aciklama': this.aciklama ?? '',
        'tarih': this.tarih ?? Timestamp.now(),
      };
}
