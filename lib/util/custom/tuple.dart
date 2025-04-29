class Tuple<X, Y, Z> {
  X first;
  Y second;
  Z third;

  Tuple(this.first, this.second, this.third);

  @override
  String toString() => 'Tuple(first: $first, second: $second, third $third)';
}
