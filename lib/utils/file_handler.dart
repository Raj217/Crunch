import 'package:file_picker/file_picker.dart';

class FileHandler {
  static Future<String?> pick() async {
    FilePickerResult? file = await FilePicker.platform.pickFiles(
        type: FileType.image,
        dialogTitle: 'Pick an attachment',
        withData: true);
    return file?.paths[0];
  }
}
