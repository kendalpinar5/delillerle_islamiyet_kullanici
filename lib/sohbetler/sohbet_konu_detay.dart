import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:delillerleislamiyet/model/soh_konu_model.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

class SohKonuDetay extends StatefulWidget {
  final SohKonular gKonu;
  final String gKonuResim;

  const SohKonuDetay({Key key, this.gKonu, this.gKonuResim}) : super(key: key);

  @override
  _SohKonuDetayState createState() => _SohKonuDetayState();
}

class _SohKonuDetayState extends State<SohKonuDetay> {
  int konum = 0;

  bool isPlay = false;
  double volume = 1.0;

  String toplamYazi = "0:00:00:00";
  String anlikYazi = "0:00:00:00";

  int toplamSure = 0;
  int anlikSure = 0;

  double slide = 0.0;
  int textSize = 16;
  AudioPlayer advancedPlayer = new AudioPlayer();
  ScrollController _scrollController;
  void boyutArttir() {
    textSize++;
    setState(() {});
  }

  void boyutAzalt() {
    textSize--;
    setState(() {});
  }

  /*  void _konumGetir() {
    if (widget.nerden == "yerimi") {
      _scrollController =
          ScrollController(initialScrollOffset: widget.sohbetKonum.toDouble());
    }
  } */

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    //  _konumGetir();
  }

  playPause() {
    if (isPlay) {
      setState(() {
        advancedPlayer.pause();
        isPlay = false;
      });
    } else {
      setState(() {
        advancedPlayer
            .play(
                "http://malibayram.com/flutterdilillerle/admin/audio/sohbet/" +
                    widget.gKonu.konuSes)
            .then((onValue) {
          advancedPlayer.setVolume(volume);

          debugPrint(onValue.toString());

          advancedPlayer.durationHandler = (Duration d) {
            toplamYazi = d.toString();
            toplamSure = d.inMilliseconds;

            setState(() {});
            debugPrint("Toplam ${d.inMilliseconds}");
          };

          advancedPlayer.positionHandler = (Duration d) {
            anlikYazi = d.toString();
            anlikSure = d.inMilliseconds;

            debugPrint("${anlikSure / toplamSure}");

            slide = (anlikSure / toplamSure);

            if (anlikSure >= toplamSure - 1000) {
              advancedPlayer.stop();
              anlikSure = 0;
              toplamSure = 0;
              slide = 0.0;
              isPlay = false;
            }
            setState(() {});

            debugPrint("Anlik ${d.inMilliseconds} $anlikSure $slide");
          };
        });

        isPlay = true;
      });
    }
  }

/*   void sonKaldigimYer() async {
    final sonKaldigimYer = await SharedPreferences.getInstance();
    sonKaldigimYer.setString("kitId", widget.kitId);
    sonKaldigimYer.setString("konuId", widget.konuId);
    sonKaldigimYer.setString("konuBaslik", widget.konuBaslik);
    sonKaldigimYer.setString("konuResim", widget.konuResim);
    sonKaldigimYer.setString("konuSes", widget.konuSes);
    sonKaldigimYer.setString("konuAciklama", widget.konuAciklama);
    sonKaldigimYer.setString("konuTarih", widget.konuTarih);
    print("kaydedildi");
  } */

  @override
  void dispose() {
    advancedPlayer.stop();
    _scrollController.dispose();
    isPlay = false;
    //  sonKaldigimYer();
    super.dispose();
  }
