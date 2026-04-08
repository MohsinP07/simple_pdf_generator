import 'dart:typed_data';

import 'package:flutter/painting.dart' show BoxFit;

/// One table body cell: Unicode text (uses the document/table theme font) or a
/// raster image (e.g. PNG bytes for logos, stamps, signatures).
///
/// Recommended usage: use [PdfTableCell.text] and [PdfTableCell.image] so
/// intent is explicit. For backward compatibility, plain [String] values and
/// raw [Uint8List] values in row maps are also accepted (see [PdfTable]).
class PdfTableCell {
  const PdfTableCell._({
    required this.text,
    this.bytes,
    this.maxWidth,
    this.maxHeight,
    this.fit,
  });

  /// Text content; empty when [bytes] is non-null.
  final String text;

  /// Raw image bytes (e.g. PNG); when set, this cell renders as an image.
  final Uint8List? bytes;

  /// Max width for the image in PDF layout units (points). Defaults when null.
  final double? maxWidth;

  /// Max height for the image in PDF layout units (points). Defaults when null.
  final double? maxHeight;

  /// How the image is inscribed in the max width/height box (PDF `BoxFit`).
  final BoxFit? fit;

  /// True when this cell should render as an image.
  bool get isImage => bytes != null;

  /// Text cell; uses [PdfTable.cellStyle] / theme fonts like plain strings.
  factory PdfTableCell.text(String value) => PdfTableCell._(text: value);

  /// Image cell; [bytes] is typically PNG or JPEG. When [maxWidth] or
  /// [maxHeight] are omitted, the table builder applies conservative defaults
  /// so row height stays reasonable.
  factory PdfTableCell.image(
    Uint8List bytes, {
    double? maxWidth,
    double? maxHeight,
    BoxFit? fit,
  }) {
    return PdfTableCell._(
      text: '',
      bytes: bytes,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      fit: fit,
    );
  }
}
