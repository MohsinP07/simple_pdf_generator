import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

import '../models/pdf_font_family.dart';

// ignore_for_file: public_member_api_docs

/// Asset path for the bundled Noto Sans variable font (SIL OFL).
///
/// See `assets/fonts/OFL.txt` in this package.
const String kSimplePdfNotoSansAsset =
    'packages/simple_pdf_generator/assets/fonts/NotoSans-Variable.ttf';

const String kSimplePdfRobotoAsset =
    'packages/simple_pdf_generator/assets/fonts/Roboto-Variable.ttf';
const String kSimplePdfPoppinsAsset =
    'packages/simple_pdf_generator/assets/fonts/Poppins-Regular.ttf';
const String kSimplePdfLatoAsset =
    'packages/simple_pdf_generator/assets/fonts/Lato-Regular.ttf';

/// Builds a [pw.ThemeData] using Noto Sans so common Unicode text (em dash,
/// Greek letters, etc.) renders instead of missing-glyph placeholders.
///
/// The `pdf` package’s default Helvetica fonts only cover a limited Latin set;
/// use this theme (or pass your own `ThemeData` to `SimplePdf.generate`)
/// for broader character coverage.
Future<pw.ThemeData> loadSimplePdfUnicodeTheme() async {
  final data = await rootBundle.load(kSimplePdfNotoSansAsset);
  final font = pw.Font.ttf(data);
  return pw.ThemeData.withFont(
    base: font,
    bold: font,
    italic: font,
    boldItalic: font,
  );
}

/// Loads a bundled font for [PdfFontFamily]. Fonts are cached by the caller
/// for per-document reuse.
Future<pw.Font> loadSimplePdfFont(PdfFontFamily family) async {
  final asset = _fontAssetForFamily(family);
  final data = await rootBundle.load(asset);
  return pw.Font.ttf(data);
}

String _fontAssetForFamily(PdfFontFamily family) {
  switch (family) {
    case PdfFontFamily.roboto:
      return kSimplePdfRobotoAsset;
    case PdfFontFamily.poppins:
      return kSimplePdfPoppinsAsset;
    case PdfFontFamily.lato:
      return kSimplePdfLatoAsset;
  }
}
