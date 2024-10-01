typedef AspectRatio = (int, int);

extension AspectRatioExtension on AspectRatio {
  int get width => this.$1;
  int get height => this.$2;
  String get name => '$width:$height';
  List<int> get asList => <int>[width, height];
}
