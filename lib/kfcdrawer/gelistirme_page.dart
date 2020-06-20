import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/gelistirme/gelistirme.dart';
import 'package:delillerleislamiyet/kfcdrawer/kf_drawer_controller.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';

class GelistirmePage extends KFDrawerContent {
  @override
  _GelistirmePageState createState() => _GelistirmePageState();
}

class _GelistirmePageState extends State<GelistirmePage> {
  @override
  Widget build(BuildContext context) {
    Fonksiyon.anasayfa = false;
    return Gelistirme(menum: widget.onMenuPressed);
  }
}
