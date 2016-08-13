import 'dart:math';

class Matrix<E> {
  int get columns => _content.length;
  int get rows => _content[0].length;
  final List<List<E>> _content;

  Matrix(int width, int height):
      // TODO make this an unmodifiable list
      _content = new List.generate(
          width, (index)=>new List(height), growable: false) {
    assert(width>0);
    assert(height>0);
  }

  /*<E>*/ operator [](int i) => _content[i]; // get
}

class Vector {
  final List<double> _v;
  double get squaredLength => _v.map((d)=>pow(d, 2)).fold(.0, (sum, d)=>sum+d);
  double get length => sqrt(squaredLength);
  int get dimension => _v.length;

  Vector(Iterable<double> elements):
        _v = new List.from(elements, growable: false);

  Vector.d3(double x, double y, double z):_v = new List(3) {
    _v..add(x)..add(y)..add(z);
  }

  Vector.combine(Vector v1, Vector v2, double combine(double, double)):
        _v = new List(v1.dimension) {
    _generalCombine(v1, v2, _v, combine);
  }

  void _replace(double f(double)) {
    _v.replaceRange(0, _v.length, _v.map(f));
  }

  void _generalCombine(Vector v1, Vector v2,
      List<double> t, double combine(double, double)) {
    assert(v1.dimension==v2.dimension);
    for(int i=0; i<_v.length;i++) {
      t[i] = combine(v1._v[i], v2._v[i]);
    }
  }

  void _combineEq(Vector o, double combine(double, double)) {
    _generalCombine(this, o, _v, combine);
  }

  void negate() => _replace((d)=>-d);

  void scaleToUnitLength() {
    final currentLength = length;
    _replace((d)=>d/currentLength);
  }

  Vector getUnitVector() => scalaDiv(length);

  num operator[](int i) =>_v[i];

  Vector operator+(Vector o) => new Vector.combine(this,o,(d1, d2)=>d1+d2);
  Vector operator-(Vector o) => new Vector.combine(this,o,(d1, d2)=>d1-d2);
  Vector operator*(Vector o) => new Vector.combine(this,o,(d1, d2)=>d1*d2);
  Vector operator/(Vector o) => new Vector.combine(this,o,(d1, d2)=>d1/d2);

  void  plusEq(Vector o) => _combineEq(o, (d1, d2)=>d1+d2);
  void minusEq(Vector o) => _combineEq(o, (d1, d2)=>d1-d2);
  void  multEq(Vector o) => _combineEq(o, (d1, d2)=>d1*d2);
  void   divEq(Vector o) => _combineEq(o, (d1, d2)=>d1/d2);

  Vector scalaMult(final double value) => new Vector(_v.map((d)=>d*value));
  Vector  scalaDiv(final double value) => new Vector(_v.map((d)=>d/value));
  void scalaMultEq(final double value) => _replace((d)=>d*value);
  void  scalaDivEq(final double value) => _replace((d)=>d/value);


  double dot(Vector o) {
    assert(dimension==o.dimension);
    double dotProduct = .0;
    for(int i=0; i<_v.length; i++) {
      dotProduct+= (_v[i]*o._v[i]);
    }
    return dotProduct;
  }

  Vector cross(Vector o) {
    //rewrite method should we ever get support for 4d-vectors
    assert(dimension==3);
    assert(dimension==o.dimension);

    List<double> v1 = _v;
    List<double> v2 = o._v;

    double d0 = v1[1]*v2[2] - v1[2]*v2[1];
    double d1 = v1[2]*v2[0] - v1[0]*v2[2];
    double d2 = v1[0]*v2[1] - v1[1]*v2[0];

    return new Vector([d0, d1, d2]);
  }
}