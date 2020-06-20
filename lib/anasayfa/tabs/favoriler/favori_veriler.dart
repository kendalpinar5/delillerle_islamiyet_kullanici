import 'package:flutter/material.dart';

class FavoriVeriler extends StatefulWidget {
  @override
  _FavoriVerilerState createState() => _FavoriVerilerState();
}

class _FavoriVerilerState extends State<FavoriVeriler> {
 // final Firestore _db = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /* Future<List<Cekilis>> _cekilisKontrolEt() async {
    QuerySnapshot querySnapshot = await _db
        .collection('cekilisler')
        .where('cekilis_tarihi', isGreaterThan: Timestamp.now())
        .orderBy('cekilis_tarihi', descending: true)
        .limit(1)
        .getDocuments();
    if (querySnapshot.documents.length > 0)
      return querySnapshot.documents
          .map((d) => Cekilis.fromJson(d.data, d.documentID))
          .toList();
    else
      return [];
  } */

  /*  Future<List<Soz>> sozleriGetir() async {
    QuerySnapshot querySnapshot = await _db
        .collection('gunun_sozleri')
        .orderBy('tarih', descending: true)
        .limit(1)
        .getDocuments();

    return querySnapshot.documents.map((d) => Soz.fromJson(d.data)).toList();
  } */

  /*  Future<List<AkisVeri>> _makaleGetir({String filtre}) async {
    Fonksiyon.begenenVeriler.forEach((f) {

      Future<DocumentSnapshot> ds = Firestore.instance
          .collection('akis_verileri').document(f)

         
          .getDocuments();

      return ds.documents
          .map((d) => AkisVeri.fromMap(d.data))
          .toList();
    });
  }
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            /*  FutureBuilder<List<Soz>>(
              future: sozleriGetir(),
              builder: (_, als) {
                if (als.connectionState == ConnectionState.active)
                  return LinearProgressIndicator();
                if (als.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (Soz soz in als.data)
                        SozWidget(soz: soz, scaffoldKey: _scaffoldKey)
                    ],
                  );
                }
                return SizedBox();
              },
            ), */

            /*  FutureBuilder<List<AkisVeri>>(
              future: _makaleGetir(),
              builder: (_, als) {
                if (als.connectionState == ConnectionState.active)
                  return LinearProgressIndicator();
                if (als.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (AkisVeri veri in als.data)
                        AkisVeriWidget(veri: veri, scaffoldKey: _scaffoldKey)
                    ],
                  );
                }
                return SizedBox();
              },
            ), */

            //  SaglikMutluluk(),
            //   SizedBox(height: 3400, child: YouTubeMain(de: true)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // _makaleGetir(filtre: 'cevapSayisi');
        },
        child: Icon(Icons.select_all),
        foregroundColor: Colors.black,
        mini: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
