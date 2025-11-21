/// Text Direction Helper Tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/utils/text_direction_helper.dart';

void main() {
  group('Text Direction Helper', () {
    group('startsWithArabic', () {
      test('returns true for text starting with Arabic', () {
        expect(startsWithArabic('مرحبا'), true);
        expect(startsWithArabic('السلام عليكم'), true);
        expect(startsWithArabic('مرحبا hello'), true);
        expect(startsWithArabic('   مرحبا'), true); // with leading whitespace
      });

      test('returns false for text not starting with Arabic', () {
        expect(startsWithArabic('Hello'), false);
        expect(startsWithArabic('Hello مرحبا'), false);
        expect(startsWithArabic('123 مرحبا'), false);
        expect(startsWithArabic('!مرحبا'), false);
      });

      test('returns false for empty string', () {
        expect(startsWithArabic(''), false);
        expect(startsWithArabic('   '), false);
      });
    });

    group('containsArabic', () {
      test('returns true when Arabic is present', () {
        expect(containsArabic('مرحبا'), true);
        expect(containsArabic('Hello مرحبا'), true);
        expect(containsArabic('مرحبا Hello'), true);
        expect(containsArabic('Hello مرحبا World'), true);
      });

      test('returns false when no Arabic is present', () {
        expect(containsArabic('Hello World'), false);
        expect(containsArabic('12345'), false);
        expect(containsArabic('!@#\$%'), false);
      });

      test('returns false for empty string', () {
        expect(containsArabic(''), false);
      });
    });
  });
}
