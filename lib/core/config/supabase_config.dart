import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // .env is bundled as a Flutter asset and loaded at runtime via dotenv, so
  // it works no matter how the app was launched (Xcode Run, Xcode Archive,
  // `flutter run`, TestFlight, ...) - unlike --dart-define, which only gets
  // baked in correctly if the specific build command that ran happened to
  // pass it. dart-define is kept as a secondary source for build pipelines
  // that intentionally don't bundle a .env file.
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
    final dotenvValue = _normalize(dotenv.env['SUPABASE_URL'] ?? '');
    if (dotenvValue.isNotEmpty) return dotenvValue;
    return _normalize(_projectUrlDefine);
  }

  static String get anonKey {
    final dotenvValue = _normalize(dotenv.env['SUPABASE_ANON_KEY'] ?? '');
    if (_looksLikeSupabaseKey(dotenvValue)) return dotenvValue;

    final defineValue = _normalize(_anonKeyDefine);
    return _looksLikeSupabaseKey(defineValue) ? defineValue : '';
  }
}
