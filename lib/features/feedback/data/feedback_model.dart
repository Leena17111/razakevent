import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String? id;
  final String eventId;
  final String eventTitle;
  final String studentId;
  final String studentName;
  final Map<String, int> builtInRatings;
  final Map<String, int> additionalRatings;
  final Map<String, String> customResponses;
  final String comments;
  final DateTime submittedAt;

  FeedbackModel({
    this.id,
    required this.eventId,
    required this.eventTitle,
    required this.studentId,
    required this.studentName,
    required this.builtInRatings,
    required this.additionalRatings,
    this.customResponses = const {},
    required this.comments,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'studentId': studentId,
      'studentName': studentName,
      'builtInRatings': builtInRatings,
      'additionalRatings': additionalRatings,
      'customResponses': customResponses,
      'comments': comments,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  factory FeedbackModel.fromMap(String id, Map<String, dynamic> map) {
    return FeedbackModel(
      id: id,
      eventId: map['eventId'] ?? '',
      eventTitle: map['eventTitle'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      builtInRatings: Map<String, int>.from(map['builtInRatings'] ?? {}),
      additionalRatings: Map<String, int>.from(map['additionalRatings'] ?? {}),
      customResponses: Map<String, String>.from(map['customResponses'] ?? {}),
      comments: map['comments'] ?? '',
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
    );
  }
}