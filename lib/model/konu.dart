class Konu {
  String id;
  String baslik;
  String kisaaciklama;
  String resim;
  int renk;
  int sorusayisi;

  Konu({
    this.id,
    this.baslik,
    this.kisaaciklama,
    this.resim,
    this.renk,
    this.sorusayisi,
  });

  Konu.fromMap(Map<String, dynamic> veri, String id) {
    this.id = id;
    this.baslik = veri['baslik'];
    this.kisaaciklama = veri['kisaaciklama'];
    this.resim = veri['resim'];
    this.renk = veri['renk'];
    this.sorusayisi = veri['sorusayisi'];
  }

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'baslik': this.baslik,
        'kisaaciklama': this.kisaaciklama,
        'resim': this.resim,
        'renk': this.renk,
        'sorusayisi': this.sorusayisi,
      };
}
