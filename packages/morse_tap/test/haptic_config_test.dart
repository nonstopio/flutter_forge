import 'package:flutter_test/flutter_test.dart';
import 'package:morse_tap/morse_tap.dart';

void main() {
  group('HapticConfig', () {
    test('default constructor sets expected defaults', () {
      const config = HapticConfig();
      expect(config.enabled, isFalse);
      expect(config.dotIntensity, HapticFeedbackType.lightImpact);
      expect(config.dashIntensity, HapticFeedbackType.mediumImpact);
      expect(config.spaceIntensity, HapticFeedbackType.heavyImpact);
      expect(config.correctSequenceIntensity, HapticFeedbackType.mediumImpact);
      expect(config.incorrectSequenceIntensity, HapticFeedbackType.heavyImpact);
      expect(config.timeoutIntensity, HapticFeedbackType.lightImpact);
    });

    test('copyWith preserves unchanged fields', () {
      const base = HapticConfig();
      final copy = base.copyWith(enabled: true);
      expect(copy.enabled, isTrue);
      expect(copy.dotIntensity, base.dotIntensity);
      expect(copy.dashIntensity, base.dashIntensity);
      expect(copy.spaceIntensity, base.spaceIntensity);
      expect(copy.correctSequenceIntensity, base.correctSequenceIntensity);
      expect(copy.incorrectSequenceIntensity, base.incorrectSequenceIntensity);
      expect(copy.timeoutIntensity, base.timeoutIntensity);
    });

    test('copyWith overrides all provided fields', () {
      const base = HapticConfig();
      final copy = base.copyWith(
        enabled: true,
        dotIntensity: HapticFeedbackType.heavyImpact,
        dashIntensity: HapticFeedbackType.selectionClick,
        spaceIntensity: HapticFeedbackType.vibrate,
        correctSequenceIntensity: HapticFeedbackType.lightImpact,
        incorrectSequenceIntensity: HapticFeedbackType.selectionClick,
        timeoutIntensity: HapticFeedbackType.vibrate,
      );
      expect(copy.enabled, isTrue);
      expect(copy.dotIntensity, HapticFeedbackType.heavyImpact);
      expect(copy.dashIntensity, HapticFeedbackType.selectionClick);
      expect(copy.spaceIntensity, HapticFeedbackType.vibrate);
      expect(copy.correctSequenceIntensity, HapticFeedbackType.lightImpact);
      expect(copy.incorrectSequenceIntensity, HapticFeedbackType.selectionClick);
      expect(copy.timeoutIntensity, HapticFeedbackType.vibrate);
    });

    test('presets have expected enabled state', () {
      expect(HapticConfig.disabled.enabled, isFalse);
      expect(HapticConfig.defaultConfig.enabled, isTrue);
      expect(HapticConfig.light.enabled, isTrue);
      expect(HapticConfig.strong.enabled, isTrue);
    });

    test('equality is identity-aware', () {
      const a = HapticConfig();
      expect(a == a, isTrue);
      expect(a == const HapticConfig(), isTrue);
      expect(a == const HapticConfig(enabled: true), isFalse);
      expect(a == 'not a config', isFalse);
    });

    test('equality differs when any intensity differs', () {
      const a = HapticConfig();
      expect(
        a == a.copyWith(dotIntensity: HapticFeedbackType.heavyImpact),
        isFalse,
      );
      expect(
        a == a.copyWith(dashIntensity: HapticFeedbackType.vibrate),
        isFalse,
      );
      expect(
        a == a.copyWith(spaceIntensity: HapticFeedbackType.selectionClick),
        isFalse,
      );
      expect(
        a ==
            a.copyWith(
              correctSequenceIntensity: HapticFeedbackType.vibrate,
            ),
        isFalse,
      );
      expect(
        a ==
            a.copyWith(
              incorrectSequenceIntensity: HapticFeedbackType.selectionClick,
            ),
        isFalse,
      );
      expect(
        a == a.copyWith(timeoutIntensity: HapticFeedbackType.heavyImpact),
        isFalse,
      );
    });

    test('hashCode matches for equal configs and differs for changes', () {
      const a = HapticConfig();
      const b = HapticConfig();
      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, isNot(a.copyWith(enabled: true).hashCode));
    });

    test('toString includes all fields', () {
      const config = HapticConfig();
      final s = config.toString();
      expect(s, contains('enabled: false'));
      expect(s, contains('dotIntensity'));
      expect(s, contains('timeoutIntensity'));
    });
  });
}
