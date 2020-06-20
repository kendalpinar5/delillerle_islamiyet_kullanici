import 'package:delillerleislamiyet/kfcdrawer/gelistirme_page.dart';
import 'package:delillerleislamiyet/kfcdrawer/gunun_sozu_page.dart';
import 'package:delillerleislamiyet/kfcdrawer/main_page.dart';

typedef T Constructor<T>();

final Map<String, Constructor<Object>> _constructors =
    <String, Constructor<Object>>{};

void register<T>(Constructor<T> constructor) {
  _constructors[T.toString()] = constructor;
}

class ClassBuilder {
  static void registerClasses() {
    register<MainPage>(() => MainPage());
    register<GununSozuPage>(() => GununSozuPage());
    register<GelistirmePage>(() => GelistirmePage());
  }

  static dynamic fromString(String type) {
    return _constructors[type]();
  }
}
