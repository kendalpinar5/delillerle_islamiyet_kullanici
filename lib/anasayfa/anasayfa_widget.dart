import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/akis_sayfasi/akis_sayfasi.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/bildirimler/bildirimler.dart';
import 'package:delillerleislamiyet/anasayfa/tabs/takip/takip.dart';
import 'package:delillerleislamiyet/anasayfa/widgets/colored_tab_bar.dart';
import 'package:delillerleislamiyet/grup/gruplar.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/utils/yazilar.dart';
import 'package:delillerleislamiyet/uyelik/profil_syf.dart';

class AnasayfaWidget extends StatefulWidget {
  final Function menum;

  const AnasayfaWidget({Key key, this.menum}) : super(key: key);

  @override
  _AnasayfaWidgetState createState() => _AnasayfaWidgetState();
}

class _AnasayfaWidgetState extends State<AnasayfaWidget> {
  final String tag = "AnasayfaWidget";

  bool bit = true;

  
  @override
  void initState() {
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            backgroundColor: Renk.beyaz,
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Renk.wpKoyu,
              ),
              onPressed: widget.menum,
            ),
            title: Row(
              children: <Widget>[
                Spacer(),
                Text(
                  'Delillerle',
                  style: TextStyle(color: Renk.wpKoyu),
                ),
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                      color: Renk.beyaz,
                      border: Border.all(color: Renk.wpKoyu, width: 1),
                      borderRadius: BorderRadius.circular(50)),
                  child: Image.asset(
                    'assets/images/icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  'İslamiyet',
                  style: TextStyle(color: Renk.wpKoyu),
                ),
                Spacer()
              ],
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilSyf()),
                  );
                },
                icon: Icon(
                  Icons.account_circle,
                  color: Renk.wpKoyu,
                ),
                tooltip: Yazi.profil,
              ),
            ],
            bottom: ColoredTabBar(
              Renk.beyaz,
              TabBar(
                labelColor: Renk.wpKoyu,
                unselectedLabelColor: Renk.siyah.withOpacity(0.5),
                indicatorColor: Renk.wpKoyu,
                indicatorWeight: 2.0,
                tabs: <Widget>[
                  Tab(
                    child: FittedBox(
                      child: Text(
                        "AKIŞ",
                        style: TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      child: Text(
                        'Takip',
                        style: TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      child: Text(
                        'Bildirimler',
                        style: TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      child: Text(
                        'Guruplar',
                        style: TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body:  Container(
                  child: TabBarView(
                    children: <Widget>[
                      AkisSayfasi(),
                      Takip(),
                      Bildirimler(
                      ),
                      Gruplar(),
                      //Ajandam(),
                      //YaziTura(),
                    ],
                  ),
                )


        /*  floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => AkisVeriEkle()));
        },
        child: Icon(Fonksiyon.admin() ? Icons.add : Icons.send),
        foregroundColor: Colors.black,
        mini: true,
      ),
      floatingActionButtonLocation: Fonksiyon.admin()
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat, */
      ),
    );
  }
}
