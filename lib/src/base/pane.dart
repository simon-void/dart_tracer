import 'dart:async';
import 'package:dart_tracer/src/base/color.dart';
import 'package:dart_tracer/src/base/math3d.dart';

abstract class RenderPane {
  int get width;
  int get height;
  start();
  paint(int x, int y, RGB color);
  finish();
}

class BufferedRenderPane extends RenderPane {
  @override
  int get width => _pane.columns;
  @override
  int get height => _pane.rows;
  Future<Matrix<RGB>> get renderedPane => _completer.future;
  final Completer<Matrix<RGB>> _completer = new Completer();
  final Matrix<RGB> _pane;
  BufferedRenderPane(int width, int height):
        this._pane = new Matrix<RGB>(width, height);

  @override
  void start() {}

  @override
  void paint(int x, int y, RGB color) {
    _pane[x][y] = color;
  }

  @override
  void finish() {
    _completer.complete(_pane);
  }
}
