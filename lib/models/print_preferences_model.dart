class PrintPreferences {
  final bool isColor;
  final bool isDuplex;
  final int copies;
  final int pages;

  PrintPreferences({
    required this.isColor,
    required this.isDuplex,
    required this.copies,
    required this.pages,
  });

  Map<String, dynamic> toMap() {
    return {
      'isColor': isColor,
      'isDuplex': isDuplex,
      'copies': copies,
      'pages': pages,
    };
  }

  factory PrintPreferences.fromMap(Map<String, dynamic> map) {
    return PrintPreferences(
      isColor: map['isColor'] ?? false,
      isDuplex: map['isDuplex'] ?? true,
      copies: map['copies'] ?? 1,
      pages: map['pages'] ?? 1,
    );
  }

  double calculateCost() {
    double baseCost = isColor ? 0.50 : 0.10;
    double multiplier = isDuplex ? 1.5 : 2.0;
    return baseCost * multiplier * copies * pages;
  }
}