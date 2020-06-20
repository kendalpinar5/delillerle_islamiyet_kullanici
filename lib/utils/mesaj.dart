class Mesaj {
  String id;
  String yazan;
  String yazanRsm;
  String gonderen;
  String grupid;
  String metin;
  String resim;
  double enlem;
  double boylam;
  List anket;
  List oyVerenler;
  dynamic tarih;

  Mesaj({
    this.id = '',
    this.yazan,
    this.yazanRsm,
    this.gonderen,
    this.grupid,
    this.metin,
    this.resim = '',
    this.enlem = 39.89703,
    this.boylam = 32.86810,
    this.anket = const [],
    this.oyVerenler = const [],
    this.tarih,
  });

  Mesaj.fromMap(Map<String, dynamic> data, String id)
      : this(
          id: id,
          yazan: data['yazan'],
          yazanRsm: data['yazanrsm'],
          gonderen: data['gonderen'],
          grupid: data['grupid'],
          metin: data['metin'],
          resim: data['resim'] ?? '',
          enlem: data['enlem'] ?? 39.89703,
          boylam: data['boylam'] ?? 32.86810,
          anket: data['anket'] ?? [],
          oyVerenler: data['oy_verenler'] ?? [],
          tarih: data['tarih'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id ?? '',
        'yazan': this.yazan,
        'yazanrsm': this.yazanRsm,
        'gonderen': this.gonderen,
        'grupid': this.grupid,
        'metin': this.metin,
        'resim': this.resim,
        'enlem': this.enlem ?? 39.89703,
        'boylam': this.boylam ?? 32.86810,
        'anket': this.anket,
        'oy_verenler': this.oyVerenler,
        'tarih': this.tarih,
      };
}
