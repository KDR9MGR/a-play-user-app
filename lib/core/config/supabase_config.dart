class SupabaseConfig {
  // Hardcoded Supabase credentials
  static const String _hardcodedProjectUrl = 'https://yvnfhsipyfxdmulajbgl.supabase.co';
  static const String _hardcodedAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl2bmZoc2lweWZ4ZG11bGFqYmdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2NDUwNTgsImV4cCI6MjA2MzIyMTA1OH0.9mw2t1IKIHJkh30CdWcAfB2JhuJYdHQ_e_iHOZWcIqs';

  static const String _projectUrlDefine =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String _anonKeyDefine =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static String _normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.length >= 2) {
      final first = trimmed[0];
      final last = trimmed[trimmed.length - 1];
      final isDoubleQuoted = first == '"' && last == '"';
      final isSingleQuoted = first == "'" && last == "'";
      if (isDoubleQuoted || isSingleQuoted) {
        return trimmed.substring(1, trimmed.length - 1).trim();
      }
    }
    return trimmed;
  }

  static bool _looksLikeSupabaseKey(String value) {
    final v = _normalize(value);
    if (v.isEmpty) return false;
    if (v.startsWith('sb_publishable_')) return true;
    final parts = v.split('.');
    if (parts.length == 3 && parts.every((p) => p.isNotEmpty)) return true;
    return false;
  }

  static String get projectUrl {
    // First try dart-define, then fall back to hardcoded value
    if (_projectUrlDefine.isNotEmpty) return _normalize(_projectUrlDefine);
    return _hardcodedProjectUrl;
  }

  static String get anonKey {
    // First try dart-define, then fall back to hardcoded value
    final defineValue = _normalize(_anonKeyDefine);
    if (_looksLikeSupabaseKey(defineValue)) return defineValue;
    return _hardcodedAnonKey;
  }
}
