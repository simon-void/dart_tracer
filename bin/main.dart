import 'package:dart_tracer/dart_tracer_local.dart';
import 'package:stack_trace/stack_trace.dart';

main() {
  bool isDebugMode = true;
  Chain.capture(() {
//    renderDefaultImage();
    renderSkyImage();
  }, when: isDebugMode);
}

renderSkyImage([int width=200, int height=100, String fileNameBase="chap3"]) async {
  var sceneDes = new SceneDescription(Camera.defaultCam);
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
