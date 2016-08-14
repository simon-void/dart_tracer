import 'package:dart_tracer/dart_tracer_local.dart';
import 'package:stack_trace/stack_trace.dart';

main() {
  bool isDebugMode = true;
  Chain.capture(() {
    renderSphereImage();
  }, when: isDebugMode);
}

renderSphereImage([int width=200, int height=100, String fileNameBase="chap4"]) async {
  var spere1 = new Sphere(vec3(0, 0, -3), 1.1, RGB.RED);
  var spere2 = new Sphere(vec3(-7, 0, -10), 2.0, RGB.GREEN);
  var spere3 = new Sphere(vec3(0.8, .5, -2), 0.5, RGB.BLUE);
  var sceneDes = new SceneDescription(Camera.defaultCam, [spere1, spere2, spere3]);
  var renderPane = new BufferedRenderPane(200, 100);
  var tracer = new Tracer();
  tracer.trace(sceneDes, renderPane);
  var matrixPrinter = new PpmPrinter();
  var canvas = await renderPane.canvas;
  await matrixPrinter.print(canvas, fileNameBase, "./img");
}

renderSkyImage([int width=200, int height=100, String fileNameBase="chap3"]) async {
  var sceneDes = new SceneDescription(Camera.defaultCam, []);
  var renderPane = new BufferedRenderPane(200, 100);
  var tracer = new Tracer();
  tracer.trace(sceneDes, renderPane);
  var matrixPrinter = new PpmPrinter();
  var canvas = await renderPane.canvas;
  await matrixPrinter.print(canvas, fileNameBase, "./img");
}

renderDefaultImage([int width=200, int height=100, String fileNameBase="chap1"]) async {
  var matrixPrinter = new PpmPrinter();
  var matrix = getDefaultMatrix(width, height);
  await matrixPrinter.print(matrix, fileNameBase, "./img");
}

Matrix<RGB> getDefaultMatrix(int columns, int rows) {
  var img = new Matrix<RGB>(columns, rows);

  for(int col=0; col<columns; col++) {
    for(int row=0; row<rows; row++) {
      num red = 255.99*col/columns;
      num green = 255.99*row/rows;
      num blue = 255.99*0.2;
      img[col][row] = new RGB(red.toInt(), green.toInt(), blue.toInt());
    }
  }
  return img;
}
