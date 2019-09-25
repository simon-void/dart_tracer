import 'dart:math';
import 'package:dart_tracer/src/base/math3d.dart';

//map double[0-1]=>int[0-255]
int _map01DoubleTo0255(double d) {
  assert(.0<=d && d<=1.0);
  return (d*255.99999).toInt();
}

//map double[-1-1]=>int[0-255]
int _map11DoubleTo0255(double d) {
  assert(-1.0<=d && d<=1.0);
  return _map01DoubleTo0255((d+1)/2);
}

//map double[-1-1]=>int[0-255]
double _map11DoubleTo01(double d) {
  assert(-1.0<=d && d<=1.0);
  return (d+1.0)/2.0;
}

class RGB_INT{
  static RGB_INT BLACK = new RGB_INT._(0, 0, 0);
  static RGB_INT WHITE = new RGB_INT._(255, 255, 255);
  static RGB_INT LIGHT_GREY = new RGB_INT._(255-_low, 255-_low, 255-_low);
  static RGB_INT DARK_GREY = new RGB_INT._(_low, _low, _low);
  static RGB_INT RED = new RGB_INT._(255, 0, 0);
  static RGB_INT GREEN = new RGB_INT._(0, 255, 0);
  static RGB_INT BLUE = new RGB_INT._(0, 0, 255);
  static const _low = 50;
  static const _high = 160;
  static const _delta = 30;
  static RGB_INT PRETTY_RED = new RGB_INT._(_high, _low, _low+_delta);
  static RGB_INT PRETTY_GREEN = new RGB_INT._(_low, _high, _low+_delta);
  static RGB_INT PRETTY_BLUE = new RGB_INT._(_low, _low+_delta, _high);

  final int red, green, blue;

  factory RGB_INT (int red, int green, int blue) {
    if(red==0 && green==0 && blue==0) {
      return RGB_INT.BLACK;
    }
    if(red==255 && green==255 && blue==255) {
      return RGB_INT.WHITE;
    }
    return new RGB_INT._(red, green, blue);
  }

  RGB_INT._(this.red, this.green, this.blue) {
    assert(0<=this.red   && this.red<256);
    assert(0<=this.green && this.green<256);
    assert(0<=this.blue  && this.blue<256);
  }
}

class RGB_DOUBLE {
  final double red, green, blue;

  RGB_DOUBLE (this.red, this.green, this.blue) {
    assert(.0<=this.red   && this.red<=1.0);
    assert(.0<=this.green && this.green<=1.0);
    assert(.0<=this.blue  && this.blue<=1.0);
  }

  RGB_DOUBLE.byUnitVector(Vector unitVector):
        this(_map11DoubleTo01(unitVector.x),
          _map11DoubleTo01(unitVector.y),
          _map11DoubleTo01(unitVector.z));

  RGB_INT toInt() => new RGB_INT(
        _map01DoubleTo0255(red),
        _map01DoubleTo0255(green),
        _map01DoubleTo0255(blue));

  factory RGB_DOUBLE.merge (List<RGB_DOUBLE> colors) {
    // you have to square the color values first
    // (because the square root of photons are stored, because humans are better at
    // distinguishing small difference at dark scenes)
    // https://www.youtube.com/watch?v=LKnqECcg6Gw

    Vector squaredV3 = colors.
    map(
        (rgb)=>vec3(pow(rgb.red,2), pow(rgb.green,2), pow(rgb.blue,2))).
    fold(
        Vector.ZERO_D3, (pv, newV)=>pv+newV).scalaDiv(colors.length.toDouble());
    RGB_DOUBLE mergedColor = new RGB_DOUBLE(
        sqrt(squaredV3.x), sqrt(squaredV3.y), sqrt(squaredV3.z));

    return mergedColor;
  }
}