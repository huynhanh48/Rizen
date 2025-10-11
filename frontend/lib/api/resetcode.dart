import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> resetcode({required String email}) async {
  Map<String, dynamic> body = {"email": email};

  var uri = Uri.http("localhost:3000", "/api/authentication/resetcode");

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
