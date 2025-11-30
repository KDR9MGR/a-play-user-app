class ContentFilterResult {
  final bool isObjectionable;
  final String filteredText;

  const ContentFilterResult({required this.isObjectionable, required this.filteredText});
}

class ContentFilterService {
  // Simplified banned words list. In production, load from remote config.
  static const List<String> _bannedWords = [
    'hate', 'racist', 'sexist', 'violence', 'nsfw', 'obscene', 'abuse',
  ];

  static final List<RegExp> _patterns = [
    RegExp(r'\b(fuck|shit|bitch|asshole)\b', caseSensitive: false),
    RegExp(r'\b(kill|rape|murder)\b', caseSensitive: false),
  ];

  static ContentFilterResult evaluate(String text) {
    if (text.isEmpty) {
      return const ContentFilterResult(isObjectionable: false, filteredText: '');
    }
    final lower = text.toLowerCase();
    bool objectionable = false;
    String masked = text;

    for (final word in _bannedWords) {
      if (lower.contains(word)) {
        objectionable = true;
        masked = masked.replaceAll(RegExp('(?i)$word'), '••••');
      }
    }

    for (final pattern in _patterns) {
      if (pattern.hasMatch(text)) {
        objectionable = true;
        masked = masked.replaceAll(pattern, '••••');
      }
    }

    return ContentFilterResult(isObjectionable: objectionable, filteredText: masked);
  }
}