import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> addChat({
  required String username,
  required String label,
}) async {
  Map<String, dynamic> body = {"username": username, "label": label};
  var uri = Uri.parse("http://localhost:3000/api/agent/chat/collection/add");
  try {
    print("api : $username ,  $label");
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
