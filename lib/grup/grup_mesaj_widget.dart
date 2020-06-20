import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/mesaj.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'grup_anket.dart';

class GrupMesajWidget extends StatelessWidget {
  final Mesaj msj;
  final Function resmiGor;
  final Size ekran;

  const GrupMesajWidget({
    Key key,
    @required this.msj,
    @required this.resmiGor,
    @required this.ekran,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool ben = msj.yazan == Fonksiyon.uye.uid;
    Widget resim = CachedNetworkImage(
      imageUrl: msj.resim,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: BoxFit.cover,
    );

    DateTime time = msj.tarih?.toDate() ?? DateTime.now();
    return msj.yazan == "cloud_system"
        ? Center(
            child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              msj.metin,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Renk.gGri19,
                fontWeight: FontWeight.w500,
              ),
            ),
          ))
        : Container(
            alignment: ben ? Alignment.centerRight : Alignment.centerLeft,
            margin: EdgeInsets.only(
              right: ben ? 0.0 : 20.0,
              left: ben ? 20.0 : 0.0,
            ),
            child: IntrinsicWidth(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (!ben)
                    Container(
                      width: 32.0,
                      height: 32.0,
                      margin: EdgeInsets.only(top: 12.0),
                      child: InkWell(
                        onLongPress: () =>
                            Fonksiyon.kullaniciEngelle(context, msj.yazan),
                        onTap: () {
                          Fonksiyon.resmiGor(
                            context,
                            msj.yazanRsm ?? Linkler.thumbResim,
                            msj.gonderen,
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: msj.yazanRsm ?? Linkler.thumbResim,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: ben ? Renk.yesil2.withAlpha(80) : Renk.beyaz,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ben ? 10 : 0),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(ben ? 0 : 10),
                        ),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: Column(
                              children: <Widget>[
                                if (!ben) SizedBox(height: 18),
                                msj.resim.length > 0 && msj.metin == "resim"
                                    ? SizedBox(
                                        height: ekran.height / 4,
                                        child: InkWell(
                                          onTap: () => resmiGor(msj),
                                          child: resim,
                                        ),
                                      )
                                    : msj.anket.length > 0 &&
                                            msj.metin == "anket"
                                        ? Opacity(
                                            opacity: 0,
                                            child: GrupAnket(mesaj: msj),
                                          )
                                        : msj.metin == "konum"
                                            ? SizedBox(
                                                height: ekran.height / 4,
                                               /*  child: InkWell(
                                                  onTap: () => launch(
                                                    "https://www.google.com/maps/search/?api=1&query=${msj.enlem},${msj.boylam}",
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        "https://maps.googleapis.com/maps/api/staticmap?center=${msj.enlem},${msj.boylam}&zoom=17&size=600x300&maptype=roadmap&markers=color:red%7C${msj.enlem},${msj.boylam}&key=${Fonksiyon.staticMapApiKey}",
                                                    placeholder:
                                                        (context, url) =>
                                                            Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ), */
                                              )
                                            : Text(
                                                "${msj.metin}",
                                                style: TextStyle(
                                                  color: Color(0),
                                                ),
                                              ),
                                Row(
                                  children: <Widget>[
                                    if (msj.anket.length > 0 &&
                                        msj.metin == "anket")
                                      Text(
                                        "${msj.anket[0]['oy_sayisi']} Oy",
                                        style: TextStyle(
                                          color: Renk.gGri,
                                          fontSize: 10.0,
                                        ),
                                      ),
                                    Spacer(),
                                    SizedBox(height: 19),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                height: ben ? 0.0 : null,
                                child: Text(
                                  "${ben ? Fonksiyon.zamanFarkiBul(time) + ' önce' : msj.gonderen}",
                                  style: TextStyle(
                                    color: Color(
                                      0xFF000000 + msj.gonderen.length * 100000,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(height: 18),
                              SizedBox(height: 18),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              if (!ben) SizedBox(height: 19),
                              msj.resim.length > 0 && msj.metin == "resim"
                                  ? SizedBox(
                                      height: ekran.height / 4,
                                      child: InkWell(
                                        onTap: () => resmiGor(msj),
                                        child: resim,
                                      ),
                                    )
                                  : msj.anket.length > 0 && msj.metin == "anket"
                                      ? GrupAnket(mesaj: msj)
                                      : msj.metin == "konum"
                                          ? AspectRatio(
                                              aspectRatio: 1.5,
                                              child: SizedBox(
                                                height: ekran.height / 4,
                                              ),
                                            )
                                          : Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text("${msj.metin}"),
                                            ),
                              Container(
                                margin: EdgeInsets.only(top: 7.0),
                                child: Text(
                                  "${Fonksiyon.zamanFarkiBul(time)} önce",
                                  style: TextStyle(
                                    color: Renk.gGri,
                                    fontSize: 10.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
