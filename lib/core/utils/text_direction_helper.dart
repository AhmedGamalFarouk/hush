/// Text Direction Helper
///
/// Provides utilities for determining text direction based on content.
/// Supports RTL for messages starting with Arabic characters.
library;

/// Determines if a string starts with an Arabic character
bool startsWithArabic(String text) {
  if (text.isEmpty) return false;

  final firstChar = text.trimLeft();
  if (firstChar.isEmpty) return false;

  final firstCodeUnit = firstChar.codeUnitAt(0);

  // Arabic Unicode ranges:
  // 0x0600 - 0x06FF: Arabic
  // 0x0750 - 0x077F: Arabic Supplement
  // 0x08A0 - 0x08FF: Arabic Extended-A
  // 0xFB50 - 0xFDFF: Arabic Presentation Forms-A
  // 0xFE70 - 0xFEFF: Arabic Presentation Forms-B
  return (firstCodeUnit >= 0x0600 && firstCodeUnit <= 0x06FF) ||
      (firstCodeUnit >= 0x0750 && firstCodeUnit <= 0x077F) ||
      (firstCodeUnit >= 0x08A0 && firstCodeUnit <= 0x08FF) ||
      (firstCodeUnit >= 0xFB50 && firstCodeUnit <= 0xFDFF) ||
      (firstCodeUnit >= 0xFE70 && firstCodeUnit <= 0xFEFF);
}

/// Determines if a string contains significant Arabic content
bool containsArabic(String text) {
  if (text.isEmpty) return false;

  return text.codeUnits.any(
    (codeUnit) =>
        (codeUnit >= 0x0600 && codeUnit <= 0x06FF) ||
        (codeUnit >= 0x0750 && codeUnit <= 0x077F) ||
        (codeUnit >= 0x08A0 && codeUnit <= 0x08FF) ||
        (codeUnit >= 0xFB50 && codeUnit <= 0xFDFF) ||
        (codeUnit >= 0xFE70 && codeUnit <= 0xFEFF),
  );
}
