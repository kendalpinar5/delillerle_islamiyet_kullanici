import 'package:cloud_firestore/cloud_firestore.dart';

class GenelKontrol {
  String versiyon;
  String serverToken;
  Timestamp tarih;
  int uyeSayisi;
  int grupSayisi;
  int etkinlikSayisi;
  int fKonuSayisi;
  int fSoruSayisi;
  int fCevapSayisi;
  int versiyonKodu;
  int versiyonTavsiye;
  int versiyonZorunlu;
  bool betaTest;

  GenelKontrol({
    this.versiyon,
    this.serverToken,
    this.tarih,
    this.uyeSayisi,
    this.grupSayisi,
    this.etkinlikSayisi,
    this.fKonuSayisi,
    this.fSoruSayisi,
    this.fCevapSayisi,
    this.versiyonKodu,
    this.versiyonTavsiye,
    this.versiyonZorunlu,
    this.betaTest,
  });

  GenelKontrol.fromMap(Map<String, dynamic> veri)
      : this(
          versiyon: veri['versiyon'],
          serverToken: veri['server_token'],
          tarih: veri['tarih'],
          uyeSayisi: veri['uye_sayisi'],
          grupSayisi: veri['grup_sayisi'],
          etkinlikSayisi: veri['etkinlik_sayisi'],
          fKonuSayisi: veri['f_konu_sayisi'],
          fSoruSayisi: veri['f_soru_sayisi'],
          fCevapSayisi: veri['f_cevap_sayisi'],
          versiyonKodu: veri['versiyon_kodu'],
          versiyonTavsiye: veri['versiyon_tavsiye'],
          versiyonZorunlu: veri['versiyon_zorunlu'],
          betaTest: veri['beta_test'],
        );

  Map<String, dynamic> toMap() => {
        'versiyon': this.versiyon ?? "1.1.0",
        'server_token': this.serverToken,
        'tarih': this.tarih ?? Timestamp.now(),
        'uye_sayisi': this.uyeSayisi ?? 0,
        'grup_sayisi': this.grupSayisi ?? 0,
        'etkinlik_sayisi': this.etkinlikSayisi ?? 0,
        'f_konu_sayisi': this.fKonuSayisi ?? 0,
        'f_soru_sayisi': this.fSoruSayisi ?? 0,
        'f_cevap_sayisi': this.fCevapSayisi ?? 0,
        'versiyon_kodu': this.versiyonKodu ?? 0,
        'versiyon_tavsiye': this.versiyonTavsiye ?? 0,
        'versiyon_zorunlu': this.versiyonZorunlu ?? 0,
        'beta_test': this.betaTest,
      };
}
