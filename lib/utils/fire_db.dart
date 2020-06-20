import 'package:cloud_firestore/cloud_firestore.dart';

class FireDB {
  static final String tag = "FireDB";
  static final Firestore firestore = Firestore.instance;

  static Future<void> urunBegen(String urunID, String begenenID) async {
    await firestore.collection('urunler').document(urunID).updateData({
      'begenenler': FieldValue.arrayUnion([begenenID]),
    });

    await firestore.collection('uyeler').document(begenenID).updateData({
      'begendikleri': FieldValue.arrayUnion([urunID]),
    });
  }

  static Future<void> urunBegenMe(String urunID, String begenenID) async {
    await firestore.collection('urunler').document(urunID).updateData({
      'begenenler': FieldValue.arrayRemove([begenenID]),
    });

    await firestore.collection('uyeler').document(begenenID).updateData({
      'begendikleri': FieldValue.arrayRemove([urunID]),
    });
  }

 /*  static Future<bool> begenKontrol(String urunID, String begenenID) async {
    DocumentSnapshot ds =
        await firestore.collection('urunler').document(urunID).get();

    return Urun.fromJson(ds.data).begenenler?.contains(begenenID) ?? false;
  }
 */
/*   static Future<void> urunIste(Urun urun, String isteyenID) async {
    String mZaman = Timestamp.now().microsecondsSinceEpoch.toString();
    await firestore.collection('urunler').document(urun.id).updateData({
      'isteyenler': FieldValue.arrayUnion([isteyenID]),
    });

    await firestore.collection('uyeler').document(isteyenID).updateData({
      'istedikleri': FieldValue.arrayUnion([urun.id]),
    });

    await firestore.collection('bedava_istekleri').document(mZaman).setData({
      'istenen_urun': urun.id,
      'isteyen_kisi': isteyenID,
      'istenen_urun_sahip_id': urun.sahip,
      'durum': 'bekleme',
      'istek_tarihi': FieldValue.serverTimestamp(),
    });
  } */

  /* static Future<void> urunIsteMe(Urun urun, String isteyenID) async {
    await firestore.collection('urunler').document(urun.id).updateData({
      'isteyenler': FieldValue.arrayRemove([isteyenID]),
    });

    await firestore.collection('uyeler').document(isteyenID).updateData({
      'istedikleri': FieldValue.arrayRemove([urun.id]),
    });

    await firestore
        .collection('bedava_istekleri')
        .where('istenen_urun', isEqualTo: urun.id)
        .where('isteyen_kisi', isEqualTo: Fonksiyon.user.uid)
        .getDocuments()
        .then((docs) {
      for (DocumentSnapshot ds in docs.documents) {
        firestore
            .collection('bedava_istekleri')
            .document(ds.documentID)
            .delete();
      }
    });
  }

  static Future<bool> isteKontrol(String urunID, String isteyenID) async {
    DocumentSnapshot ds =
        await firestore.collection('urunler').document(urunID).get();

    return Urun.fromJson(ds.data).isteyenler?.contains(isteyenID) ?? false;
  }

  static Future<bool> takasIsteKontrol(String urunID, String isteyenID) async {
    QuerySnapshot qs = await Fonksiyon.firestore
        .collection('takas_istekleri')
        .where('istenen_urun', isEqualTo: urunID)
        .where('durum', isEqualTo: 'kabul')
        .getDocuments();

    if (qs.documents.length > 0) {
      return true;
    }
    return false;
  } */

  /* static Future<bool> takasIsteOnerKontrol(
      String urunID, String isteyenID) async {
    QuerySnapshot qs = await Fonksiyon.firestore
        .collection('takas_istekleri')
        .where('istenen_urun', isEqualTo: urunID)
        .where('isteyen_kisi', isEqualTo: isteyenID)
        .where('durum', isEqualTo: 'bekleme')
        .getDocuments();

    if (qs.documents.length > 0) {
      return true;
    }
    return false;
  } */
}
