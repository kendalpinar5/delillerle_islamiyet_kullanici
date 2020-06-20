import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:delillerleislamiyet/kfcdrawer/class_builder.dart';
import 'package:delillerleislamiyet/pages/alan_sec.dart';
import 'package:delillerleislamiyet/utils/renkler.dart';
import 'package:delillerleislamiyet/uyelik/tum_uyeler.dart';
import 'package:delillerleislamiyet/uyelik/uyekontrol.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    print("myBackgroundMessageHandler// Handle data message $data");
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    print("myBackgroundMessageHandler// Handle notification message $notification");
  }

  // Or do other work.
  print("myBackgroundMessageHandler// Or do other work.");
}

void main() {
  runApp(MyApp());
}

var rotalar = {
  '/alan_sec': (context) => AlanSec(),
  '/tum_uyeler': (context) => TumUyeler(),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delillerle İslamiyet',
      routes: rotalar,
      theme: ThemeData(
        fontFamily: 'Rubik',
        primaryColor: Renk.wp,
        accentColor: Renk.wpAcik,
        unselectedWidgetColor: Renk.beyaz,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', 'US'), Locale('tr', 'TR')],
      home: FutureBuilder(future: Future.microtask(
        () async {

          await Hive.initFlutter('delilerleislamiyet');
          ClassBuilder.registerClasses();
          
        },
      ), builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return Scaffold(
            backgroundColor: Renk.wp.withOpacity(0.65),
            body: SafeArea(
              child: UyeKontrol(),
            ),
          );

        return Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Renk.wpKoyu,
          child: Center(
              child: Text(
            'HoşGeldiniz...',
            style: TextStyle(color: Renk.beyaz, fontSize: MediaQuery.of(context).size.width / 26),
          )),
        );
      }),
    );
  }
}
