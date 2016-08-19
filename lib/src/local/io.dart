import 'dart:async';
import 'dart:io' as dart show File;
import 'dart:convert' show AsciiCodec;
import 'package:file/io.dart';
import 'package:dart_tracer/src/base/math3d.dart';
import 'package:dart_tracer/src/base/color.dart';


abstract class MatrixPrinter<E> {
  String get fileType;

  Future print(Matrix<E> matrix, String baseName, String dirPath) async {
    var newFile = await _getNewFile(baseName, fileType, dirPath);
    var bytes = _convertToBytes(matrix);
    // lets await for the _print future to complete
    // before we complete this functions future
    await _print(newFile, bytes);
  }

  List<int> _convertToBytes(Matrix<E> matrix);

  Future<File> _getNewFile(String baseName, String fileType, final String dirPath) async {
    final fs = const LocalFileSystem();
    Future<bool> isNewFilename(String filename) async {
      var filePath = "${dirPath}/$filename";
      FileSystemEntityType type = await fs.type(filePath);
      return type==FileSystemEntityType.NOT_FOUND;
    }

    var fileNameCandidate = "$baseName.$fileType";
    if( await isNewFilename(fileNameCandidate)) {
      return fs.file("${dirPath}/$fileNameCandidate");
    }

    int i = 1;
    while( true ) {
      fileNameCandidate = "${baseName}_${_iTo3chars(i++, "0")}.$fileType";
      if( await isNewFilename(fileNameCandidate)) {
        return fs.file("${dirPath}/$fileNameCandidate");
      }
    }
  }

  Future _print(File newFile, List<int> bytes) {
    var fileToCreate = new dart.File(newFile.path);
    fileToCreate.createSync(recursive: true);
    return fileToCreate.writeAsBytes(bytes, flush: true);
  }
}

class PpmPrinter extends MatrixPrinter<RGB_INT> {
  final String fileType = "ppm";
  final AsciiCodec _codec = const AsciiCodec();

  @override
  List<int> _convertToBytes(Matrix<RGB_INT> matrix) {
    String rgb2Str(RGB_INT rgb) =>
        "${_iTo3chars(rgb.red)} ${_iTo3chars(rgb.green)} ${_iTo3chars(rgb.blue)}";

    var buffer = new StringBuffer("P3\n");
    buffer.writeln("${matrix.columns} ${matrix.rows}");
    buffer.writeln("255");

    for(int row=matrix.rows-1; row>=0; row--) {
      buffer.write(rgb2Str(matrix[0][row]));
      for(int col=1; col<matrix.columns; col++) {
        buffer.write(" ");
        buffer.write(rgb2Str(matrix[col][row]));
      }
      buffer.writeln();
    }

    var content = buffer.toString();
    return _codec.encode(content);
  }
}


String _iTo3chars(int i, [String seperator= " "]) {
  assert(i>=0 && i<256);
  if(i<10) {
    return "$seperator$seperator$i";
  }else if(i<100) {
    return "$seperator$i";
  }else{
    return i.toString();
  }
}