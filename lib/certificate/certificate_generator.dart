import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// STEP 2 — Certificate Generator Service
///
/// Uses the OFFICIAL Nehru Arts & Science College certificate image as the
/// full-page PDF background. This file does exactly ONE thing beyond
/// displaying that image: it overlays the student's name inside the blank
/// line that already exists in the image.
///
/// Nothing else is drawn, redrawn, recreated, or modified — no borders,
/// no logos, no signatures, no seals, no college branding, no background,
/// no re-colored text, no re-positioned elements. The image bytes are
/// passed straight into the PDF untouched.
class CertificateGenerator {
  // ---- Coordinates measured directly from the official image pixels ----
  // Source image: 1600 x 1130px
  //   underline detected at y = 627-628, spanning x = 521 to 1233
  static const double _blankCenterXFraction = 0.548; // (521+1233)/2 / 1600
  static const double _blankBaselineYFraction =
      0.68; // just above the underline
  static const double _blankWidthFraction = 0.445; // (1233-521) / 1600

  // Navy sampled directly from the certificate's own printed text (RGB 20,43,93)
  static const PdfColor _nameColor = PdfColor.fromInt(0xFF142B5D);

  static Future<Uint8List> generate({
    required String studentName,
    String templateAssetPath = 'assets/images/certificate_template.jpg',
  }) async {
    final ByteData raw = await rootBundle.load(templateAssetPath);
    final pw.MemoryImage certificateImage = pw.MemoryImage(
      raw.buffer.asUint8List(),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          final double pageWidth = PdfPageFormat.a4.landscape.availableWidth;
          final double pageHeight = PdfPageFormat.a4.landscape.availableHeight;

          final double blankWidth = pageWidth * _blankWidthFraction * 0.94;
          final double blankCenterX = pageWidth * _blankCenterXFraction;
          final double baselineFromTop = pageHeight * _blankBaselineYFraction;

          double fontSize = 22;
          if (studentName.length > 20) fontSize = 18;
          if (studentName.length > 28) fontSize = 15;

          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(certificateImage, fit: pw.BoxFit.fill),
              ),
              pw.Positioned(
                left: blankCenterX - blankWidth / 2,
                top: baselineFromTop - fontSize,
                child: pw.SizedBox(
                  width: blankWidth,
                  child: pw.Center(
                    child: pw.Text(
                      studentName,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: fontSize,
                        color: _nameColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
