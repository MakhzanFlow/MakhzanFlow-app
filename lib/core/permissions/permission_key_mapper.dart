/// Translates between the app's client permission keys (`.view`, legacy
/// `invoices.cancel`) and the backend's canonical keys (`.read`,
/// `invoices.delete`).
///
/// Backend review renames (server-enforced):
/// - cancel invoice: `invoices.cancel` → `invoices.delete`
/// - read gates: `payments.read`, `reports.read` (and per-entity
///   `products.read` / `invoices.read` / `customers.read` for activity logs)
///
/// The client keeps its existing `.view` vocabulary internally; translation
/// happens at the wire boundary (role editor load/save) and as alias
/// fallbacks in [PermissionServiceImpl.hasPermission], so roles stored under
/// either spelling keep working during the migration window.
abstract class PermissionKeyMapper {
  /// Client key → backend key for outbound payloads (role editor save).
  /// Unknown keys pass through unchanged.
  static String toBackendKey(String clientKey) {
    return _clientToBackend[clientKey] ?? clientKey;
  }

  /// Backend key → client key for inbound payloads (role editor load,
  /// permission list responses). Unknown keys pass through unchanged.
  static String toClientKey(String backendKey) {
    return _backendToClient[backendKey] ?? backendKey;
  }

  /// All spellings accepted for a client key at runtime gating time.
  /// First entry is the client key itself, followed by backend equivalents
  /// and legacy spellings.
  static List<String> aliasesFor(String clientKey) {
    final backend = _clientToBackend[clientKey];
    final legacy = _legacyAliases[clientKey];
    return [
      clientKey,
      ?backend,
      ...?legacy,
    ];
  }

  static const Map<String, String> _clientToBackend = {
    'products.view': 'products.read',
    'customers.view': 'customers.read',
    'invoices.view': 'invoices.read',
    'payments.view': 'payments.read',
    'reports.view': 'reports.read',
    'invoices.cancel': 'invoices.delete',
  };

  static final Map<String, String> _backendToClient = {
    for (final e in _clientToBackend.entries) e.value: e.key,
    // Legacy stored roles may already carry the new cancel spelling.
    'invoices.delete': 'invoices.delete',
  };

  /// Legacy spellings that must still grant access after the rename.
  static const Map<String, List<String>> _legacyAliases = {
    // Roles saved before the backend review carry invoices.cancel.
    'invoices.delete': ['invoices.cancel'],
    // Roles saved with the old view spelling after a backend-side rename.
    'products.view': ['products.read'],
    'customers.view': ['customers.read'],
    'invoices.view': ['invoices.read'],
    'payments.view': ['payments.read'],
    'reports.view': ['reports.read'],
  };
}
