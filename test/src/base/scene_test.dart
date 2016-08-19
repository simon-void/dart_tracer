import 'package:dart_tracer/src/base/math3d.dart';
import 'package:dart_tracer/src/base/scene.dart';
import "package:test/test.dart";

void main() {
  group("camera.getRay", testCamera);
}


void testCamera() {
  final side = 101;
  final camera = new Camera(
      vec3(0, 0, 0), vec3(0, 0, -1), vec3(1, 0, 0), 1.0, 1);

  test("middle middle ray", (){
    Ray negaZAxis = camera.getRays(50, side, 50, side)[0];
    expect(negaZAxis.origin,  equals(vec3(0, 0, 0)));
    expect(negaZAxis.unitDir, equals(vec3(0, 0,-1)));
  });

  test("left middle ray", (){
    Ray ray = camera.getRays(0, side, 50, side)[0];
    expect(ray.unitDir.x, isNegative);
    expect(ray.unitDir.y, isZero);
    expect(ray.unitDir.z, isNegative);
  });

  test("right middle ray", (){
    Ray ray = camera.getRays(100, side, 50, side)[0];
    expect(ray.unitDir.x, isPositive);
    expect(ray.unitDir.y, isZero);
    expect(ray.unitDir.z, isNegative);
  });

  test("middle upper ray", (){
    Ray ray = camera.getRays(50, side, 100, side)[0];
    expect(ray.unitDir.x, isZero);
    expect(ray.unitDir.y, isPositive);
    expect(ray.unitDir.z, isNegative);
  });

  test("middle lower ray", (){
    Ray ray = camera.getRays(50, 101, 0, 101)[0];
    expect(ray.unitDir.x, isZero);
    expect(ray.unitDir.y, isNegative);
    expect(ray.unitDir.z, isNegative);
  });
}