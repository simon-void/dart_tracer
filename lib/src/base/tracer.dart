import 'package:dart_tracer/src/base/color.dart';
import 'package:dart_tracer/src/base/math3d.dart';
import 'package:dart_tracer/src/base/pane.dart';
import 'package:dart_tracer/src/base/scene.dart';


class Tracer {
  void trace(SceneDescription scene, RenderPane pane) {
    _prepare(scene);

    pane.start();
    for(int x=0; x<pane.width; x++) {
      for(int y=0; y<pane.height; y++) {
        var rgb = _tracePixel(x, y, pane.width, pane.height);
        pane.paint(x, y, rgb);
      }
    }
    pane.finish();
  }

  /**
   * prepare the scene, e.g. transform it into an internal representation
   */
  void _prepare(SceneDescription scene) {
    _scene = scene;
  }

  SceneDescription _scene;
  /**
   * trace a
   */
  RGB_INT _tracePixel(int x, int y, int width, int height) {
    var rays = _scene.camera.getRays(x, width, y, height);
    var colors = new List<RGB_DOUBLE>(rays.length);
    rays.asMap().forEach((index, ray) {
      colors[index] = _traceRay(ray);
    });

    var rgb_double = new RGB_DOUBLE.merge(colors);
    return rgb_double.toInt();
  }

  RGB_DOUBLE _traceRay(Ray ray) {
    double distance = 999999999999999999.9;
    Renderable closestRenderable;
    for(var renderable in _scene.renderables) {
      var currentDistance = renderable.getHitPoint(ray);
      if(currentDistance!=null) {
        if(currentDistance<distance) {
          distance = currentDistance;
          closestRenderable = renderable;
        }
      }
    }
    if(closestRenderable!=null) {
      var hitPoint = ray.point(distance);
      return new RGB_DOUBLE.byUnitVector(closestRenderable.getUnitNormal(hitPoint));
    }else{
      return _skyColor(ray);
    }
  }

  RGB_DOUBLE _skyColor(Ray ray) {
    //t as in the book, ray.unitDir.y [-1, 1]
    var t = (ray.unitDir.y+1.0)/2;
    var colorInDoubles =
      vec3(.5, .7, 1).scalaMultEq(t).scalaAddEq(1-t);
    return new RGB_DOUBLE(
        colorInDoubles.x,colorInDoubles.y,colorInDoubles.z);
  }
}