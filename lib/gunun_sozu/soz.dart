import 'package:cloud_firestore/cloud_firestore.dart';

class Soz {
  String id;
  String baslik;
  String soz;
  Timestamp tarih;
  String yazar;
  String paylasan;
  int paylasma;
  List begenme;
  List begenmeme;
  bool onay;

  Soz({
    this.id,
    this.baslik,
    this.soz,
    this.tarih,
    this.yazar,
    this.paylasan,
    this.paylasma,
    this.begenme,
    this.begenmeme,
    this.onay,
  });

  Soz.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    baslik = json['baslik'];
    soz = json['soz'];
    tarih = json['tarih'];
    yazar = json['yazar'];
    paylasan = json['paylasan'];
    paylasma = json['paylasma'] ?? 0;
    begenme = json['begenme'] ?? 0;
    begenmeme = json['begenmeme'] ?? 0;
    onay = json['onay'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['baslik'] = this.baslik;
    data['soz'] = this.soz;
    data['tarih'] = this.tarih;
    data['yazar'] = this.yazar;
    data['paylasan'] = this.paylasan;
    data['paylasma'] = this.paylasma ?? 0;
    data['begenme'] = this.begenme ?? [];
    data['begenmeme'] = this.begenmeme ?? [];
    data['onay'] = this.onay ?? false;
    return data;
  }
}
