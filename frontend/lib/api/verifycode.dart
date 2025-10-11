import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> verifycode({
  required String email,
  required String code,
}) async {
  Map<String, dynamic> body = {"email": email, "code": code};

  var uri = Uri.http("localhost:3000", "/api/authentication/verify");

  try {
    var response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    }
  } catch (e) {
    return {"message": "error!"};
  }
}
