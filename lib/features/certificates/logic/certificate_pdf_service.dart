import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/models/certificate_model.dart';

class CertificatePdfService {
  static const _black      = PdfColor.fromInt(0xFF1A1A1A);
  static const _darkGrey   = PdfColor.fromInt(0xFF2C2C2C);
  static const _midGrey    = PdfColor.fromInt(0xFF6B6B6B);
  static const _lightGrey  = PdfColor.fromInt(0xFFD0D0D0);
  static const _silverBg   = PdfColor.fromInt(0xFFF4F4F4);
  static const _white      = PdfColors.white;

  static const String defaultKtrAdminTitle = 'Admin, Kolej Tun Razak';

  Future<Uint8List> generate({
    required CertificateModel cert,
    required String studentName,
  }) async {
    final isVolunteer = cert.certType == CertificateType.volunteer;

    final regular      = await PdfGoogleFonts.poppinsRegular();
    final bold         = await PdfGoogleFonts.poppinsBold();
    final italic       = await PdfGoogleFonts.poppinsItalic();
    final semiBold     = await PdfGoogleFonts.poppinsSemiBold();
    final playfair     = await PdfGoogleFonts.playfairDisplayBold();
    final playfairReg  = await PdfGoogleFonts.playfairDisplayRegular();
    final playfairItal = await PdfGoogleFonts.playfairDisplayItalic();
    final greatVibes   = await PdfGoogleFonts.greatVibesRegular();

    final ktrAdmin = await _getKtrAdminInfo();

    final certTypeLabel = isVolunteer
        ? 'OF APPRECIATION FOR VOLUNTARY SERVICE'
        : 'FOR EVENT PARTICIPATION ';

    final issuedDay   = cert.issuedAt.day;
    final issuedMonth = _monthName(cert.issuedAt.month);
    final issuedYear  = cert.issuedAt.year;

    final eventNameUpper = cert.eventName.toUpperCase();

    final bodyPrefix = isVolunteer
        ? 'With heartfelt thanks for your commitment and selfless contribution '
          'to the planning, coordination, and delivery of the'
        : 'With heartfelt thanks for your commitment and active participation '
          'in the planning, coordination, and delivery of the';

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (context) {
          return pw.Stack(
            children: [
              // ── White base ───────────────────────────────────────────
              pw.Container(color: _white),

              // ── Outer border ─────────────────────────────────────────
              pw.Container(
                margin: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _black, width: 2.5),
                ),
              ),

              // ── Inner thin border ─────────────────────────────────────
              pw.Container(
                margin: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _lightGrey, width: 0.8),
                ),
              ),

              // ── Silver inner fill ─────────────────────────────────────
              pw.Container(
                margin: const pw.EdgeInsets.all(21),
                color: _silverBg,
              ),

