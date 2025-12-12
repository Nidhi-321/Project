// lib/utils/stego_utils.dart
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Defensive stego helper — extracts LSB data from red channel.
class StegoUtils {
  static List<int> _rgbFromPixel(dynamic pix) {
    if (pix is int) {
      final int p = pix;
      final int r = (p >> 16) & 0xFF;
      final int g = (p >> 8) & 0xFF;
      final int b = p & 0xFF;
      return [r, g, b];
    }
    try {
      final dynamic p = pix;
      final int r = (p.r ?? p.red ?? 0) as int;
      final int g = (p.g ?? p.green ?? 0) as int;
      final int b = (p.b ?? p.blue ?? 0) as int;
      return [r, g, b];
    } catch (_) {
      return [0, 0, 0];
    }
  }

  static int _lsb(int v) => v & 1;

  static String extractFromImage(img.Image image, {int maxBytes = 0}) {
    final buffer = <int>[];
    int bitCount = 0;
    int current = 0;
    int x = 0, y = 0;
    final total = image.width * image.height;
    int visited = 0;
    while ((maxBytes == 0 || buffer.length < maxBytes) && visited < total) {
      final pix = image.getPixel(x, y);
      final rgb = _rgbFromPixel(pix);
      final int r = rgb[0];
      final bit = _lsb(r);
      current = (current << 1) | bit;
      bitCount++;
      if (bitCount == 8) {
        buffer.add(current & 0xFF);
        bitCount = 0;
        current = 0;
      }
      x++;
      if (x >= image.width) {
        x = 0;
        y++;
        if (y >= image.height) break;
      }
      visited++;
    }
    return String.fromCharCodes(buffer);
  }

  static String extractFromBytes(List<int> bytes) {
    try {
      final u = Uint8List.fromList(bytes);
      final img.Image? image = img.decodeImage(u);
      if (image == null) return '';
      return extractFromImage(image);
    } catch (_) {
      return '';
    }
  }
}
