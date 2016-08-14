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

Vector vec3(num x, num y, num z) {
  return new Vector([x.toDouble(), y.toDouble(), z.toDouble()]);
}

class Vector {
  final List<double> _v;
  double get squaredLength => _v.map((d)=>pow(d, 2)).fold(.0, (sum, d)=>sum+d);
  double get length => sqrt(squaredLength);
  int get dimension => _v.length;
  bool get isZero => _v.every((d)=>d==0);
  bool get isUnit => squaredLength==1;
  double get x => _v[0];
  double get y => _v[1];
  double get z => _v[2];

  Vector(Iterable<double> elements):
        _v = new List.from(elements, growable: false);

  Vector.combine(Vector v1, Vector v2, double combine(double d1, double d2)):
        _v = new List(v1.dimension) {
    _generalCombine(v1, v2, _v, combine);
  }

  Vector _replace(double f(double d)) {
    for(int i=0; i<_v.length;i++) {
      _v[i] = f(_v[i]);
    }
    return this;
  }

  void _generalCombine(Vector v1, Vector v2,
      List<double> t, double combine(double d1, double d2)) {
    assert(v1.dimension==v2.dimension);
    for(int i=0; i<_v.length;i++) {
      t[i] = combine(v1._v[i], v2._v[i]);
    }
  }

  void _combineEq(Vector o, double combine(double d1, double d2)) {
    _generalCombine(this, o, _v, combine);
  }

  Vector negate() => _replace((d)=>-d);

  Vector scaleToUnitLength() {
    assert(!isZero);
    final currentLength = length;
    if(currentLength!=1) {
      // make this a unit vector if it isn't already
      _replace((d)=>d/currentLength);
    }
    return this;
  }

  Vector getUnitVector() {
    assert(!isZero);
    final currentLength = length;
    if(currentLength==1) {
      // return a copy of this
      return new Vector(_v);
    }else{
      // return a scaled copy of this
      return scalaDiv(currentLength);
    }
  }

  bool isSameDirection(Vector o) {
    final double scale = _v[0]/o._v[0];
    for(int i=1; i<_v.length; i++) {
      if(_v[i]/o._v[i] != scale) {
        return false;
      }
    }
    return true;
  }
  bool isOrthogonal(Vector o) => dot(o)==.0;
  Vector getOrthogonal3D(Vector rightSide) {
    // give that this Vector is pointing to the front
    // and the parameter is pointing to the right
    // return the one pointing up
    assert(this.dimension==3 && this.dimension==rightSide.dimension);
    assert(!isSameDirection(rightSide));

    return cross(rightSide).negate();
  }

  num operator[](int i) =>_v[i];

  Vector operator+(Vector o) => new Vector.combine(this,o,(d1, d2)=>d1+d2);
  Vector operator-(Vector o) => new Vector.combine(this,o,(d1, d2)=>d1-d2);
  Vector operator*(Vector o) => new Vector.combine(this,o,(d1, d2)=>d1*d2);
  Vector operator/(Vector o) => new Vector.combine(this,o,(d1, d2)=>d1/d2);

  void  plusEq(Vector o) => _combineEq(o, (d1, d2)=>d1+d2);
  void minusEq(Vector o) => _combineEq(o, (d1, d2)=>d1-d2);
  void  multEq(Vector o) => _combineEq(o, (d1, d2)=>d1*d2);
  void   divEq(Vector o) => _combineEq(o, (d1, d2)=>d1/d2);

  Vector scalaMult  (final double value) => new Vector(_v.map((d)=>d*value));
  Vector  scalaDiv  (final double value) => new Vector(_v.map((d)=>d/value));
  Vector scalaMultEq(final double value) => _replace((d)=>d*value);
  Vector  scalaDivEq(final double value) => _replace((d)=>d/value);
  Vector  scalaAddEq(final double value) => _replace((d)=>d+value);


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

  @override
  String toString() {
    return "(${_v.map((d)=>d.toStringAsFixed(2)).join(", ")})";
  }

  @override
  bool operator==(other) {
    // must be a vector
    if(!(other is Vector)) {
      return false;
    }
    // must have same length
    var other_v = (other as Vector)._v;
    if( _v.length != other_v.length) {
      return false;
    }
    // must have same content
    for(int i=0; i<_v.length; i++) {
      if(_v[i]!=other_v[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => _v.fold(0, (sum, d)=>37*sum+d.toInt());
}