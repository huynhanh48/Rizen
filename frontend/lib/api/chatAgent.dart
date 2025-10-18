import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> sendQuestion({
  required String username,
  required String question,
  required String labelname,
}) async {
  final uri = Uri.http("localhost:3000", "/api/agent/chat");

  try {
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "labelname": labelname,
        "question": question,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {"message": "Server error", "status": response.statusCode};
    }
  } catch (e) {
    return {"message": "Network error: $e"};
  }
}
