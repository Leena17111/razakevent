import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/models/certificate_model.dart';

class CertificatePdfService {
  // ── Colours ───────────────────────────────────────────────────────────────

  static const _navy      = PdfColor.fromInt(0xFF003F7D);
  static const _gold      = PdfColor.fromInt(0xFFD4A017);
  static const _black     = PdfColor.fromInt(0xFF1A1A1A);
  static const _darkGrey  = PdfColor.fromInt(0xFF2C2C2C);
  static const _midGrey   = PdfColor.fromInt(0xFF6B6B6B);
  static const _lightGrey = PdfColor.fromInt(0xFFD0D0D0);
  static const _white     = PdfColors.white;

  // ── Defaults ──────────────────────────────────────────────────────────────

  static const String defaultKtrAdminName  = 'Faiznureza binti Mohamad Pauzi';
  static const String defaultKtrAdminTitle = 'Pengetua Kolej Tun Razak';

  // ── Public API ────────────────────────────────────────────────────────────

  Future<Uint8List> generate({
    required CertificateModel cert,
    required String studentName,
    String locale = 'ms', // default Malay
  }) async {
    final isVolunteer = cert.certType == CertificateType.volunteer;

    // Fonts
    final regular    = await PdfGoogleFonts.poppinsRegular();
    final bold       = await PdfGoogleFonts.poppinsBold();
    final semiBold   = await PdfGoogleFonts.poppinsSemiBold();
    final italic     = await PdfGoogleFonts.poppinsItalic();
    final greatVibes = await PdfGoogleFonts.greatVibesRegular();

    // Assets
    final utmLogo = await _loadAsset('assets/images/utm_logo.png');
    final ktrLogo = await _loadAsset('assets/images/ktr_logo.png');

    // Remote data
    final eventInfo    = await _getEventInfo(cert.eventId);
    final ktrAdmin     = await _getKtrAdminInfo();
    final matricNumber = await _getMatricNumber(cert.userId);

    // ── All strings in Malay ──────────────────────────────────────────────
    final titleText = isVolunteer ? 'Sijil Penghargaan' : 'Sijil Penyertaan';
    const certifyLine     = 'Adalah dengan ini diperakui bahawa';
    final participationLine = isVolunteer
        ? 'telah memberikan khidmat sukarela dengan jayanya dalam'
        : 'telah menyertai dengan jayanya';
    const organizedByLabel = 'Anjuran';
    const datedLabel       = 'bertarikh';

    final dateStr =
        '${cert.issuedAt.day} ${_monthNameMs(cert.issuedAt.month)} ${cert.issuedAt.year}';

    // ── Build PDF ─────────────────────────────────────────────────────────
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (_) => pw.Stack(
          children: [
            // White background
            pw.Container(color: _white),

            // Corner decorations
            pw.Positioned.fill(
              child: pw.CustomPaint(
                painter: (canvas, size) => _drawCorners(canvas, size),
              ),
            ),

            // Thin outer border
            pw.Container(
              margin: const pw.EdgeInsets.all(28),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _lightGrey, width: 0.8),
              ),
            ),

            // Main content
            pw.Container(
              margin: const pw.EdgeInsets.fromLTRB(50, 55, 50, 45),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [

                  // ── Logos ──────────────────────────────────────────────
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Image(utmLogo, width: 150, height: 48, fit: pw.BoxFit.contain),
                      pw.SizedBox(width: 28),
                      pw.Image(ktrLogo, width: 58, height: 58, fit: pw.BoxFit.contain),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // ── Title (Great Vibes script) ─────────────────────────
                  pw.Text(
                    titleText,
                    style: pw.TextStyle(font: greatVibes, fontSize: 46, color: _darkGrey),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 14),

                  // ── Certify line ───────────────────────────────────────
                  pw.Text(
                    certifyLine,
                    style: pw.TextStyle(
                      font: semiBold, fontSize: 9,
                      color: _midGrey, letterSpacing: 1.5,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 10),

                  // ── Student name ───────────────────────────────────────
                  pw.Text(
                    studentName.toLowerCase(), // matches reference style
                    style: pw.TextStyle(font: bold, fontSize: 18, color: _black),
                    textAlign: pw.TextAlign.center,
                  ),

                  // ── Matric number ──────────────────────────────────────
                  if (matricNumber.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    pw.Text(
                      matricNumber.toUpperCase(),
                      style: pw.TextStyle(font: semiBold, fontSize: 10, color: _darkGrey),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                  pw.SizedBox(height: 12),

                  // ── Participation line ─────────────────────────────────
                  pw.Text(
                    participationLine,
                    style: pw.TextStyle(font: regular, fontSize: 10, color: _darkGrey),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 8),

                  // ── Event name ─────────────────────────────────────────
                  pw.Text(
                    cert.eventName.toUpperCase(),
                    style: pw.TextStyle(font: bold, fontSize: 13, color: _black),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 20),

                  // ── Organizer label ────────────────────────────────────
                  pw.Text(
                    organizedByLabel,
                    style: pw.TextStyle(font: italic, fontSize: 9, color: _midGrey),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    eventInfo['organizationName']!.toUpperCase(),
                    style: pw.TextStyle(font: semiBold, fontSize: 10, color: _darkGrey),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 20),

                  // ── Date ──────────────────────────────────────────────
                  pw.Text(
                    datedLabel,
                    style: pw.TextStyle(font: italic, fontSize: 9, color: _midGrey),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    dateStr,
                    style: pw.TextStyle(font: bold, fontSize: 11, color: _darkGrey),
                    textAlign: pw.TextAlign.center,
                  ),

                  pw.Spacer(),

                  // ── Signature ─────────────────────────────────────────
                  pw.SizedBox(
                    width: 200,
                    height: 44,
                    child: pw.CustomPaint(
                      painter: (canvas, size) => _drawSignature(canvas, size),
                    ),
                  ),
                  pw.Container(width: 200, height: 1, color: _darkGrey),
                  pw.SizedBox(height: 6),

                  // ── Admin name & title ─────────────────────────────────
                  pw.Text(
                    ktrAdmin['name']!.toUpperCase(),
                    style: pw.TextStyle(font: semiBold, fontSize: 9, color: _black),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    ktrAdmin['title']!.toUpperCase(),
                    style: pw.TextStyle(font: regular, fontSize: 8, color: _midGrey),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'UNIVERSITI TEKNOLOGI MALAYSIA',
                    style: pw.TextStyle(font: regular, fontSize: 8, color: _midGrey),
                    textAlign: pw.TextAlign.center,
                  ),

                  pw.SizedBox(height: 14),

                  // ── Cert ID ───────────────────────────────────────────
                  pw.Text(
                    'Cert ID: ${cert.id}',
                    style: pw.TextStyle(font: regular, fontSize: 6.5, color: _lightGrey),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  // ── Asset loading ─────────────────────────────────────────────────────────

  Future<pw.MemoryImage> _loadAsset(String path) async {
    final data = await rootBundle.load(path);
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  // ── Decorative painters ───────────────────────────────────────────────────

  /// Matches the reference: large navy triangles top-right & bottom-left,
  /// with a diagonal gold stripe across each corner.
  void _drawCorners(PdfGraphics canvas, PdfPoint size) {
    final w = size.x;
    final h = size.y;

    // ── Top-right corner ──────────────────────────────────────────────────

    // Navy filled triangle
    canvas
      ..setFillColor(_navy)
      ..moveTo(w, 0)
      ..lineTo(w, h * 0.22)
      ..lineTo(w * 0.78, 0)
      ..closePath()
      ..fillPath();

    // Gold diagonal stripe (wide, matches reference)
    canvas
      ..setFillColor(_gold)
      ..moveTo(w * 0.78, 0)
      ..lineTo(w * 0.84, 0)
      ..lineTo(w, h * 0.06)
      ..lineTo(w, h * 0.12)
      ..closePath()
      ..fillPath();

    // ── Bottom-left corner ────────────────────────────────────────────────

    // Navy filled triangle
    canvas
      ..setFillColor(_navy)
      ..moveTo(0, h)
      ..lineTo(0, h * 0.78)
      ..lineTo(w * 0.22, h)
      ..closePath()
      ..fillPath();

    // Gold diagonal stripe
    canvas
      ..setFillColor(_gold)
      ..moveTo(0, h * 0.88)
      ..lineTo(0, h * 0.94)
      ..lineTo(w * 0.06, h)
      ..lineTo(w * 0.12, h)
      ..closePath()
      ..fillPath();
  }

  void _drawSignature(PdfGraphics canvas, PdfPoint size) {
    final w = size.x;
    final h = size.y;

    canvas
      ..setStrokeColor(_darkGrey)
      ..setLineWidth(1.4)
      ..moveTo(w * 0.05, h * 0.70)
      ..curveTo(w * 0.10, h * 0.20, w * 0.18, h * 0.20, w * 0.24, h * 0.60)
      ..strokePath()
      ..moveTo(w * 0.24, h * 0.60)
      ..curveTo(w * 0.30, h * 0.90, w * 0.38, h * 0.90, w * 0.44, h * 0.40)
      ..strokePath()
      ..moveTo(w * 0.44, h * 0.40)
      ..curveTo(w * 0.52, h * 0.00, w * 0.62, h * 0.00, w * 0.66, h * 0.50)
      ..strokePath()
      ..moveTo(w * 0.66, h * 0.50)
      ..curveTo(w * 0.74, h * 0.90, w * 0.84, h * 0.90, w * 0.92, h * 0.30)
      ..strokePath();
  }

  // ── Date helper (Malay only) ──────────────────────────────────────────────

  String _monthNameMs(int m) => const [
    'JAN', 'FEB', 'MAC', 'APR', 'MEI', 'JUN',
    'JUL', 'OGO', 'SEP', 'OKT', 'NOV', 'DIS',
  ][m - 1];

  // ── Firestore helpers ─────────────────────────────────────────────────────

  Future<Map<String, String>> _getEventInfo(String eventId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();
      return {
        'organizationName':
            (doc.data()?['organizationName'] as String?) ?? 'Kolej Tun Razak',
      };
    } catch (_) {
      return {'organizationName': 'Kolej Tun Razak'};
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
        'name':  (data?['ktrAdminName']  as String?) ?? defaultKtrAdminName,
        'title': (data?['ktrAdminTitle'] as String?) ?? defaultKtrAdminTitle,
      };
    } catch (_) {
      return {
        'name':  defaultKtrAdminName,
        'title': defaultKtrAdminTitle,
      };
    }
  }

  /// TODO: confirm field name from user_model.dart
  Future<String> _getMatricNumber(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final data = doc.data();
      return (data?['matricNo']     as String?)
          ?? (data?['matricNumber'] as String?)
          ?? (data?['studentId']    as String?)
          ?? '';
    } catch (_) {
      return '';
    }
  }
}