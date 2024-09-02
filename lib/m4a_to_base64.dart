import 'dart:convert';
import 'dart:io';

Future<String> convertM4aToBase64(String recordFileName) async {
  final file = File(recordFileName);
  List<int> fileBytes = await file.readAsBytes();
  String base64String = base64Encode(fileBytes);
  return base64String;
}
