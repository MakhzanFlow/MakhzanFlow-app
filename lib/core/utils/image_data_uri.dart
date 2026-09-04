import 'dart:convert';
import 'dart:io';

/// Converts a local image file into a base64 data URI so it can be sent to
/// the backend (which uploads it to Cloudinary).
Future<String> fileToDataUri(File file) async {
  final extension = file.path.split('.').last.toLowerCase();
  final mime = switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'gif' => 'image/gif',
    'heic' || 'heif' => 'image/heic',
    _ => 'image/jpeg',
  };
  final bytes = await file.readAsBytes();
  return 'data:$mime;base64,${base64Encode(bytes)}';
}