import 'package:dart_tracer/dart_tracer_local.dart';
import 'package:stack_trace/stack_trace.dart';

main() {
  print("trace world");
  bool isDebugMode = true;
  Chain.capture(() {
    var matrixPrinter = new PpmPrinter();
    var matrix = getDefaultMatrix(200, 100);
    matrixPrinter.print(matrix, "first", "./img").then(
        (_){
          print("traced world");
        }
    );
  }, when: isDebugMode);
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
