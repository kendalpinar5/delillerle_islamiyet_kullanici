import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delillerleislamiyet/model/kullanici.dart';
import 'package:delillerleislamiyet/utils/fonksiyonlar.dart';
import 'package:delillerleislamiyet/utils/mesaj.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';

class MesajYazWidget extends StatefulWidget {
  final String grupID;
  final Function scrollToBottom;

  const MesajYazWidget({
    Key key,
    @required this.grupID,
    @required this.scrollToBottom,
  }) : super(key: key);

  @override
  _MesajYazWidgetState createState() => _MesajYazWidgetState();
}

class _MesajYazWidgetState extends State<MesajYazWidget> {
  final ValueNotifier _mesaj = ValueNotifier('');

  Uye uye = Fonksiyon.uye;

  bool _islem = false;
  bool _gittim = false;

  Future _mesajGonder(String msg) async {
    if (msg.trim() != '') {
      Mesaj msj = Mesaj(
        gonderen: uye.gorunenIsim,
        yazan: uye.uid,
        yazanRsm: uye.resim,
        grupid: widget.grupID,
        metin: _mesaj.value,
        tarih: FieldValue.serverTimestamp(),
      );

      await Firestore.instance
          .collection('gruplar')
          .document(widget.grupID)
          .collection('mesajlar')
          .document(Timestamp.now().millisecondsSinceEpoch.toString())
          .setData(msj.toMap());

      widget.scrollToBottom(yazan: uye.gorunenIsim, mesaj: _mesaj.value);
      _mesaj.value = '';
      if (!_gittim) setState(() {});
    }
  }

  @override
  void dispose() {
    _gittim = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 120.0),
      child: IntrinsicHeight(
        child: Card(
          margin: EdgeInsets.all(4.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: TextField(
                    controller: TextEditingController(text: _mesaj.value),
                    decoration: InputDecoration(
                      hintText: "Mesajınızı yazın",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0)),
                      ),
                    ),
                    onChanged: (m) => _mesaj.value = m,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: IconButton(
                  onPressed: () {
                    if (_mesaj.value.length > 0 && !_islem) {
                      _mesajGonder(_mesaj.value);
                    }
                  },
                  icon: ValueListenableBuilder(
                    valueListenable: _mesaj,
                    builder: (c, v, _) {
                      return Icon(
                        Icons.send,
                        color:
                            _mesaj.value.length > 0 ? Renk.yesil : Renk.siyah,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
