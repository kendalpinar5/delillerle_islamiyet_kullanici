import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delillerleislamiyet/model/ham_uye.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/linkler.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class KullaniciListeOge extends StatefulWidget {
  final HamUye user;

  const KullaniciListeOge({Key key, this.user}) : super(key: key);

  @override
  _KullaniciListeOgeState createState() => _KullaniciListeOgeState();
}

class _KullaniciListeOgeState extends State<KullaniciListeOge> {
  void _resmiGor() {
    Fonksiyon.resmiGor(
      context,
      widget.user.resim ?? Linkler.thumbResim,
      "${widget.user.gorunenIsim}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Renk.gKirmizi, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: _resmiGor,
            onLongPress: () {
              Fonksiyon.kullaniciEngelle(context, widget.user.uid);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                color: Renk.beyaz,
                height: 35,
                width: 35,
                child: CachedNetworkImage(
                  imageUrl: widget.user.resim ?? Linkler.thumbResim,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              "${widget.user.gorunenIsim}",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
