import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> resetPassword({required String email}) async {
  Map<String, dynamic> body = {"email": email};
  var uri = Uri.http("localhost:3000", "/api/authentication/resetpassword");
  try {
    var response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );
    final Map<String, dynamic> result = jsonDecode(response.body);
    return result;
  } catch (e) {
    return {"message": "error!"};
  }
}
