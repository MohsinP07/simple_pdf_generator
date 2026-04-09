## 0.2.2

- Added page orientation support in `SimplePdf.generate`: portrait (default) and landscape via `pageLandscape`.
- Added `pageFormat` override support for custom page sizes/formats; when set, it takes priority over `pageLandscape`.

## 0.2.1

- **Table cells:** added `PdfTableCell` with `PdfTableCell.text` and `PdfTableCell.image` so rows can mix Unicode text (theme font) and raster images (`Uint8List`, e.g. PNG). Plain `String` and raw `Uint8List` map values remain supported for backward compatibility.
- Default max image size in table cells is 40×40 PDF points when not specified; optional Flutter `BoxFit` maps to the `pdf` package layout.

## 0.1.1

- Added support for multiple tables
- Added per-table summary sections
- Added table header styling
- Added table cell styling
- Added summary styling