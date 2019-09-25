import 'dart:async';
import 'package:dart_tracer/src/base/color.dart';
import 'package:dart_tracer/src/base/math3d.dart';

abstract class RenderPane {
  int get width;
  int get height;
  start();
  paint(int x, int y, RGB_INT color);
  finish();
}

class BufferedRenderPane extends RenderPane {
  @override
  int get width => _pane.columns;
  @override
  int get height => _pane.rows;
  Future<Matrix<RGB_INT>> get canvas => _completer.future;
  final Completer<Matrix<RGB_INT>> _completer = new Completer();
  final Matrix<RGB_INT> _pane;
  BufferedRenderPane(int width, int height):
        this._pane = new Matrix<RGB_INT>(width, height);

  @override
  void start() {}

  @override
  void paint(int x, int y, RGB_INT color) {
    _pane[x][y] = color;
  }

  @override
  void finish() {
    _completer.complete(_pane);
  }
}

class LogProgressPaneProxy extends RenderPane {
  final RenderPane proxiedPane;
  final Stopwatch _stopwatch = new Stopwatch();
  int _raysRendered = 0;
  int _raysToRender;
  int lastStep = 0;
  final int _logStep;

  LogProgressPaneProxy(this.proxiedPane, this._logStep) {
    assert(_logStep>0 && _logStep<21);
    _raysToRender = height*width;
  }

  @override
  int get height => proxiedPane.height;

  @override
  int get width => proxiedPane.width;

  @override
  paint(int x, int y, RGB_INT color) {
    proxiedPane.paint(x,y,color);
    _raysRendered++;
    int percent = (100*_raysRendered)~/_raysToRender;
    if(percent>=lastStep+_logStep) {
      print("$percent%");
      lastStep=percent;
    }
  }

  @override
  start() {
    proxiedPane.start();
    print("0%");
    _stopwatch.reset();
    _stopwatch.start();
  }

  @override
  finish() {
    _stopwatch.stop();
    proxiedPane.finish();
    print("elapsed time: ${_stopwatch.elapsed}");
  }
}