class PdfHeader {
  final String title;
  final String? subtitle;
  final String? extra;

  PdfHeader({
    required this.title,
    this.subtitle,
    this.extra,
  });
}
