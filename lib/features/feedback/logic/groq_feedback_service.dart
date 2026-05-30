import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razakevent/core/secrets.dart';

class GroqFeedbackService {
    Future<String> summarizeFeedback(List<Map<String, dynamic>> feedbackList) async {
    final feedbackText = feedbackList.map((f) {
      final ratings = (f['builtInRatings'] as Map<String, dynamic>?)
              ?.entries
              .map((e) => '${e.key}: ${e.value}/5')
              .join(', ') ??
          'No ratings';
      final comment = f['comments'] ?? 'No comment';
      return '- Ratings: $ratings | Comment: $comment';
    }).join('\n');

    final prompt = '''
You are summarizing student feedback for a university event.
Here are the responses:

$feedbackText

Write a short 3-4 sentence summary of the overall sentiment, what students liked, and any concerns raised.
''';

    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $groqApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? 'No summary available.';
    } else {
      throw Exception('Failed: ${response.statusCode} - ${response.body}');
    }
  }
}