import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/certificate_model.dart';
import '../logic/certificate_pdf_service.dart';

class CertificatePreviewScreen extends StatelessWidget {
  const CertificatePreviewScreen({
    super.key,
    required this.cert,
    required this.studentName,
  });

  final CertificateModel cert;
  final String studentName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          cert.eventName,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: PdfPreview(
        build: (format) => CertificatePdfService().generate(
          cert: cert,
          studentName: studentName,
        ),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      ),
    );
  }
}