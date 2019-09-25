import 'dart:math';
import 'package:dart_tracer/src/base/color.dart';
import 'package:dart_tracer/src/base/math3d.dart';
import 'package:dart_tracer/src/base/util.dart';

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
    //we are only interested in points before the camera
    assert(!t.isNegative);
    return origin+unitDir.scalaMult(t);
  }
}

class Camera {
  static final Camera defaultCam = new Camera.defaultPane(
      vec3(0, 0, 0), vec3(0, 0, -1), vec3(1, 0, 0));
  AntialiasingStrategy _antialiasingStrategy;


  Camera.defaultPane(Vector pos, Vector direction, Vector right):
        this(pos, direction, right, 1.0, 2);

  Camera(Vector pos, Vector frontDir, Vector rightDir,
      double paneDistance, int aaSqrtFactor) {
    Vector unitFrontDir = frontDir.scaleToUnitLength();
    Vector unitRightDir = rightDir.scaleToUnitLength();
    //front vector and right vector have to have a 90° angle between them
    assert(unitFrontDir.isOrthogonal(unitRightDir));

    Vector unitUpDir = frontDir.getOrthogonal3D(rightDir).scaleToUnitLength();
    Vector paneMiddlePos = pos + unitFrontDir.scalaMult(paneDistance);

    assert(aaSqrtFactor>0);
    if(aaSqrtFactor==1) {
      _antialiasingStrategy = new NoAntialiasingStrategy(
        pos, paneMiddlePos, unitUpDir, unitRightDir);
    }else{
      _antialiasingStrategy = new QuadraticAntialiasingStrategy(
          pos, paneMiddlePos, unitUpDir, unitRightDir, 2);
    }
  }

  /**
   * return one or more rays (in case of antialiasing)
   */
  List<Ray> getRays(int x, int width, int y, int height) {
    return _antialiasingStrategy.getRays(x, width, y, height);
  }
}

abstract class AntialiasingStrategy {
  final Vector _pos, _unitRightDir, _unitUpDir, _paneMiddlePos;

  AntialiasingStrategy(this._pos, this._paneMiddlePos,
                       this._unitUpDir, this._unitRightDir) {
    //front vector and right vector have to have a 90° angle between them
    assert(_unitUpDir.isOrthogonal(_unitRightDir));
  }

  List<Ray> getRays(int x, int width, int y, int height);
}

class NoAntialiasingStrategy extends AntialiasingStrategy {
  final SingleComputeValue widthScaleFactorC = new SingleComputeValue();
  final SingleComputeValue heightScaleFactorC = new SingleComputeValue();

  NoAntialiasingStrategy(_pos, _paneMiddlePos, _unitUpDir, _unitRightDir):
      super(_pos, _paneMiddlePos, _unitUpDir, _unitRightDir);

  /**
   * return one ray (so no antialiasing)
   */
  @override
  List<Ray> getRays(int x, int width, int y, int height) {
    //relativX/Y e [-.5, .5]
    double relativX = x/(width-1)-.5;
    double relativY = y/(height-1)-.5;
    // the virtual camera pane is assumed to have a with and height of 1
    // these two parameters will scale it to the ratio of my final image
    final double widthScaleFactor = widthScaleFactorC.computeOnce(
        ()=>max(width/height, 1.0));
    final double heightScaleFactor = heightScaleFactorC.computeOnce(
        ()=>max(height/width, 1.0));
    // compute where the ray is going through the virtual camera pane
    Vector panePos = _paneMiddlePos +
        _unitRightDir.scalaMult(relativX*widthScaleFactor) +
        _unitUpDir.scalaMult(relativY*heightScaleFactor);

    Vector dir = panePos - _pos;
    // returns just a single, middle ray
    return [new Ray(_pos, dir)];
  }
}

class QuadraticAntialiasingStrategy extends AntialiasingStrategy {
  final int _numbersOfRaysRoot;
  final widthScaleFactorC = new SingleComputeValue();
  final heightScaleFactorC = new SingleComputeValue();
  final relativePixelWidthC = new SingleComputeValue();
  final random = new Random();

  QuadraticAntialiasingStrategy(
      _pos, _paneMiddlePos, _unitUpDir, _unitRightDir, this._numbersOfRaysRoot):
        super(_pos, _paneMiddlePos, _unitUpDir, _unitRightDir);

  /**
   * return pow(_numbersOfRaysRoot,w) number of rays,
   * that are randomly shaken within their quadrant
   */
  @override
  List<Ray> getRays(int x, final int width, int y, final int height) {
    //relativX/Y e [-.5, .5[
    double relativX = x/width-.5;
    double relativY = y/height-.5;
    // the virtual camera pane is assumed to have a with and height of 1
    // these two parameters will scale it to the ratio of my final image
    final double widthScaleFactor = widthScaleFactorC.computeOnce(
        ()=>max(width/height, 1.0));
    final double heightScaleFactor = heightScaleFactorC.computeOnce(
        ()=>max(height/width, 1.0));
    final double relPixelWidth = relativePixelWidthC.computeOnce(
        ()=>(heightScaleFactor/height));

    List<Vector> quadrantPanePositions =
      getRandomizedQuadrantPoints(relativX, relativY, relPixelWidth,
          widthScaleFactor, heightScaleFactor);

    // for each position return the ray to that position
    return new List.from(
        quadrantPanePositions.map(
            (Vector randPos)=>new Ray(_pos,randPos-_pos)));
  }

  List<Vector> getRandomizedQuadrantPoints(
      double relativStartX, double relativStartY, double relativPixelWidth,
      double widthScaleFactor, double heightScaleFactor) {
    final relativeSubpixelWith = relativPixelWidth/_numbersOfRaysRoot;
    List<Vector> randPos = [];
    for(int x=0; x<_numbersOfRaysRoot; x++) {
      for(int y=0; y<_numbersOfRaysRoot; y++) {
        //randPos = quadrant + randomized Offset in that quadrant
        double randX = random.nextDouble();
        double randY = random.nextDouble();
        double relativX = relativStartX+(x+randX)*relativeSubpixelWith;
        double relativY = relativStartY+(y+randY)*relativeSubpixelWith;

        Vector subPixel = _paneMiddlePos +
            _unitRightDir.scalaMult(relativX*widthScaleFactor) +
            _unitUpDir.scalaMult(relativY*heightScaleFactor);

        randPos.add(subPixel);
      }
    }
    return randPos;
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
  RGB_INT get color;
}

class Sphere extends Renderable {
  final Vector _midPoint;
  final double _radius;
  final RGB_INT color;

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