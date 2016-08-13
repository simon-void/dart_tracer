class RGB{
  static RGB BLACK = new RGB(0, 0, 0);
  static RGB WHITE = new RGB(255, 255, 255);

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

  RGB._(this.red, this.green, this.blue) {
    assert(0<=this.red   && this.red<256);
    assert(0<=this.green && this.green<256);
    assert(0<=this.blue  && this.blue<256);
  }
}