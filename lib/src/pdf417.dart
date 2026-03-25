import 'dart:convert';

/// PDF417 2D barcode generator
///
/// Uses GS ( k cn=48 command set with 9 sub-functions.
/// PDF417 is widely used for shipping labels, ID cards, and airline tickets.
class PDF417 {
  List<int> bytes = <int>[];
  static const String _header = '\x1D\x28\x6B';
  static const int _cn = 48; // cn=48 for PDF417

  /// Creates a PDF417 barcode command sequence
  ///
  /// [text] data to encode
  /// [columns] number of data columns (0 = auto, 1-30)
  /// [rows] number of rows (0 = auto, 3-90)
  /// [moduleWidth] module width in dots (2-8)
  /// [moduleHeight] row height in dots (2-8)
  /// [errorCorrection] error correction level (0-8)
  /// [truncated] if true, uses Compact PDF417
  PDF417(
    String text, {
    int columns = 0,
    int rows = 0,
    int moduleWidth = 3,
    int moduleHeight = 3,
    int errorCorrection = 1,
    bool truncated = false,
  }) {
    // FN 065: Set the number of columns
    // GS ( k pL pH cn fn n
    bytes += _header.codeUnits + [0x03, 0x00, _cn, 65, columns];

    // FN 066: Set the number of rows
    bytes += _header.codeUnits + [0x03, 0x00, _cn, 66, rows];

    // FN 067: Set the width of the module
    bytes += _header.codeUnits + [0x03, 0x00, _cn, 67, moduleWidth];

    // FN 068: Set the row height
    bytes += _header.codeUnits + [0x03, 0x00, _cn, 68, moduleHeight];

    // FN 069: Set the error correction level
    // m = 48 + level (48-56 for levels 0-8)
    bytes += _header.codeUnits + [0x04, 0x00, _cn, 69, 48, 48 + errorCorrection];

    // FN 070: Select the options (standard or truncated)
    // n = 0: standard PDF417, n = 1: truncated (Compact PDF417)
    bytes += _header.codeUnits + [0x03, 0x00, _cn, 70, truncated ? 1 : 0];

    // FN 080: Store the data in the symbol storage area
    List<int> textBytes = latin1.encode(text);
    int dataLength = textBytes.length + 3;
    bytes += _header.codeUnits +
        [dataLength & 0xFF, (dataLength >> 8) & 0xFF, _cn, 80, 48];
    bytes += textBytes;

    // FN 081: Print the symbol data in the symbol storage area
    bytes += _header.codeUnits + [0x03, 0x00, _cn, 81, 48];
  }
}
