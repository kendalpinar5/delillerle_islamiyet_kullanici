import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/grup.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/yeni_grup/yeni_grup_detay.dart';

class GrupWidget extends StatelessWidget {
  final Grup grup;
  final Box kutu;
  final Function yenile;

  const GrupWidget({Key key, @required this.grup, @required this.kutu, this.yenile}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final double genislik = Fonksiyon.ekran.width;
    return InkWell(
      onLongPress: () {
        /*  Navigator.pushNamed(
          context,
          '/grup_detay',
          arguments: {"grup": grup},
        ); */
      },
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) {
          return YeniGrupDetay(
            grup: grup,
            kutu: kutu,
            yenile: yenile,
          );
        }));
      },
      child: Container(
        margin: grup.katilimcilar.contains(Fonksiyon.uye.uid) ? EdgeInsets.all(5.0) : EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: genislik / 4,
                    alignment: Alignment.center,
                    child: CachedNetworkImage(
                      width: genislik / 2,
                      imageUrl: grup.resim ?? Linkler.grupThumbResim,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (grup.resim == null)
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (String s in grup.baslik.split(' '))
                            Text(
                              s,
                              style: TextStyle(
                                fontSize: genislik / 20,
                                fontWeight: FontWeight.w500,
                                color: Renk.beyaz,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Renk.gKirmizi.withAlpha(180),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.people, size: 16.0),
                            Text(
                              grup.katilimcisayisi,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Renk.beyaz,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              width: double.maxFinite,
              child: Text(
                grup.baslik.toUpperCase(),
                style: TextStyle(
                  fontSize: genislik / 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                grup.anahtarkelimeler,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  fontSize: genislik / 35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
