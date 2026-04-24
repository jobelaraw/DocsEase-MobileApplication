import 'package:flutter/services.dart';

import 'package:google_generative_ai/google_generative_ai.dart';



class RagService {
  static DataPart? _cachedPdf;


  static Future<DataPart> getPdfPart() async {

    if (_cachedPdf != null) return _cachedPdf!;
    final bytes = await rootBundle.load('assets/Citizen_Charter.pdf');
    _cachedPdf = DataPart('application/pdf', bytes.buffer.asUint8List());
    return _cachedPdf!;
  }
}