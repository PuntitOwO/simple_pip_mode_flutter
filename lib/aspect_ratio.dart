/// AspectRatio type to represent the width to height ratio.
typedef AspectRatio = (int, int);

/// Extension to get the width, height, name, and list form of an AspectRatio.
extension AspectRatioExtension on AspectRatio {
  /// Width of the aspect ratio.
  int get width => this.$1;

  /// Height of the aspect ratio.
  int get height => this.$2;

  /// Aspect ratio in a human readable form.
  String get name => '$width:$height';

  /// Aspect ratio as a list.
  List<int> get asList => <int>[width, height];
}
