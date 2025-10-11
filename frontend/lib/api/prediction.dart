import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> prediction(
  List<Map<String, dynamic>> predata,
) async {
  var uri = Uri.http("localhost:3000", "/api/modal");
  Map<String, dynamic> body = {"data": predata};
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
    return {"message": "error when post!"};
  }
}
