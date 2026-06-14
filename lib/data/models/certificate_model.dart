import 'package:cloud_firestore/cloud_firestore.dart';

enum CertificateType { participation, volunteer }

class CertificateModel {
  final String id;
  final String userId;
  final String eventId;
  final String eventName;
  final CertificateType certType;
  final DateTime issuedAt;
  final String? downloadUrl;

  const CertificateModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.eventName,
    required this.certType,
    required this.issuedAt,
    this.downloadUrl,
  });

  factory CertificateModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CertificateModel(
      id: doc.id,
      userId: data['userId'] as String,
      eventId: data['eventId'] as String,
      eventName: data['eventName'] as String,
      certType: (data['certType'] as String) == 'volunteer'
          ? CertificateType.volunteer
          : CertificateType.participation,
      issuedAt: (data['issuedAt'] as Timestamp).toDate(),
      downloadUrl: data['downloadUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'eventName': eventName,
      'certType': certType == CertificateType.volunteer
          ? 'volunteer'
          : 'participation',
      'issuedAt': Timestamp.fromDate(issuedAt),
      if (downloadUrl != null) 'downloadUrl': downloadUrl,
    };
  }

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${issuedAt.day} ${months[issuedAt.month - 1]} ${issuedAt.year}';
  }
}