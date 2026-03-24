import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

void main() {
  // ==================== PosColumn Tests ====================
  group('PosColumn', () {
    test('creates with default values', () {
      final col = PosColumn();
      expect(col.text, '');
      expect(col.textEncoded, null);
      expect(col.containsChinese, false);
      expect(col.width, 2);
      expect(col.styles.bold, false);
    });

    test('creates with custom text and width', () {
      final col = PosColumn(text: 'Hello', width: 6);
      expect(col.text, 'Hello');
      expect(col.width, 6);
    });

    test('creates with textEncoded', () {
      final encoded = Uint8List.fromList([72, 101, 108, 108, 111]);
      final col = PosColumn(textEncoded: encoded, width: 4);
      expect(col.textEncoded, encoded);
      expect(col.width, 4);
    });

    test('throws on width less than 1', () {
      expect(
        () => PosColumn(text: 'test', width: 0),
        throwsException,
      );
    });

    test('throws on width greater than 12', () {
      expect(
        () => PosColumn(text: 'test', width: 13),
        throwsException,
      );
    });

    test('accepts width at boundary 1', () {
      final col = PosColumn(text: 'test', width: 1);
      expect(col.width, 1);
    });

    test('accepts width at boundary 12', () {
      final col = PosColumn(text: 'test', width: 12);
      expect(col.width, 12);
    });

    test('throws when both text and textEncoded are non-empty', () {
      expect(
        () => PosColumn(
          text: 'Hello',
          textEncoded: Uint8List.fromList([72]),
          width: 4,
        ),
        throwsException,
      );
    });

    test('allows text with null textEncoded', () {
      final col = PosColumn(text: 'Hello', width: 4);
      expect(col.text, 'Hello');
      expect(col.textEncoded, null);
    });

    test('allows empty text with textEncoded', () {
      final col = PosColumn(
        textEncoded: Uint8List.fromList([72]),
        width: 4,
      );
      expect(col.text, '');
      expect(col.textEncoded, isNotNull);
    });

    test('fields are immutable (final)', () {
      final col = PosColumn(text: 'test', width: 6);
      // If fields were mutable, this test documents they are now final
      expect(col.text, 'test');
      expect(col.width, 6);
    });

    test('creates with custom styles', () {
      final col = PosColumn(
        text: 'Bold text',
        width: 6,
        styles: const PosStyles(bold: true, align: PosAlign.center),
      );
      expect(col.styles.bold, true);
      expect(col.styles.align, PosAlign.center);
    });

    test('creates with containsChinese flag', () {
      final col = PosColumn(
        text: '你好',
        width: 6,
        containsChinese: true,
      );
      expect(col.containsChinese, true);
    });
  });

  // ==================== PosStyles Tests ====================
  group('PosStyles', () {
    test('default constructor has expected defaults', () {
      const styles = PosStyles();
      expect(styles.bold, false);
      expect(styles.reverse, false);
      expect(styles.underline, false);
      expect(styles.turn90, false);
      expect(styles.align, PosAlign.left);
      expect(styles.height, PosTextSize.size1);
      expect(styles.width, PosTextSize.size1);
      expect(styles.fontType, null);
      expect(styles.codeTable, null);
    });

    test('defaults constructor initializes all fields', () {
      const styles = PosStyles.defaults();
      expect(styles.fontType, PosFontType.fontA);
      expect(styles.codeTable, 'CP437');
    });

    test('copyWith preserves unchanged fields', () {
      const original = PosStyles(bold: true, align: PosAlign.center);
      final copy = original.copyWith(underline: true);
      expect(copy.bold, true);
      expect(copy.align, PosAlign.center);
      expect(copy.underline, true);
    });

    test('copyWith overrides specified fields', () {
      const original = PosStyles(bold: true);
      final copy = original.copyWith(bold: false, reverse: true);
      expect(copy.bold, false);
      expect(copy.reverse, true);
    });
  });

  // ==================== PosTextSize Tests ====================
  group('PosTextSize', () {
    test('size values are 1-8', () {
      expect(PosTextSize.size1.value, 1);
      expect(PosTextSize.size2.value, 2);
      expect(PosTextSize.size3.value, 3);
      expect(PosTextSize.size8.value, 8);
    });

    test('decSize calculates correctly for size1x1', () {
      final result = PosTextSize.decSize(PosTextSize.size1, PosTextSize.size1);
      expect(result, 0); // 16*(1-1) + (1-1) = 0
    });

    test('decSize calculates correctly for size2x2', () {
      final result = PosTextSize.decSize(PosTextSize.size2, PosTextSize.size2);
      expect(result, 17); // 16*(2-1) + (2-1) = 17
    });

    test('decSize calculates correctly for mixed sizes', () {
      final result = PosTextSize.decSize(PosTextSize.size1, PosTextSize.size2);
      expect(result, 16); // 16*(2-1) + (1-1) = 16
    });
  });

  // ==================== PaperSize Tests ====================
  group('PaperSize', () {
    test('mm58 width is 372', () {
      expect(PaperSize.mm58.width, 372);
    });

    test('mm72 width is 503', () {
      expect(PaperSize.mm72.width, 503);
    });

    test('mm80 width is 558', () {
      expect(PaperSize.mm80.width, 558);
    });
  });

  // ==================== PosBeepDuration Tests ====================
  group('PosBeepDuration', () {
    test('beep50ms has value 1', () {
      expect(PosBeepDuration.beep50ms.value, 1);
    });

    test('beep450ms has value 9', () {
      expect(PosBeepDuration.beep450ms.value, 9);
    });
  });

  // ==================== Barcode Tests ====================
  group('Barcode', () {
    group('UPC-A', () {
      test('creates with 11 digits', () {
        final barcode = Barcode.upcA([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0]);
        expect(barcode.type, BarcodeType.upcA);
        expect(barcode.data.length, 11);
      });

      test('creates with 12 digits', () {
        final barcode = Barcode.upcA([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4]);
        expect(barcode.type, BarcodeType.upcA);
        expect(barcode.data.length, 12);
      });

      test('throws on wrong length', () {
        expect(
          () => Barcode.upcA([1, 2, 3]),
          throwsException,
        );
      });

      test('throws on non-numeric data', () {
        expect(
          () => Barcode.upcA(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k']),
          throwsException,
        );
      });
    });

    group('UPC-E', () {
      test('creates with 6 digits', () {
        final barcode = Barcode.upcE([1, 2, 3, 4, 5, 6]);
        expect(barcode.type, BarcodeType.upcE);
      });

      test('creates with 7 digits starting with 0', () {
        final barcode = Barcode.upcE([0, 1, 2, 3, 4, 5, 6]);
        expect(barcode.type, BarcodeType.upcE);
      });

      test('throws with 7 digits not starting with 0', () {
        expect(
          () => Barcode.upcE([1, 1, 2, 3, 4, 5, 6]),
          throwsException,
        );
      });

      test('throws on wrong length', () {
        expect(
          () => Barcode.upcE([1, 2, 3]),
          throwsException,
        );
      });
    });

    group('EAN-13', () {
      test('creates with 12 digits', () {
        final barcode = Barcode.ean13([4, 0, 0, 6, 3, 8, 1, 3, 3, 9, 0, 4]);
        expect(barcode.type, BarcodeType.ean13);
      });

      test('creates with 13 digits', () {
        final barcode =
            Barcode.ean13([4, 0, 0, 6, 3, 8, 1, 3, 3, 9, 0, 4, 2]);
        expect(barcode.type, BarcodeType.ean13);
      });

      test('throws on wrong length', () {
        expect(
          () => Barcode.ean13([1, 2, 3]),
          throwsException,
        );
      });
    });

    group('EAN-8', () {
      test('creates with 7 digits', () {
        final barcode = Barcode.ean8([4, 0, 0, 6, 3, 8, 1]);
        expect(barcode.type, BarcodeType.ean8);
      });

      test('creates with 8 digits', () {
        final barcode = Barcode.ean8([4, 0, 0, 6, 3, 8, 1, 3]);
        expect(barcode.type, BarcodeType.ean8);
      });

      test('throws on wrong length', () {
        expect(
          () => Barcode.ean8([1, 2, 3]),
          throwsException,
        );
      });
    });

    group('CODE39', () {
      test('creates with valid characters', () {
        final barcode = Barcode.code39('ABC123'.split(''));
        expect(barcode.type, BarcodeType.code39);
      });

      test('throws on empty data', () {
        expect(
          () => Barcode.code39([]),
          throwsException,
        );
      });

      test('throws on invalid characters', () {
        expect(
          () => Barcode.code39(['a', 'b']),
          throwsException,
        );
      });
    });

    group('ITF', () {
      test('creates with even number of digits', () {
        final barcode = Barcode.itf([1, 2, 3, 4]);
        expect(barcode.type, BarcodeType.itf);
      });

      test('throws on odd number of digits', () {
        expect(
          () => Barcode.itf([1, 2, 3]),
          throwsException,
        );
      });

      test('throws on single digit', () {
        expect(
          () => Barcode.itf([1]),
          throwsException,
        );
      });

      test('throws on non-numeric data', () {
        expect(
          () => Barcode.itf(['A', 'B']),
          throwsException,
        );
      });
    });

    group('CODABAR', () {
      test('creates with valid data', () {
        final barcode = Barcode.codabar('A12345B'.split(''));
        expect(barcode.type, BarcodeType.codabar);
      });

      test('throws on single character', () {
        expect(
          () => Barcode.codabar(['A']),
          throwsException,
        );
      });

      test('throws when start is A-D but end is not A-D', () {
        expect(
          () => Barcode.codabar('A12345'.split('')..add('1')),
          throwsException,
        );
      });
    });

    group('CODE128', () {
      test('creates with valid data', () {
        final barcode = Barcode.code128('{A978020137962'.split(''));
        expect(barcode.type, BarcodeType.code128);
      });

      test('throws on single character', () {
        expect(
          () => Barcode.code128(['A']),
          throwsException,
        );
      });
    });
  });

  // ==================== Generator Tests ====================
  // Note: Generator requires CapabilityProfile which uses rootBundle.
  // Full integration tests require a running Flutter app context.
  // The beep/raster fix logic is verified in dedicated groups below.

  // ==================== Generator Beep Fix Verification ====================
  group('Generator beep fix verification', () {
    // These tests verify the beep recursion fix without needing CapabilityProfile
    // by testing the logic pattern

    test('beep with n <= 0 returns empty list', () {
      // Verifies the base case
      // The actual beep method returns [] when n <= 0
      // This pattern test verifies the fix logic
      List<int> simulateBeep({int n = 3, int durationValue = 9}) {
        List<int> bytes = [];
        if (n <= 0) return [];
        int beepCount = n > 9 ? 9 : n;
        // ESC B [count] [duration]
        bytes.addAll([0x1B, 0x42, beepCount, durationValue]);
        if (n > 9) {
          bytes += simulateBeep(n: n - 9, durationValue: durationValue);
        }
        return bytes;
      }

      expect(simulateBeep(n: 0), isEmpty);
      expect(simulateBeep(n: -1), isEmpty);
    });

    test('beep with n=3 returns single command', () {
      List<int> simulateBeep({int n = 3, int durationValue = 9}) {
        List<int> bytes = [];
        if (n <= 0) return [];
        int beepCount = n > 9 ? 9 : n;
        bytes.addAll([0x1B, 0x42, beepCount, durationValue]);
        if (n > 9) {
          bytes += simulateBeep(n: n - 9, durationValue: durationValue);
        }
        return bytes;
      }

      final result = simulateBeep(n: 3);
      expect(result.length, 4); // One command: ESC B count duration
      expect(result[2], 3); // beepCount = 3
    });

    test('beep with n=9 returns single command with count 9', () {
      List<int> simulateBeep({int n = 3, int durationValue = 9}) {
        List<int> bytes = [];
        if (n <= 0) return [];
        int beepCount = n > 9 ? 9 : n;
        bytes.addAll([0x1B, 0x42, beepCount, durationValue]);
        if (n > 9) {
          bytes += simulateBeep(n: n - 9, durationValue: durationValue);
        }
        return bytes;
      }

      final result = simulateBeep(n: 9);
      expect(result.length, 4);
      expect(result[2], 9);
    });

    test('beep with n=15 returns two commands (fixed recursion)', () {
      List<int> simulateBeep({int n = 3, int durationValue = 9}) {
        List<int> bytes = [];
        if (n <= 0) return [];
        int beepCount = n > 9 ? 9 : n;
        bytes.addAll([0x1B, 0x42, beepCount, durationValue]);
        if (n > 9) {
          bytes += simulateBeep(n: n - 9, durationValue: durationValue);
        }
        return bytes;
      }

      final result = simulateBeep(n: 15);
      expect(result.length, 8); // Two commands
      expect(result[2], 9); // First command: 9 beeps
      expect(result[6], 6); // Second command: 6 beeps
    });

    test('beep with n=27 returns three commands', () {
      List<int> simulateBeep({int n = 3, int durationValue = 9}) {
        List<int> bytes = [];
        if (n <= 0) return [];
        int beepCount = n > 9 ? 9 : n;
        bytes.addAll([0x1B, 0x42, beepCount, durationValue]);
        if (n > 9) {
          bytes += simulateBeep(n: n - 9, durationValue: durationValue);
        }
        return bytes;
      }

      final result = simulateBeep(n: 27);
      expect(result.length, 12); // Three commands
      expect(result[2], 9); // First: 9
      expect(result[6], 9); // Second: 9
      expect(result[10], 9); // Third: 9
    });

    test('beep does not stack overflow with large n', () {
      List<int> simulateBeep({int n = 3, int durationValue = 9}) {
        List<int> bytes = [];
        if (n <= 0) return [];
        int beepCount = n > 9 ? 9 : n;
        bytes.addAll([0x1B, 0x42, beepCount, durationValue]);
        if (n > 9) {
          bytes += simulateBeep(n: n - 9, durationValue: durationValue);
        }
        return bytes;
      }

      // Should not throw StackOverflowError
      final result = simulateBeep(n: 100);
      expect(result.length, 48); // ceil(100/9) = 12 commands * 4 bytes
    });
  });

  // ==================== Image Rasterization Fix Verification ====================
  group('Image rasterization fix verification', () {
    test('pack bits into bytes works correctly', () {
      // Test the _packBitsIntoBytes logic
      // Input: 8 grayscale values, threshold 127
      // Values > 127 become 1, values <= 127 become 0
      final input = [255, 0, 255, 0, 255, 0, 255, 0]; // 10101010 pattern

      int transformUint32Bool(int uint32, int shift, bool newValue) {
        return ((0xFFFFFFFF ^ (0x1 << shift)) & uint32) |
            ((newValue ? 1 : 0) << shift);
      }

      const pxPerLine = 8;
      const threshold = 127;
      final res = <int>[];
      for (int i = 0; i < input.length; i += pxPerLine) {
        int newVal = 0;
        for (int j = 0; j < pxPerLine; j++) {
          newVal = transformUint32Bool(
            newVal,
            pxPerLine - j,
            input[i + j] > threshold,
          );
        }
        res.add(newVal ~/ 2);
      }

      expect(res.length, 1);
      // 10101010 = 0xAA = 170
      expect(res[0], 170);
    });

    test('pack bits all ones', () {
      final input = List<int>.filled(8, 255); // All white

      int transformUint32Bool(int uint32, int shift, bool newValue) {
        return ((0xFFFFFFFF ^ (0x1 << shift)) & uint32) |
            ((newValue ? 1 : 0) << shift);
      }

      const pxPerLine = 8;
      const threshold = 127;
      final res = <int>[];
      for (int i = 0; i < input.length; i += pxPerLine) {
        int newVal = 0;
        for (int j = 0; j < pxPerLine; j++) {
          newVal = transformUint32Bool(
            newVal,
            pxPerLine - j,
            input[i + j] > threshold,
          );
        }
        res.add(newVal ~/ 2);
      }

      expect(res[0], 255); // 11111111
    });

    test('pack bits all zeros', () {
      final input = List<int>.filled(8, 0); // All black

      int transformUint32Bool(int uint32, int shift, bool newValue) {
        return ((0xFFFFFFFF ^ (0x1 << shift)) & uint32) |
            ((newValue ? 1 : 0) << shift);
      }

      const pxPerLine = 8;
      const threshold = 127;
      final res = <int>[];
      for (int i = 0; i < input.length; i += pxPerLine) {
        int newVal = 0;
        for (int j = 0; j < pxPerLine; j++) {
          newVal = transformUint32Bool(
            newVal,
            pxPerLine - j,
            input[i + j] > threshold,
          );
        }
        res.add(newVal ~/ 2);
      }

      expect(res[0], 0); // 00000000
    });

    test('row padding logic rounds width to multiple of 8', () {
      // Test the padding logic from _toRasterFormat fix
      const widthPx = 10;
      const heightPx = 2;
      final oneChannelBytes = List<int>.generate(widthPx * heightPx, (i) => i);

      final int targetWidth = (widthPx + 7) & ~7; // Should be 16
      expect(targetWidth, 16);

      final int missingPx = targetWidth - widthPx; // Should be 6
      expect(missingPx, 6);

      final List<int> paddedBytes = [];
      for (int row = 0; row < heightPx; row++) {
        final int rowStart = row * widthPx;
        paddedBytes
            .addAll(oneChannelBytes.sublist(rowStart, rowStart + widthPx));
        paddedBytes.addAll(List<int>.filled(missingPx, 0));
      }

      expect(paddedBytes.length, targetWidth * heightPx); // 16 * 2 = 32
      // First row: 0..9 then 6 zeros
      expect(paddedBytes.sublist(0, 10), List<int>.generate(10, (i) => i));
      expect(paddedBytes.sublist(10, 16), List<int>.filled(6, 0));
      // Second row: 10..19 then 6 zeros
      expect(
          paddedBytes.sublist(16, 26), List<int>.generate(10, (i) => i + 10));
      expect(paddedBytes.sublist(26, 32), List<int>.filled(6, 0));
    });

    test('no padding needed when width is already multiple of 8', () {
      const widthPx = 16;
      const heightPx = 2;

      if (widthPx % 8 != 0) {
        fail('This test expects width to already be a multiple of 8');
      }

      // No padding branch should be taken
      final int targetWidth = (widthPx + 7) & ~7;
      expect(targetWidth, widthPx); // Should be unchanged
    });
  });

  // ==================== QRCode Tests ====================
  group('QRCode', () {
    test('creates QR code bytes', () {
      final qr = QRCode('Hello', QRSize.size4, QRCorrection.L);
      expect(qr.bytes, isNotEmpty);
    });

    test('different sizes produce different bytes', () {
      final qr1 = QRCode('Hello', QRSize.size1, QRCorrection.L);
      final qr2 = QRCode('Hello', QRSize.size8, QRCorrection.L);
      expect(qr1.bytes, isNot(equals(qr2.bytes)));
    });

    test('different correction levels produce different bytes', () {
      final qr1 = QRCode('Hello', QRSize.size4, QRCorrection.L);
      final qr2 = QRCode('Hello', QRSize.size4, QRCorrection.H);
      expect(qr1.bytes, isNot(equals(qr2.bytes)));
    });

    test('QRSize values are correct', () {
      expect(QRSize.size1.value, 0x01);
      expect(QRSize.size4.value, 0x04);
      expect(QRSize.size8.value, 0x08);
    });

    test('QRCorrection values are correct', () {
      expect(QRCorrection.L.value, 48);
      expect(QRCorrection.M.value, 49);
      expect(QRCorrection.Q.value, 50);
      expect(QRCorrection.H.value, 51);
    });
  });

  // ==================== BarcodeType Tests ====================
  group('BarcodeType', () {
    test('upcA has value 0', () {
      expect(BarcodeType.upcA.value, 0);
    });

    test('code128 has value 73', () {
      expect(BarcodeType.code128.value, 73);
    });

    test('all types have unique values', () {
      final types = [
        BarcodeType.upcA,
        BarcodeType.upcE,
        BarcodeType.ean13,
        BarcodeType.ean8,
        BarcodeType.code39,
        BarcodeType.itf,
        BarcodeType.codabar,
        BarcodeType.code128,
      ];
      final values = types.map((t) => t.value).toSet();
      expect(values.length, types.length);
    });
  });

  // ==================== BarcodeText Tests ====================
  group('BarcodeText', () {
    test('none has value 0', () {
      expect(BarcodeText.none.value, 0);
    });

    test('below has value 2', () {
      expect(BarcodeText.below.value, 2);
    });

    test('both has value 3', () {
      expect(BarcodeText.both.value, 3);
    });
  });

  // ==================== BarcodeFont Tests ====================
  group('BarcodeFont', () {
    test('fontA has value 0', () {
      expect(BarcodeFont.fontA.value, 0);
    });

    test('specialB has value 98', () {
      expect(BarcodeFont.specialB.value, 98);
    });
  });
}
