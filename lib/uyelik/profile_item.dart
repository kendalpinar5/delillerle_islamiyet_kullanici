import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class ProfileItem extends StatelessWidget {
  final IconData ikon;
  final String yazi;

  const ProfileItem({Key key, this.ikon, this.yazi}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Renk.gGri19,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5.0),
        color: Renk.beyaz,
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(ikon),
          ),
          Flexible(
            child: Text(yazi, style: TextStyle(fontWeight: FontWeight.w500),),
          ),
        ],
      ),
    );
  }
}
