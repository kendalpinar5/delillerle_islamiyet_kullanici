import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/anasayfa/anasayfa_widget.dart';
import 'package:delillerleislamiyet/forum/forum_syf.dart';
import 'package:delillerleislamiyet/medrese/medrese.dart';
import 'package:delillerleislamiyet/sohbetler/sohbetler.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class AnaSayfa extends StatefulWidget {
  final Function menum;

  const AnaSayfa({Key key, this.menum}) : super(key: key);
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _currentIndex = 0;
  List<Widget> _navWidgets;
  Box _kutu;

  Future<Box> _kutuAc() async {
    if (Hive.isBoxOpen('anasayfa')) {
      _kutu = Hive.box('anasayfa');
      return Future.value(_kutu);
    } else {
      _kutu = await Hive.openBox('anasayfa');
      return _kutu;
    }
  }

  @override
  void dispose() {
    _kutu.compact();
    _kutu.close();

    super.dispose();
  }

  @override
  void initState() {
    Logger.log('tag', message: 'ana');
    _navWidgets = <Widget>[
      AnasayfaWidget(menum: widget.menum),
      ForumSyf(),
      Sohbetler(),
      MedKitap(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex == 0)
          return true;
        else {
          _currentIndex = 0;
          setState(() {});
          return false;
        }
      },
      child: Scaffold(
        body: FutureBuilder(
            future: _kutuAc(),
            builder: (context, snapshot) {
              
              if (snapshot.hasData) {
                return _navWidgets[_currentIndex];
              }

              if (!Hive.isBoxOpen('anasayfa'))
                return CardListSkeleton(
                  style: SkeletonStyle(
                      theme: SkeletonTheme.Light,
                      isShowAvatar: true,
                      isCircleAvatar: true,
                      barCount: 3,
                      borderRadius: BorderRadius.circular(10)),
                );

              return Center();
            }),
        bottomNavigationBar: SizedBox(
          height: 55.0,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            fixedColor: Renk.beyaz,
            unselectedItemColor: Renk.gGri19,
            currentIndex: _currentIndex,
            onTap: (int i) {
              _currentIndex = i;
              setState(() {});
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                backgroundColor: Renk.gGri,
                icon: Icon(Icons.home),
                title: Text(
                  'AnaSayfa',
                  style: TextStyle(color: Renk.beyaz),
                ),
              ),
              BottomNavigationBarItem(
                backgroundColor: Renk.gGri,
                icon: Icon(/* Icons.search */ FontAwesomeIcons.comments),
                title: Text(
                  /* Yazi.arama */ 'Münazara',
                  style: TextStyle(color: Renk.beyaz),
                ),
              ),
              BottomNavigationBarItem(
                backgroundColor: Renk.gGri,
                icon: Icon(Icons.music_note),
                title: Text(
                  "Sohbet Oku/Dinle",
                  style: TextStyle(color: Renk.beyaz),
                ),
              ),
              BottomNavigationBarItem(
                backgroundColor: Renk.gGri,
                icon: Icon(FontAwesomeIcons.bookOpen),
                title: Text(
                  "Medrese",
                  style: TextStyle(color: Renk.beyaz),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
