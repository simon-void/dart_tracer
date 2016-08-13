import 'package:dart_tracer/src/base/scene.dart';
import 'package:dart_tracer/src/base/color.dart';
import 'package:dart_tracer/src/base/pane.dart';


class Tracer {
  void trace(SceneDefinition scene, RenderPane pane) {
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
  void _prepare(SceneDefinition scene) {}

  /**
   * trace a
   */
  RGB _tracePixel(int x, int y, int width, int height) {
    return new RGB(0,0,0);
  }
}