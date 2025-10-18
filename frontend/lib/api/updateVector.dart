import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> addImageVector(
  String label,
  String caption,
  File file,
) async {
  try {
    var uri = Uri.http("localhost:3000", "/api/agent");
    var request = http.MultipartRequest('POST', uri);

    // Thêm file
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    // Thêm các field khác
    request.fields['label'] = label;
    request.fields['caption'] = caption;

    var streamedResponse = await request.send();
    var responseString = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 201) {
      return jsonDecode(responseString);
    } else {
      return jsonDecode(responseString);
    }
  } catch (e) {
    print("Error: $e");
    return {"message": "error when post!"};
  }
}
