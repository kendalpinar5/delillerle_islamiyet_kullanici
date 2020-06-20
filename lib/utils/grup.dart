import 'package:cloud_firestore/cloud_firestore.dart';

class Grup {
  String id;
  String resim;
  String baslik;
  String kisaaciklama;
  String anahtarkelimeler;
  String aciklama;
  String maxkatilimci;
  String katilimcisayisi;
  String olusturan;
  List kurallar;

  List katilimcilar;
  List engellenenler;
  List sesliler;
  List sessizler;

  bool yOnay;
  String il;
  int seviye;
  int ilPlaka;
  Timestamp yTarih;
  FieldValue oTarih;

  Grup({
    this.id,
    this.resim,
    this.baslik,
    this.kisaaciklama,
    this.anahtarkelimeler,
    this.aciklama,
    this.maxkatilimci,
    this.katilimcisayisi,
    this.olusturan,
    this.kurallar,
    this.katilimcilar,
    this.engellenenler,
    this.sesliler,
    this.sessizler,
    this.yOnay,
    this.il,
    this.seviye = 0,
    this.ilPlaka = 0,
    this.yTarih,
    this.oTarih,
  });

  Grup.fromMap(Map<String, dynamic> data, String id)
      : this(
          id: id,
          resim: data['resim'],
          baslik: data['baslik'],
          kisaaciklama: data['kisaaciklama'],
          anahtarkelimeler: data['anahtarkelimeler'],
          aciklama: data['aciklama'],
          maxkatilimci: data['maxkatilimci'],
          katilimcisayisi: data['katilimcisayisi'],
          olusturan: data['olusturan'],
          kurallar: data['kurallar'],
          katilimcilar: data['katilimcilar'] ?? [],
          engellenenler: data['engellenenler'] ?? [],
          sesliler: data['sesliler'] ?? [],
          sessizler: data['sessizler'] ?? [],
          yOnay: data['y_onay'],
          il: data['il'],
          seviye: data['seviye'],
          ilPlaka: data['il_plaka'] ?? 0,
          yTarih: data['yeni_tarih'] ?? Timestamp.now(),
        );

  Map<String, dynamic> toMap() => {
        'resim': this.resim,
        'baslik': this.baslik,
        'kisaaciklama': this.kisaaciklama,
        'anahtarkelimeler': this.anahtarkelimeler,
        'aciklama': this.aciklama,
        'maxkatilimci': this.maxkatilimci,
        'katilimcisayisi': this.katilimcisayisi,
        'olusturan': this.olusturan,
        'kurallar': this.kurallar,
        'katilimcilar': this.katilimcilar ?? [],
        'engellenenler': this.engellenenler ?? [],
        'sesliler': this.sesliler ?? [],
        'sessizler': this.sessizler ?? [],
        'y_onay': this.yOnay,
        'il': this.il ?? "Türkiye",
        'seviye': this.seviye ?? 0,
        'il_plaka': this.ilPlaka ?? 0,
        'yeni_tarih': this.yTarih,
        'olusturma_tarih': this.oTarih,
      };
}
