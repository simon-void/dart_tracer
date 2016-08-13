class Matrix<E> {
  int get columns => _content.length;
  int get rows => _content[0].length;
  final List<List<E>> _content;

  Matrix(int width, int height):
      // TODO make this an unmodifiable list
      _content = new List.generate(
          width, (index)=>new List(height), growable: false) {
    assert(width>0);
    assert(height>0);
  }

  operator [](int x) => _content[x]; // get
}