              // ── Main content ──────────────────────────────────────────
              pw.Container(
                margin: const pw.EdgeInsets.fromLTRB(40, 30, 40, 28),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [

                    _thinRule(),
                    pw.SizedBox(height: 10),

                    // CERTIFICATE
                    pw.Text(
                      'CERTIFICATE',
                      style: pw.TextStyle(
                        font: playfair,
                        fontSize: 38,
                        color: _black,
                        letterSpacing: 6,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),

                    pw.SizedBox(height: 2),

                    pw.Text(
                      certTypeLabel,
                      style: pw.TextStyle(
                        font: italic,
                        fontSize: 10,
                        color: _midGrey,
                        letterSpacing: 1.5,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),

                    pw.SizedBox(height: 8),
                    _ornamentRow(),
                    pw.SizedBox(height: 12),

                    pw.Text(
                      'THIS CERTIFICATE IS PROUDLY PRESENTED TO',
                      style: pw.TextStyle(
                        font: semiBold,
                        fontSize: 8,
                        color: _midGrey,
                        letterSpacing: 3,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),

                    pw.SizedBox(height: 10),

                    // Recipient name
                    pw.Text(
                      studentName,
                      style: pw.TextStyle(
                        font: greatVibes,
                        fontSize: 46,
                        color: _darkGrey,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),

                    pw.Container(
                      width: 320,
                      height: 0.8,
                      color: _lightGrey,
                      margin: const pw.EdgeInsets.only(top: 2, bottom: 12),
                    ),

                    // Body paragraph — event name bolded, date bolded
                    pw.RichText(
                      textAlign: pw.TextAlign.center,
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: bodyPrefix + '\n',
                            style: pw.TextStyle(
                              font: playfairReg,
                              fontSize: 10,
                              color: _darkGrey,
                              lineSpacing: 3,
                            ),
                          ),
                          // Event name — bold
                          pw.TextSpan(
                            text: eventNameUpper,
                            style: pw.TextStyle(
                              font: playfair,
                              fontSize: 11,
                              color: _black,
                              lineSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 8),

                    // Date line — bold date parts
                    pw.RichText(
                      textAlign: pw.TextAlign.center,
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Issued on the ',
                            style: pw.TextStyle(
                              font: playfairItal,
                              fontSize: 9,
                              color: _midGrey,
                            ),
                          ),
                          pw.TextSpan(
                            text:
                                '$issuedDay${_ordinal(issuedDay)} $issuedMonth $issuedYear',
                            style: pw.TextStyle(
                              font: playfair,
                              fontSize: 10,
                              color: _darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.Spacer(),

                    _ornamentRow(),
                    pw.SizedBox(height: 10),

                    // ── Signature row ─────────────────────────────────
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [

                        // Left — Organizer Head: completely blank, just line + label
                        _blankSignatureColumn(
                          label: 'ORGANIZER HEAD',
                          subLabel: 'KOLEJ TUN RAZAK',
                          font: regular,
                          semiBold: semiBold,
                        ),

                        // Centre — KTR stamp circle
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 56,
                              height: 56,
                              decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                border: pw.Border.all(
                                    color: _lightGrey, width: 1.5),
                                color: _white,
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Column(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    'KTR',
                                    style: pw.TextStyle(
                                      font: bold,
                                      fontSize: 12,
                                      color: _black,
                                    ),
                                  ),
                                  pw.Text(
                                    'UTM',
                                    style: pw.TextStyle(
                                      font: regular,
                                      fontSize: 7,
                                      color: _midGrey,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              cert.id.length > 14
                                  ? cert.id.substring(0, 14)
                                  : cert.id,
                              style: pw.TextStyle(
                                font: regular,
                                fontSize: 6.5,
                                color: _midGrey,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),

                        // Right — KTR Admin: improved signature + label only
                        _ktrSignatureColumn(
                          label: ktrAdmin['title']!,
                          subLabel: 'KOLEJ TUN RAZAK',
                          font: regular,
                          semiBold: semiBold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  // ── Blank organizer head — just empty space + line + label ────────────────

  pw.Widget _blankSignatureColumn({
    required String label,
    required String subLabel,
    required pw.Font font,
    required pw.Font semiBold,
  }) {
    return pw.SizedBox(
      width: 180,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Completely empty — physical signing space
          pw.SizedBox(height: 40),
          pw.Container(width: 180, height: 1, color: _darkGrey),
          pw.SizedBox(height: 5),
          pw.Text(
            label,
            style: pw.TextStyle(
              font: semiBold,
              fontSize: 8,
              color: _black,
              letterSpacing: 1,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            subLabel,
            style: pw.TextStyle(
              font: font,
              fontSize: 7,
              color: _midGrey,
              letterSpacing: 0.8,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── KTR Admin signature column ─────────────────────────────────────────────

  pw.Widget _ktrSignatureColumn({
    required String label,
    required String subLabel,
    required pw.Font font,
    required pw.Font semiBold,
  }) {
    return pw.SizedBox(
      width: 180,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(
            width: 180,
            height: 40,
            child: pw.CustomPaint(
              painter: (PdfGraphics canvas, PdfPoint size) {
                _drawKtrSignature(canvas, size);
              },
            ),
          ),
          pw.Container(width: 180, height: 1, color: _darkGrey),
          pw.SizedBox(height: 5),
          pw.Text(
            label,
            style: pw.TextStyle(
              font: semiBold,
              fontSize: 8,
              color: _black,
              letterSpacing: 1,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            subLabel,
            style: pw.TextStyle(
              font: font,
              fontSize: 7,
              color: _midGrey,
              letterSpacing: 0.8,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── KTR Admin signature — drawn carefully to look like a real signature ────
  //
  // Strategy: mimics a real academic/professional signature —
  //   1. A tall capital initial loop (like "A" or "H")
  //   2. A smooth connected body with 2–3 humps (like cursive letters)
  //   3. A long descending tail that curves back up
  //   4. A clean straight underline (not curved) below everything
  //
  void _drawKtrSignature(PdfGraphics canvas, PdfPoint size) {
    final w = size.x;
    final h = size.y;

    // ── Stroke 1: Tall capital initial — like an 'A' with a loop ────────────
    canvas
      ..setStrokeColor(_darkGrey)
      ..setLineWidth(1.5);

    // Left leg of capital
    canvas.moveTo(w * 0.05, h * 0.85);
    canvas.curveTo(
      w * 0.07, h * 0.60,
      w * 0.08, h * 0.12,
      w * 0.13, h * 0.10,
    );
    canvas.strokePath();

    // Right leg of capital curving back down
    canvas.moveTo(w * 0.13, h * 0.10);
    canvas.curveTo(
      w * 0.18, h * 0.12,
      w * 0.18, h * 0.50,
      w * 0.20, h * 0.82,
    );
    canvas.strokePath();

    // Cross bar of the capital
    canvas
      ..setLineWidth(1.2)
      ..moveTo(w * 0.06, h * 0.48)
      ..lineTo(w * 0.19, h * 0.48);
    canvas.strokePath();

    // ── Stroke 2: Connected cursive body — 3 smooth humps ───────────────────
    canvas
      ..setLineWidth(1.4)
      ..moveTo(w * 0.20, h * 0.82);

    // First hump
    canvas.curveTo(
      w * 0.24, h * 0.55,
      w * 0.28, h * 0.30,
      w * 0.33, h * 0.55,
    );
    canvas.strokePath();

    // Second hump — slightly taller
    canvas.moveTo(w * 0.33, h * 0.55);
    canvas.curveTo(
      w * 0.38, h * 0.22,
      w * 0.44, h * 0.22,
      w * 0.49, h * 0.55,
    );
    canvas.strokePath();

    // Third hump
    canvas.moveTo(w * 0.49, h * 0.55);
    canvas.curveTo(
      w * 0.53, h * 0.32,
      w * 0.58, h * 0.32,
      w * 0.62, h * 0.58,
    );
    canvas.strokePath();

    // ── Stroke 3: Descending tail with upward flick ──────────────────────────
    canvas.moveTo(w * 0.62, h * 0.58);
    canvas.curveTo(
      w * 0.67, h * 0.75,
      w * 0.72, h * 0.88,
      w * 0.78, h * 0.80,
    );
    canvas.strokePath();

    canvas.moveTo(w * 0.78, h * 0.80);
    canvas.curveTo(
      w * 0.84, h * 0.72,
      w * 0.88, h * 0.55,
      w * 0.92, h * 0.62,
    );
    canvas.strokePath();

    // ── Stroke 4: Clean straight underline — no wobble ──────────────────────
    canvas
      ..setLineWidth(1.0)
      ..setStrokeColor(_darkGrey)
      ..moveTo(w * 0.04, h * 0.96)
      ..lineTo(w * 0.93, h * 0.96);
    canvas.strokePath();
  }

  // ── Thin full-width rule ───────────────────────────────────────────────────

  pw.Widget _thinRule() {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Container(height: 0.8, color: _lightGrey),
        ),
      ],
    );
  }

  // ── Ornament row ───────────────────────────────────────────────────────────

  pw.Widget _ornamentRow() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Container(width: 30, height: 0.8, color: _lightGrey),
        pw.SizedBox(width: 5),
        pw.Container(
          width: 5, height: 5,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            color: _lightGrey,
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Container(width: 10, height: 0.8, color: _lightGrey),
        pw.SizedBox(width: 5),
        pw.Transform.rotate(
          angle: 0.785,
          child: pw.Container(width: 6, height: 6, color: _midGrey),
        ),
        pw.SizedBox(width: 5),
        pw.Container(width: 10, height: 0.8, color: _lightGrey),
        pw.SizedBox(width: 5),
        pw.Container(
          width: 5, height: 5,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            color: _lightGrey,
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Container(width: 30, height: 0.8, color: _lightGrey),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  String _ordinal(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  Future<Map<String, String>> _getKtrAdminInfo() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('certificateConfig')
          .get();
      final data = doc.data();
      return {
        'title': (data?['ktrAdminTitle'] as String?) ?? defaultKtrAdminTitle,
      };
    } catch (_) {
      return {'title': defaultKtrAdminTitle};
    }
  }
}