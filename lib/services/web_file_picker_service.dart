import 'package:optmsg/services/common_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

class WebFilePickerService {
  /// Picks a single file from the user's device and returns its details.
  ///
  /// The function allows the user to select a file with the following extensions:
  /// ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx']. If a file is selected, it
  /// returns a map containing the file's bytes and name. Returns `null` if no
  /// file is selected or if an error occurs during the file picking process.

  // M-12: Allowed MIME type prefixes/types for validation alongside extension check
  static const _allowedMimePrefixes = [
    'image/',
    'video/',
    'audio/',
    'text/',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument',
    'application/vnd.ms-excel',
    'application/vnd.ms-powerpoint',
    'application/vnd.oasis.opendocument',
    'application/rtf',
    'application/zip',
    'application/x-rar',
    'application/x-7z-compressed',
    'application/x-tar',
    'application/gzip',
    'application/json',
    'application/xml',
    'application/postscript',
    'application/octet-stream', // fallback for .ai, .indd, .psd etc.
  ];

  static Future<Map<String, dynamic>?> pickFile() async {
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
          'psd',
          'ai',
          'eps',
          'svg',
          'indd',
        ],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // M-12: Validate MIME type alongside extension to prevent renamed files
        final mimeType = lookupMimeType(file.name, headerBytes: file.bytes) ?? '';
        if (mimeType.isNotEmpty &&
            !_allowedMimePrefixes.any((prefix) => mimeType.startsWith(prefix))) {
          CommonService.animatedToast(
              'File type not allowed: $mimeType', 'error');
          return null;
        }

        return {
          'bytes': file.bytes,
          'name': file.name,
        };
      }
    } catch (e) {
      CommonService.animatedToast('Something went wrong', 'error');
    }
    return null;
  }

  /// Pick an image file from the gallery using file_picker.
  /// Unlike ImagePicker, this preserves the original filename from the device.
  static Future<Map<String, dynamic>?> pickImageFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        return {
          'bytes': file.bytes,
          'name': file.name,
        };
      }
    } catch (e) {
      CommonService.animatedToast('Something went wrong', 'error');
    }
    return null;
  }

  /// Pick multiple files with MIME validation.
  /// Returns a list of maps with 'bytes' and 'name', or null if canceled.
  static Future<List<Map<String, dynamic>>?> pickFiles() async {
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
          'psd', 'ai', 'eps', 'svg', 'indd',
        ],
      );
      if (result != null && result.files.isNotEmpty) {
        final validFiles = <Map<String, dynamic>>[];
        for (final file in result.files) {
          final mimeType =
              lookupMimeType(file.name, headerBytes: file.bytes) ?? '';
          if (mimeType.isNotEmpty &&
              !_allowedMimePrefixes
                  .any((prefix) => mimeType.startsWith(prefix))) {
            CommonService.animatedToast(
                'File type not allowed: ${file.name}', 'error');
            continue;
          }
          validFiles.add({'bytes': file.bytes, 'name': file.name});
        }
        return validFiles.isNotEmpty ? validFiles : null;
      }
    } catch (e) {
      CommonService.animatedToast('Something went wrong', 'error');
    }
    return null;
  }

  /// Pick multiple image files from the gallery.
  /// Returns a list of maps with 'bytes' and 'name', or null if canceled.
  static Future<List<Map<String, dynamic>>?> pickImageFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files
            .map((file) => <String, dynamic>{
                  'bytes': file.bytes,
                  'name': file.name,
                })
            .toList();
      }
    } catch (e) {
      CommonService.animatedToast('Something went wrong', 'error');
    }
    return null;
  }
}
