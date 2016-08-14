int _map01DoubleTo0255Inf(double d) {
  assert(.0<=d && d<=1.0);
  return (d*255.99999).toInt();
}

class RGB{
  static RGB BLACK = new RGB(0, 0, 0);
  static RGB WHITE = new RGB(255, 255, 255);
  static RGB RED = new RGB(255, 0, 0);
  static RGB GREEN = new RGB(0, 255, 0);
  static RGB BLUE = new RGB(0, 0, 255);

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

  RGB.fromDoubles(double red, double green, double blue):
        this._(_map01DoubleTo0255Inf(red),
          _map01DoubleTo0255Inf(green),
          _map01DoubleTo0255Inf(blue));

  RGB._(this.red, this.green, this.blue) {
    assert(0<=this.red   && this.red<256);
    assert(0<=this.green && this.green<256);
    assert(0<=this.blue  && this.blue<256);
  }
}