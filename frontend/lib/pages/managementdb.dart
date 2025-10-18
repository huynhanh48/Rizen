import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobileapp/api/updateVector.dart';
import 'package:mobileapp/utils/wrapperbar.dart';

class Managementdb extends StatefulWidget {
  const Managementdb({super.key});

  @override
  State<Managementdb> createState() => _ManagementdbState();
}

class _ManagementdbState extends State<Managementdb> {
  TextEditingController _captionController = TextEditingController();
  TextEditingController _labelController = TextEditingController();
  String filepath = "";

  File? selectedFile;

  Future<void> pickerFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (result == null) return;

    final file = File(result.files.single.path!);
    setState(() {
      selectedFile = file;
      filepath = file.path;
    });
  }

  Future<void> uploadData() async {
    if (selectedFile == null) return;
    print(selectedFile);
    final label = _labelController.text.trim();
    final caption = _captionController.text.trim();

    final response = await addImageVector(label, caption, selectedFile!);
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return WrapperBar(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label input

          // Buttons
          SizedBox(
            width: double.infinity,
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.image, size: 30, color: Colors.white),
                    label: Text(
                      "Chọn File",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: pickerFile,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        Colors.green.shade400,
                      ),
                      shadowColor: MaterialStateProperty.all(Colors.grey),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.publish, size: 30, color: Colors.white),
                    label: Text(
                      "Nạp dữ liệu",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: uploadData,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        Colors.green.shade400,
                      ),
                      shadowColor: MaterialStateProperty.all(Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 40),
          // Image preview
          SizedBox(
            height: 300,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: filepath.isEmpty
                  ? Center(child: Text("Chưa chọn file"))
                  : Image.file(File(filepath), fit: BoxFit.cover),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _labelController,
              decoration: InputDecoration(
                hintText: "Nhập label cho ảnh",
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
          // Caption input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _captionController,
              maxLines: 6,
              cursorColor: Colors.grey.shade400,
              decoration: InputDecoration(
                hintText: "Nhập mô tả cho ảnh...",
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
