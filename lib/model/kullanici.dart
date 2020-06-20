import 'package:flutter/foundation.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';

class Uye {
  String uid;
  String bildirimjetonu;
  String gorunenIsim;
  String email;
  String referans = "";
  String telefon;
  String resim;
  String unvan;
  String element = "Bronz_5";
  String il;
  String kayitTarih;
  bool telOnay;
  bool engel;
  int rutbe;
  int puan = 0;
  int gonderiSayisi;
  bool gizlilik = false;

  List arkIstekleri;
  List arkadaslar;
  List ilgiAlanlari;
  List gruplar;

  Uye({
    @required this.uid,
    this.bildirimjetonu = "",
    this.gorunenIsim = "isim soyisim",
    this.referans = "",
    @required this.email,
    this.telefon,
    this.resim = Linkler.thumbResim,
    this.unvan = "unvan",
    this.element = "Bronz_5",
    this.il,
    this.kayitTarih,
    this.telOnay = false,
    this.engel = false,
    this.rutbe = 0,
    this.puan = 0,
    this.gonderiSayisi,
    this.ilgiAlanlari,
    this.arkIstekleri,
    this.arkadaslar,
    this.gruplar,
  });

  Uye.fromMap(Map<String, dynamic> veri)
      : this(
          uid: veri['uid'],
          bildirimjetonu: veri['bildirimjetonu'],
          gorunenIsim: veri['gorunen_isim'],
          referans: veri['referans'] ?? "",
          email: veri['email'],
          telefon: veri['telefon'] ?? '',
          resim: veri['resim'],
          unvan: veri['unvan'],
          element: veri['element'] ?? "Bronz_5",
          il: veri['il'] ?? "il",
          kayitTarih: veri['kayitTarih'],
          telOnay: veri['telonay'] ?? false,
          engel: veri['engel'] ?? false,
          rutbe: veri['rutbe'],
          puan: veri['puan'] ?? 0,
          gonderiSayisi: veri['gonderiSayisi'] ?? 0,
          ilgiAlanlari: veri['ilgialanlari'] ?? [],
          arkIstekleri: veri['arkIstekleri'] ?? [],
          arkadaslar: veri['arkadaslar'] ?? [],
          gruplar: veri['gruplar'] ?? [],
        );

  Map<String, dynamic> toMap() => {
        'uid': this.uid,
        'bildirimjetonu': this.bildirimjetonu,
        'gorunen_isim': this.gorunenIsim,
        'referans': this.referans ?? "",
        'email': this.email,
        'telefon': this.telefon ?? '',
        'resim': this.resim,
        'unvan': this.unvan,
        'element': this.element ?? "Bronz_5",
        'il': this.il ?? "il",
        'kayitTarih': this.kayitTarih,
        'telonay': this.telOnay ?? false,
        'engel': this.engel ?? false,
        'rutbe': this.rutbe,
        'puan': this.puan,
        'gonderiSayisi': this.gonderiSayisi,
        'ilgialanlari': this.ilgiAlanlari ?? [],
        'arkIstekleri': this.arkIstekleri ?? [],
        'arkadaslar': this.arkadaslar ?? [],
        'gruplar': this.gruplar ?? [],
      };
}