/* 
  _sohbetEkle(String nerden) {
    vtYardimcisi
        .sohbetKaydet(
      new SohbetlerVt(
          widget.konuId,
          widget.kitId,
          widget.konuBaslik,
          widget.konuAciklama,
          widget.konuResim,
          widget.konuSes,
          "1",
          nerden.toString(),
          widget.konuTarih,
          nerden == "yerimi" ? konum : 0),
    )
        .then((deger) {
      if (deger > 0) {
        debugPrint(nerden.toString());

        Fluttertoast.showToast(
            msg: nerden == "favori" ? "Favori Eklendi.." : "Yerimi Eklendi..",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xff075E54),
            textColor: Colors.white);
      }
    });
  }

  _sohbetSil(SohbetlerVt sohbet) {
    vtYardimcisi.sohbetSil(sohbet).then((cvp) {
      if (cvp > 0) {
        Fluttertoast.showToast(
            msg: "Yerimi/Favoriniz Silindi..",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    });
  } */

  _paylas() {
    Share.share(widget.gKonu.konuBaslik +
        "\n\n" +
        widget.gKonu.konuAciklama +
        "\n\n" +
        "Delillerle İslamiyet mobil uygulamasını uygulama marketinizden indirebilirsiniz \nIOS : https://itunes.apple.com/app/id1448127736 \nAndroid : https://play.google.com/store/apps/details?id=com.imamgazalikalplerinkesfi");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gKonu.konuBaslik),
        actions: <Widget>[
          /*  widget.nerden != "yerimi"
              ? IconButton(
                  onPressed: () {
                    _sohbetEkle("yerimi");
                  },
                  icon: Icon(Icons.bookmark),
                )
              : Container(), */
        ],
      ),
      body: NotificationListener(
        onNotification: (t) {
          if (t is ScrollEndNotification) {
            print(_scrollController.position.pixels.toInt().toString());
            konum = _scrollController.position.pixels.toInt();
          }
        },
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(3.0),
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 150.0,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            "http://malibayram.com/flutterdilillerle/admin/thumbnails/" +
                                widget.gKonu.konuResim),
                      ),
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.all(3.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: IconButton(
                              color: Colors.black,
                              onPressed: () => boyutAzalt(),
                              icon: Icon(FontAwesomeIcons.searchMinus),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: IconButton(
                              color: Colors.black,
                              onPressed: () => boyutArttir(),
                              icon: Icon(FontAwesomeIcons.searchPlus),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: IconButton(
                              onPressed: _paylas,
                              icon: Icon(Icons.share),
                            ),
                          ),
                        ),
                        /*  Expanded(
                          child: Container(
                               child: IconButton(
                              onPressed: () {
                                widget.nerden == "favori" ||
                                        widget.nerden == "yerimi"
                                    ? _sohbetSil(widget.sohbet)
                                    : _sohbetEkle("favori");
                              },
                              icon: Icon(
                                 widget.nerden == "favori" ||
                                        widget.nerden == "yerimi"
                                    ? Icons.delete
                                    : Icons.favorite_border, 
                              ),
                            ),
                              ),
                        ), */
                        /*  widget.nerden != "favori" && widget.nerden != "yerimi"
                            ? Expanded(
                                child: Container(
                                  child: IconButton(
                                    onPressed: () {
                                      widget.nerden == "favori" ||
                                              widget.nerden == "yerimi"
                                          ? _sohbetSil(widget.sohbet)
                                          : _sohbetEkle("yerimi");
                                    },
                                    icon: Icon(
                                      widget.nerden == "favori" ||
                                              widget.nerden == "yerimi"
                                          ? Icons.delete
                                          : Icons.bookmark_border,
                                    ),
                                  ),
                                ),
                              )
                            : Container(), */
                      ],
                    ),
                  ),
                  widget.gKonu.konuSes != ""
                      ? Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  top: 5.0, left: 5.0, right: 5.0, bottom: 5.0),
                              height: 30.0,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 8.0,
                                    left: 8.0,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Image.asset("assets/images/ses1.png"),
                                      Expanded(
                                        child: Slider(
                                          activeColor: Colors.black,
                                          inactiveColor: Colors.grey.shade400,
                                          value: volume,
                                          onChanged: (newValue) {
                                            setState(() {
                                              volume = newValue;
                                              advancedPlayer.setVolume(volume);
                                            });
                                          },
                                        ),
                                      ),
                                      Image.asset("assets/images/ses2.png"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 5.0, left: 5.0, right: 5.0, bottom: 5.0),
                              height: 30.0,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 8.0,
                                    left: 8.0,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        anlikYazi.substring(2, 7),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          activeColor: Colors.black,
                                          inactiveColor: Colors.grey.shade400,
                                          value: slide,
                                          onChanged: (newValue) {
                                            setState(() {
                                              slide = newValue;
                                              debugPrint("değişiyor");

                                              if (toplamSure > 1) {
                                                advancedPlayer.seek(
                                                    new Duration(
                                                        milliseconds:
                                                            (toplamSure *
                                                                    newValue)
                                                                .toInt()));
                                              } else {
                                                slide = 0.0;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      Text(
                                        toplamYazi.substring(2, 7),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          height: 0.0,
                        ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 5.0, left: 5.0, right: 5.0, bottom: 5.0),
                    child: Card(
                      elevation: 6.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Card(
                              margin: EdgeInsets.only(bottom: 10.0),
                              elevation: 3.0,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  widget.gKonu.konuBaslik,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5.0, bottom: 2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(right: 3.0),
                                    child: Icon(
                                      Icons.date_range,
                                      size: 14.0,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(
                                              widget.gKonu.konuTarih.toDate())
                                          .toString(),
                                      maxLines: 1,
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  right: 20.0, top: 3.0, bottom: 5.0),
                              child: Divider(
                                height: 1.0,
                                color: Colors.black38,
                              ),
                            ),
                            Container(
                              width: double.maxFinite,
                              child: GestureDetector(
                                onLongPress: () {
                                  Clipboard.setData(
                                    new ClipboardData(
                                        text: widget.gKonu.konuAciklama +
                                            "\n\n" +
                                            "Uygulamamızı Marketten indirebilirsiniz.." +
                                            "\n\n" +
                                            "Kalplerin Keşfi İ.Gazali Medrese Dersleri,Münazara"),
                                  );
                                  Fluttertoast.showToast(
                                      msg: "Metin kopyalandı..",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.black54,
                                      textColor: Colors.white);
                                },
                                child: Text(
                                  widget.gKonu.konuAciklama,
                                  style: TextStyle(
                                    fontSize: textSize.toDouble(),
                                  ),
                                ),
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
          ],
        ),
      ),
      floatingActionButton: widget.gKonu.konuSes != ""
          ? new FloatingActionButton(
              backgroundColor: Theme.of(context).accentColor,
              child: new Icon(
                isPlay ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () => playPause(),
            )
          : Container(),
    );
  }
}
