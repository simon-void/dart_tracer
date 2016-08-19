typedef dynamic Compute();

class SingleComputeValue<T> {
  T _value;
  T computeOnce(Compute computeT)=> _value ??= computeT();
}