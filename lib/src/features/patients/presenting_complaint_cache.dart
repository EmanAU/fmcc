import 'package:shared_preferences/shared_preferences.dart';

/// One pending presenting complaint per patient until visit create succeeds.
class PresentingComplaintCache {
  PresentingComplaintCache._();

  static const maxLength = 255;
  static const _prefix = 'patient.pendingComplaint.';

  static String _key(String patientId) => '$_prefix${patientId.trim()}';

  /// Returns trimmed text, or null if missing/empty.
  static Future<String?> load(String patientId) async {
    final id = patientId.trim();
    if (id.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(id))?.trim() ?? '';
    if (raw.isEmpty) return null;
    if (raw.length > maxLength) return raw.substring(0, maxLength);
    return raw;
  }

  /// Saves trimmed text. Empty text clears the entry. Throws [ArgumentError]
  /// if longer than [maxLength].
  static Future<void> save(String patientId, String text) async {
    final id = patientId.trim();
    if (id.isEmpty) return;
    final trimmed = text.trim();
    final prefs = await SharedPreferences.getInstance();
    if (trimmed.isEmpty) {
      await prefs.remove(_key(id));
      return;
    }
    if (trimmed.length > maxLength) {
      throw ArgumentError(
        'Presenting complaint must be at most $maxLength characters.',
      );
    }
    await prefs.setString(_key(id), trimmed);
  }

  static Future<void> clear(String patientId) async {
    final id = patientId.trim();
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(id));
  }
}
