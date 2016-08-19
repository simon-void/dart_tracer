import 'package:dart_tracer/src/base/math3d.dart';

//map double[0-1]=>int[0-255]
int _map01DoubleTo0255Inf(double d) {
  assert(.0<=d && d<=1.0);
  return (d*255.99999).toInt();
}

//map double[-1-1]=>int[0-255]
int _map11DoubleTo0255Inf(double d) {
  assert(-1.0<=d && d<=1.0);
  return _map01DoubleTo0255Inf((d+1)/2);
}

class RGB{
  static RGB BLACK = new RGB._(0, 0, 0);
  static RGB WHITE = new RGB._(255, 255, 255);
  static RGB LIGHT_GREY = new RGB._(255-_low, 255-_low, 255-_low);
  static RGB DARK_GREY = new RGB._(_low, _low, _low);
  static RGB RED = new RGB._(255, 0, 0);
  static RGB GREEN = new RGB._(0, 255, 0);
  static RGB BLUE = new RGB._(0, 0, 255);
  static const _low = 50;
  static const _high = 160;
  static const _delta = 30;
  static RGB PRETTY_RED = new RGB._(_high, _low, _low+_delta);
  static RGB PRETTY_GREEN = new RGB._(_low, _high, _low+_delta);
  static RGB PRETTY_BLUE = new RGB._(_low, _low+_delta, _high);

  final int red, green, blue;

  factory RGB (int red, int green, int blue) {
    if(red==0 && green==0 && blue==0) {
      return RGB.BLACK;
    }
    if(red==255 && green==255 && blue==255) {
      return RGB.WHITE;
    }
    return new RGB._(red, green, blue);
  }

  factory RGB.mergeRGBs (List<RGB> colors) {
    // TODO real merge
    return colors[0];
  }

  RGB.fromDoubles(double red, double green, double blue):
        this._(_map01DoubleTo0255Inf(red),
          _map01DoubleTo0255Inf(green),
          _map01DoubleTo0255Inf(blue));

  RGB._(this.red, this.green, this.blue) {
    assert(0<=this.red   && this.red<256);
    assert(0<=this.green && this.green<256);
    assert(0<=this.blue  && this.blue<256);
  }

  RGB.byUnitVector(Vector unitVector):
        this._(_map11DoubleTo0255Inf(unitVector.x),
          _map11DoubleTo0255Inf(unitVector.y),
          _map11DoubleTo0255Inf(unitVector.z));
}