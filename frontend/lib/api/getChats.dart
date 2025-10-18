import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> getChats({
  String username = "",
  String slug = "",
}) async {
  var uri = Uri.http("localhost:3000", "/api/agent/chat/collecton/get", {
    "username": username,
    "slug": slug,
  });

  try {
    var response = await http.get(uri);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    }
  } catch (e) {
    return {"message": "error when  get!"};
  }
}
