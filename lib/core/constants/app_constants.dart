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

  /// Offline mutation queue (see lib/core/sync/): bounded FIFO persisted as
  /// JSON in SharedPreferences. Replay is sequential, one request at a time.
  static const pendingOpsKey = 'mf_pending_ops_v1';
  static const needsReviewKey = 'mf_needs_review_v1';
  static const pendingOpsCap = 100;
  static const maxSyncAttempts = 5;

  /// Prefix for client-generated ids of locally queued creates. Entities
  /// carrying it are optimistic (unsynced): shown with a pending badge and
  /// opened read-only until the server record replaces them after sync.
  static const pendingIdPrefix = 'pending_';

  /// Last-good GET responses (stale-while-offline read cache).
  static const getCacheKey = 'mf_get_cache_v1';
  static const getCacheCap = 50;

  /// Last signed-in user snapshot for offline session restore.
  static const lastUserKey = 'mf_last_user_v1';

  /// Last selected company + membership snapshot for offline restore.
  static const lastCompanyKey = 'mf_last_company_v1';
}
