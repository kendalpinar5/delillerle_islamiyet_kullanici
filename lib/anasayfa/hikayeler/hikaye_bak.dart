import 'package:delillerleislamiyet/profil_ex/profil_ex.dart';
import 'package:delillerleislamiyet/uyelik/profil_syf.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/model/hikaye_model.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/logger.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'dart:async';
import 'package:percent_indicator/percent_indicator.dart';

class HikayeBak extends StatefulWidget {
  final Hikaye gHik;
  final Uye gUye;

  const HikayeBak({Key key, this.gHik, this.gUye}) : super(key: key);
  @override
  _HikayeBakState createState() => _HikayeBakState();
}

class _HikayeBakState extends State<HikayeBak> {
  int _start = 0;
  int sayi = 0;
  Timer _timer;

  void startTimer() {
    _start = 0;
    Logger.log('sayi', message: _start.toString());
    const oneSec = const Duration(milliseconds: 100);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start > 450) {
            if (sayi + 1 != widget.gHik.resim.length) {
              sayi++;
              timer.cancel();

              startTimer();
            } else {
              timer.cancel();
              Navigator.pop(context);
            }
          } else {
            _start = _start + 10;
          }

          Logger.log('tag', message: _start.toString());
        },
      ),
    );
  }

  @override
  void initState() {
    startTimer();

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Renk.siyah,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: 10),
                child: LinearPercentIndicator(
                  backgroundColor: Renk.siyah,
                  fillColor: Renk.siyah,
                  width: (MediaQuery.of(context).size.width - 30),
                  lineHeight: 5.0,
                  percent: _start / 500,
                  progressColor: Renk.beyaz,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _timer.cancel();

                if (widget.gUye.uid == Fonksiyon.uye.uid)
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilSyf()));
                else
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilSyfEx(gUye: widget.gUye)));
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 60,
                      width: 60,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Renk.beyaz, width: 2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          image: DecorationImage(
                              image: NetworkImage(
                                widget.gUye.resim,
                              ),
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 3, left: 4),
                          alignment: Alignment.centerLeft,
                          child: widget.gUye == null
                              ? Center(
                                  child: LinearProgressIndicator(),
                                )
                              : Text(
                                  widget.gUye.gorunenIsim,
                                  style: TextStyle(
                                    color: Renk.beyaz,
                                    fontWeight: FontWeight.normal,
                                    fontSize: MediaQuery.of(context).size.width / 25,
                                  ),
                                ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: widget.gUye == null
                              ? Center(
                                  child: LinearProgressIndicator(),
                                )
                              : Text(
                                  "${Fonksiyon.zamanFarkiBul(widget.gHik.tarih.toDate())} önce",
                                  style: TextStyle(
                                    color: Renk.beyaz,
                                    fontWeight: FontWeight.normal,
                                    fontSize: MediaQuery.of(context).size.width / 28,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(children: <Widget>[
                Container(
                  width: double.maxFinite,
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        widget.gHik.resim[sayi],
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (sayi - 1 != -1) {
                              sayi--;
                              _timer.cancel();
                              startTimer();
                            } else {}
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (sayi + 1 != widget.gHik.resim.length) {
                              sayi++;
                              _timer.cancel();
                              startTimer();
                            } else {
                              _timer.cancel();
                              Navigator.pop(context);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                )
              ]),
            ),
            Column(
              children: <Widget>[
                Align(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(
                          'Toplam:',
                          style: TextStyle(color: Renk.beyaz),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.gHik.goruntulenme.toString(),
                          style: TextStyle(color: Renk.beyaz),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(
                          'görüntülenme',
                          style: TextStyle(color: Renk.beyaz),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int i = 0; i < widget.gHik.resim.length; i++)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                            color: sayi == i ? Renk.wpAcik : Renk.beyaz.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(50)),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
