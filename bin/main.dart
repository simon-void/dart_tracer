import 'package:dart_tracer/dart_tracer_local.dart';
import 'package:stack_trace/stack_trace.dart';

main() {
  bool isDebugMode = true;
  Chain.capture(() {
    renderSphereImage(400, 400, "cross");
  }, when: isDebugMode);
}

renderSphereImage([int width=200, int height=100, String fileNameBase="chap4"]) async {
  var spheres = getCrosshairSpheres(2, -18);
  spheres.add(new Sphere(vec3(0,  1.2, -22), 1.15, RGB_INT.LIGHT_GREY));
  spheres.add(new Sphere(vec3(0, -1.2, -22), 1.15, RGB_INT.DARK_GREY));
  Camera cam = new Camera(vec3(0, 0, 0), vec3(0, 0, -1), vec3(1, 0, 0), 3.0, 3);
  var sceneDes = new SceneDescription(cam, spheres);
  var renderPane = new BufferedRenderPane(width, height);
  var tracer = new Tracer();
  tracer.trace(sceneDes, new LogProgressPaneProxy(renderPane, 10));
  var matrixPrinter = new PpmPrinter();
  var canvas = await renderPane.canvas;
  await matrixPrinter.print(canvas, fileNameBase, "./img");
}

List<Renderable> getCrosshairSpheres(int radius, int z) {
  List<Renderable> spheres = [];
  for(int x=-radius;x<=radius;x++) {
    for(int y=-radius;y<=radius;y++) {
      if(x.abs()==radius || y.abs()==radius || (x*y==0&&x.abs()+y.abs()!=0)) {
        var color = RGB_INT.PRETTY_RED;
        if(y==0) {
          color = RGB_INT.PRETTY_BLUE;
        }else if(x==0) {
          color = RGB_INT.PRETTY_GREEN;
        }
        var sphere = new Sphere(vec3(x, y, z), .5, color);
        spheres.add(sphere);
      }
    }
  }

  return spheres;
}

renderSkyImage([int width=200, int height=100, String fileNameBase="chap3"]) async {
  var sceneDes = new SceneDescription(Camera.defaultCam, []);
  var renderPane = new BufferedRenderPane(width, height);
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

Matrix<RGB_INT> getDefaultMatrix(int columns, int rows) {
  var img = new Matrix<RGB_INT>(columns, rows);

  for(int col=0; col<columns; col++) {
    for(int row=0; row<rows; row++) {
      num red = 255.99*col/columns;
      num green = 255.99*row/rows;
      num blue = 255.99*0.2;
      img[col][row] = new RGB_INT(red.toInt(), green.toInt(), blue.toInt());
    }
  }
  return img;
}
