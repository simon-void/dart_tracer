import 'dart:math';
import 'package:dart_tracer/src/base/math3d.dart';

class SceneDescription {
  final Camera camera;

  SceneDescription(this.camera);
}

class Ray {
  final Vector origin, unitDir;
  Ray(this.origin, Vector direction):
        unitDir = direction.scaleToUnitLength();
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