/// Centralized app-wide constants.
abstract class AppConstants {
  static const imageContentType = 'image/jpeg';
  static const maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  /// Company logos are sent as base64 JSON — the backend rejects images
  /// over ~2MB, so compress/pick smaller before sending.
  static const maxLogoSizeBytes = 2 * 1024 * 1024; // 2MB
  static const defaultPageSize = 20;
  static const connectTimeoutMs = 10000;
  static const receiveTimeoutMs = 15000;
}
