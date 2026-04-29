import 'dart:typed_data';
import 'package:flutter/services.dart';

class RagService {
  static Uint8List? _cachedPdf;

  static Future<Uint8List> getPdfBytes() async {
    if (_cachedPdf != null) return _cachedPdf!;
    final bytes = await rootBundle.load('assets/Citizen_Charter.pdf');
    _cachedPdf = bytes.buffer.asUint8List();
    return _cachedPdf!;
  }
}
