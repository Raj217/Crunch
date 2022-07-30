class Formatter {
  /// [size] : is in bytes
  static String getSize({required int size}) {
    String unit = 'KB';
    double finalSize = size / 1024;
    if (finalSize > 1000) {
      unit = 'MB';
      finalSize /= 1024;
      if (finalSize > 1000) {
        unit = 'GB';
        finalSize /= 1024;
      }
    }
    return '${finalSize.toStringAsFixed(2)} $unit';
  }
}
