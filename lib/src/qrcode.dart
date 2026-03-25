import 'dart:convert';

class QRSize {
  const QRSize(this.value);
  final int value;

  static const size1 = QRSize(0x01);
  static const size2 = QRSize(0x02);
  static const size3 = QRSize(0x03);
  static const size4 = QRSize(0x04);
  static const size5 = QRSize(0x05);
  static const size6 = QRSize(0x06);
  static const size7 = QRSize(0x07);
  static const size8 = QRSize(0x08);
  static const size9 = QRSize(0x09);
  static const size10 = QRSize(0x0A);
  static const size11 = QRSize(0x0B);
  static const size12 = QRSize(0x0C);
  static const size13 = QRSize(0x0D);
  static const size14 = QRSize(0x0E);
  static const size15 = QRSize(0x0F);
  static const size16 = QRSize(0x10);
}

/// QR Correction level
class QRCorrection {
  const QRCorrection._internal(this.value);
  final int value;

  /// Level L: Recovery Capacity 7%
  static const L = QRCorrection._internal(48);

  /// Level M: Recovery Capacity 15%
  static const M = QRCorrection._internal(49);

  /// Level Q: Recovery Capacity 25%
  static const Q = QRCorrection._internal(50);

  /// Level H: Recovery Capacity 30%
  static const H = QRCorrection._internal(51);
}

/// QR Code model selection
///
/// Model 1: Original QR Code specification
/// Model 2: Enhanced version with larger capacity (most common)
/// microQR: Compact version for small items
class QRModel {
  const QRModel._internal(this.value);
  final int value;

  /// Model 1 - Original specification
  static const model1 = QRModel._internal(49);

  /// Model 2 - Enhanced, most widely used (default)
  static const model2 = QRModel._internal(50);

  /// Micro QR - Compact version
  static const microQR = QRModel._internal(51);
}

class QRCode {
  List<int> bytes = <int>[];
  static const String cQrHeader = '\x1D\x28\x6B';

  QRCode(
    String text,
    QRSize size,
    QRCorrection level, {
    QRModel model = QRModel.model2,
  }) {
    // FN 165. QR Code: Select the model
    // GS ( k pL pH cn fn n1 n2
    bytes += cQrHeader.codeUnits + [0x04, 0x00, 0x31, 0x41, model.value, 0x00];

    // FN 167. QR Code: Set the size of module
    bytes += cQrHeader.codeUnits + [0x03, 0x00, 0x31, 0x43] + [size.value];

    // FN 169. QR Code: Select the error correction level
    bytes += cQrHeader.codeUnits + [0x03, 0x00, 0x31, 0x45] + [level.value];

    // FN 180. QR Code: Store the data in the symbol storage area
    List<int> textBytes = latin1.encode(text);
    int textLength = textBytes.length + 3;

    bytes += cQrHeader.codeUnits +
        [textLength & 0xFF, textLength >> 8, 0x31, 0x50, 0x30];
    bytes += textBytes;

    // FN 181. QR Code: Print the symbol data in the symbol storage area
    bytes += cQrHeader.codeUnits + [0x03, 0x00, 0x31, 0x51, 0x30];
  }
}
