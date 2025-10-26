enum ShockType { oneWay, threeWay }
String shockTypeToStr(ShockType t) => t == ShockType.threeWay ? 'three' : 'one';
ShockType shockTypeFromStr(String s) => s == 'three' ? ShockType.threeWay : ShockType.oneWay;

class Car {
  String make;
  String model;
  String surface;
  ShockType defaultShockType;
  Car({required this.make, required this.model, this.surface = 'Asfaltti', this.defaultShockType = ShockType.threeWay});
  String get title => '$make $model';
}

class Corner {
  double camber;
  double toeMm;
  double springMm;
  String note;
  Corner({required this.camber, required this.toeMm, required this.springMm, this.note = ''});
}

class Shocks {
  int total;
  int fast;
  int slow;
  String note;
  Shocks({required this.total, required this.fast, required this.slow, this.note = ''});
}

class CarData {
  Car car;
  ShockType shockType;
  Corner fl, fr, rl, rr;
  Shocks sfl, sfr, srl, srr;
  CarData({required this.car, required this.shockType, required this.fl, required this.fr, required this.rl, required this.rr, required this.sfl, required this.sfr, required this.srl, required this.srr});
}

