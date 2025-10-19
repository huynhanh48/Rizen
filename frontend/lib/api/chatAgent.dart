import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> sendQuestion({
  required String username,
  required String question,
  required String labelname,
  bool hadFile = false,
  File? file,
}) async {
  final uri = Uri.parse("http://localhost:3000/api/agent/chat");
  var request = http.MultipartRequest("POST", uri);

  request.fields["username"] = username;
  request.fields["question"] = question;
  request.fields["labelname"] = labelname;

  if (hadFile && file != null) {
    request.files.add(await http.MultipartFile.fromPath("file", file.path));
  }

  try {
    var response = await request.send();

    var body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      // parse JSON trả về từ server
      return jsonDecode(body) as Map<String, dynamic>;
    } else {
      return {
        "message": "Server error",
        "status": response.statusCode,
        "body": body,
      };
    }
  } catch (e) {
    return {"message": "API failed", "error": e.toString()};
  }
}
