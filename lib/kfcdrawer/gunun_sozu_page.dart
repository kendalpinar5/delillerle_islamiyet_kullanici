import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/kfcdrawer/kf_drawer_controller.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/gunun_sozu/gunun_sozu.dart';

class GununSozuPage extends KFDrawerContent {
  @override
  _GununSozuPageState createState() => _GununSozuPageState();
}

class _GununSozuPageState extends State<GununSozuPage> {
  @override
  Widget build(BuildContext context) {
    Fonksiyon.anasayfa = false;
    return GununSozu(menum: widget.onMenuPressed);
  }
}
