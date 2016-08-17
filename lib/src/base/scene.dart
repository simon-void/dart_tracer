import 'dart:math';
import 'package:dart_tracer/src/base/color.dart';
import 'package:dart_tracer/src/base/math3d.dart';

class SceneDescription {
  final Camera camera;
  final List<Renderable> renderables;

  SceneDescription(this.camera, this.renderables);
}

class Ray {
  final Vector origin, unitDir;
  Ray(this.origin, Vector direction):
        unitDir = direction.scaleToUnitLength();

  Vector point(double t) {
    //we are only interessted in points before the camera
    assert(!t.isNegative);
    return origin+unitDir.scalaMult(t);
  }
}

class Camera {
  static final Camera defaultCam = new Camera.defaultPane(
      vec3(0, 0, 0), vec3(0, 0, -1), vec3(1, 0, 0));
  final Vector _pos, _unitFrontDir, _unitRightDir, _unitUpDir;
  Vector _paneMiddlePos;


  Camera.defaultPane(Vector pos, Vector direction, Vector right):
        this(pos, direction, right, 1.0);

  Camera(Vector pos, Vector frontDir, Vector rightDir, double paneDistance):
        _pos = pos,
        _unitFrontDir = frontDir.scaleToUnitLength(),
        _unitRightDir = rightDir.scaleToUnitLength(),
        _unitUpDir = frontDir.getOrthogonal3D(rightDir).scaleToUnitLength() {
    //front vector and right vector have to have a 90° angle between them
    assert(_unitFrontDir.isOrthogonal(_unitRightDir));
    _paneMiddlePos = _pos + _unitFrontDir.scalaMult(paneDistance);
  }

  Ray getRay(int x, int width, int y, int height) {
    //relativX/Y e [-.5, .5]
    double relativX = x/(width-1)-.5;
    double relativY = y/(height-1)-.5;
    // the virtual camera pane is assumed to have a with and height of 1
    // these two parameters will scale it to the ratio of my final image
    double widthScaleFactor = max(width/height, 1.0);
    double heightScaleFactor = max(height/width, 1.0);
    // compute where the ray is going through the virtual camera pane
    Vector panePos = _paneMiddlePos +
        _unitRightDir.scalaMult(relativX*widthScaleFactor) +
        _unitUpDir.scalaMult(relativY*heightScaleFactor);

    Vector dir = panePos - _pos;
    return new Ray(_pos, dir);
  }
}

abstract class Renderable {
  /**
   * return the distance from the camera, if this ray hits this object
   * and the return value is positive
   * (we are not interested in objects behind the camera)
   * , otherwise null.
   */
  double getHitPoint(Ray ray);
  Vector getUnitNormal(Vector point);
  RGB get color;
}

class Sphere extends Renderable {
  final Vector _midPoint;
  final double _radius;
  final RGB color;

  Sphere(this._midPoint, this._radius, this.color);

  @override
  double getHitPoint(Ray ray) {
    // create a quadratic equation of type a*x^2+b*x+c=0
    // with ray.pos+x*ray.dir = hitpoint of the ray with the sphere
    // return the smalest solution with x>0 (if that exist)
    final a = ray.unitDir.dot(ray.unitDir);
    final aMinusC = ray.origin-_midPoint;
    final b = ray.unitDir.dot(aMinusC)*2;
    final c = aMinusC.squaredLength-pow(_radius,2);

    // we are only interested in solutions in front of the camera
    Iterable<double> positiveSolutions = solveQuadrEq(a, b, c).where((d)=>d>0);

    if(positiveSolutions.isEmpty) {
      return null;
    }
    // find the minimum of max two values
    double t = positiveSolutions.first;
    if(positiveSolutions.length==2) {
      double t2=positiveSolutions.last;
      if(t2<t) {
        t = t2;
      }
    }

    //t is the distance of the object from the camera
    return t;
  }

  @override
  Vector getUnitNormal(Vector point) {
    return (point-_midPoint).scaleToUnitLength();
  }
}