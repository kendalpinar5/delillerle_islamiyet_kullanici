import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/anasayfa/anasayfa.dart';
import 'package:delillerleislamiyet/kfcdrawer/kf_drawer_controller.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';

class MainPage extends KFDrawerContent {
  MainPage({Key key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    Fonksiyon.anasayfa = true;
    return AnaSayfa(menum: widget.onMenuPressed);
  }
}
