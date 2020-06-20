class HamUye {
  String uid;
  String resim;
  String gorunenIsim;
  String email;
  String il;
  int rutbe;

  HamUye({
    this.uid,
    this.resim,
    this.gorunenIsim,
    this.email,
    this.il,
    this.rutbe,
  });

  HamUye.fromJson(Map json) {
    uid = json['uid'];
    resim = json['resim'];
    gorunenIsim = json['gorunen_isim'];
    email = json['email'];
    il = json['il'] ?? "";
    rutbe = json['rutbe'];
  }

  Map toJson() {
    final Map data = Map();
    data['uid'] = this.uid;
    data['resim'] = this.resim;
    data['gorunen_isim'] = this.gorunenIsim;
    data['email'] = this.email;
    data['il'] = this.il ?? "";
    data['rutbe'] = this.rutbe;
    return data;
  }
}
