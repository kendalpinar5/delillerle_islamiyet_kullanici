import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/anasayfa/widgets/colored_tab_bar.dart';
import 'package:delillerleislamiyet/gelistirme/hatalar.dart';
import 'package:delillerleislamiyet/gelistirme/oneriler.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class Gelistirme extends StatelessWidget {
  final Function menum;

  const Gelistirme({Key key, this.menum}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Renk.beyaz,
            ),
            onPressed: menum,
          ),
          title: Text("Görüşleriniz Önemli"),
          bottom: ColoredTabBar(
            Renk.wp,
            TabBar(
              labelColor: Renk.beyaz,
              unselectedLabelColor: Renk.gGri19,
              indicatorColor: Renk.wpAcik,
              indicatorWeight: 4.0,
              tabs: <Widget>[
                
                Tab(
                  child: FittedBox(
                    child: Text(
                      "Hatalar",
                      style: TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    child: Text(
                      "Öneriler",
                      style: TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
           
            Hatalar(),
            Oneriler(),
          ],
        ),
      ),
    );
  }
}
