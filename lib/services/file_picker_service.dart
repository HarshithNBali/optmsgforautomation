import 'package:file_picker/file_picker.dart';

class FilePickerService {
  /// Pick a file from the file picker.
  ///
  /// The user is presented with a file picker dialog, from which they can select
  /// a single file of the following types: jpg, jpeg, png, pdf, doc, docx. If
  /// the user selects a file, the path of that file is returned. If the user
  /// cancels the picker, null is returned. If an error occurs, null is returned.
  ///
  /// Returns a [Future] that resolves with the path of the selected file, or null
  /// if the user canceled the picker or an error occurred.
  static Future<String?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'bmp',
          'tiff',
          'webp',
          'pdf',
          'doc',
          'docx',
          'odt',
          'rtf',
          'txt',
          'xls',
          'xlsx',
          'csv',
          'ods',
          'ppt',
          'pptx',
          'odp',
          'zip',
          'rar',
          '7z',
          'tar',
          'gz',
          'mp4',
          'mov',
          'avi',
          'mkv',
          'wmv',
          'flv',
          'webm',
          'mp3',
          'wav',
          'aac',
          'ogg',
          'flac',
          'm4a',
          'html',
          'htm',
          'xml',
          'json',
          'exe',
          'msi',
          'bat',
          'sh',
          'apk',
          'iso',
          'dmg',
          'psd',
          'ai',
          'eps',
          'svg',
          'indd',
        ],
      );
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        return path;
      } else {
        // User canceled the picker
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Pick an image file from the gallery using file_picker.
  /// Unlike ImagePicker, this preserves the original filename from the device.
  static Future<String?> pickImageFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick multiple files from the file picker.
  ///
  /// Same allowed extensions as [pickFile], but with multi-select enabled.
  /// Returns a list of file paths, or null if the user canceled or an error occurred.
  static Future<List<String>?> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'webp',
          'pdf', 'doc', 'docx', 'odt', 'rtf', 'txt',
          'xls', 'xlsx', 'csv', 'ods',
          'ppt', 'pptx', 'odp',
          'zip', 'rar', '7z', 'tar', 'gz',
          'mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm',
          'mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a',
          'html', 'htm', 'xml', 'json',
          'exe', 'msi', 'bat', 'sh', 'apk', 'iso', 'dmg',
          'psd', 'ai', 'eps', 'svg', 'indd',
        ],
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((f) => f.path != null)
            .map((f) => f.path!)
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick multiple image files from the gallery using file_picker.
  /// Returns a list of file paths, or null if the user canceled or an error occurred.
  static Future<List<String>?> pickImageFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((f) => f.path != null)
            .map((f) => f.path!)
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
