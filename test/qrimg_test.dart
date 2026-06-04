import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('qrcodeAsImage produces GS v 0 raster bytes for 33-char URL', () async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(PaperSize.mm80, profile);
    final bytes = gen.qrcodeAsImage(
      'www.lithospos.comssdddddddddd8991',
      moduleSize: 6,
    );
    expect(bytes.length, greaterThan(100));
    // GS v 0 = 0x1D 0x76 0x30
    final idx = _findSeq(bytes, [0x1D, 0x76, 0x30]);
    expect(idx, greaterThanOrEqualTo(0), reason: 'GS v 0 raster header missing');
  });
  test('qrcodeAsImage handles UTF-8 payloads', () async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(PaperSize.mm80, profile);
    final bytes = gen.qrcodeAsImage('فاتورة 🔥 https://lithospos.com/order/12345');
    expect(bytes.length, greaterThan(100));
  });
}

int _findSeq(List<int> haystack, List<int> needle) {
  for (int i = 0; i + needle.length <= haystack.length; i++) {
    var ok = true;
    for (int j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) { ok = false; break; }
    }
    if (ok) return i;
  }
  return -1;
}
