import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_tap/morse_tap.dart';
import 'package:morse_tap/src/utils/platform_utils_io.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    HapticUtils.debugHapticSupportedOverride = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
  });

  tearDown(() {
    HapticUtils.debugHapticSupportedOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('HapticUtils maps and defaults', () {
    test('hapticTypeNames covers every enum value', () {
      for (final type in HapticFeedbackType.values) {
        expect(HapticUtils.hapticTypeNames[type], isNotNull);
      }
    });

    test('hapticTypeDescriptions covers every enum value', () {
      for (final type in HapticFeedbackType.values) {
        expect(HapticUtils.hapticTypeDescriptions[type], isNotNull);
      }
    });

    test('availableHapticTypes lists every enum value', () {
      for (final type in HapticFeedbackType.values) {
        expect(HapticUtils.availableHapticTypes, contains(type));
      }
    });
  });

  group('HapticUtils.triggerHaptic', () {
    test('returns false when type is null', () async {
      expect(await HapticUtils.triggerHaptic(null), isFalse);
    });

    test('returns false when haptics are unsupported', () async {
      HapticUtils.debugHapticSupportedOverride = false;
      expect(
        await HapticUtils.triggerHaptic(HapticFeedbackType.lightImpact),
        isFalse,
      );
    });

    test('dispatches the correct platform call for each type', () async {
      final methods = <String?>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          methods.add(call.arguments as String?);
        }
        return null;
      });
      for (final type in HapticFeedbackType.values) {
        expect(await HapticUtils.triggerHaptic(type), isTrue);
      }
      expect(methods, hasLength(HapticFeedbackType.values.length));
    });

    test('returns false when a platform call throws', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        throw PlatformException(code: 'fail');
      });
      expect(
        await HapticUtils.triggerHaptic(HapticFeedbackType.lightImpact),
        isFalse,
      );
    });
  });

  group('HapticUtils.executeFromConfig', () {
    test('returns false when config is null', () async {
      expect(
        await HapticUtils.executeFromConfig(
          null,
          HapticFeedbackType.lightImpact,
        ),
        isFalse,
      );
    });

    test('returns false when config is disabled', () async {
      expect(
        await HapticUtils.executeFromConfig(
          HapticConfig.disabled,
          HapticFeedbackType.lightImpact,
        ),
        isFalse,
      );
    });

    test('delegates to triggerHaptic when enabled', () async {
      expect(
        await HapticUtils.executeFromConfig(
          HapticConfig.defaultConfig,
          HapticFeedbackType.lightImpact,
        ),
        isTrue,
      );
    });
  });

  group('HapticUtils naming helpers', () {
    test('getHapticTypeName returns friendly names', () {
      for (final type in HapticFeedbackType.values) {
        expect(HapticUtils.getHapticTypeName(type), isNotEmpty);
      }
    });

    test('getHapticTypeDescription returns descriptions', () {
      for (final type in HapticFeedbackType.values) {
        expect(HapticUtils.getHapticTypeDescription(type), isNotEmpty);
      }
    });

    test('createDropdownItem builds DropdownMenuItem with the name', () {
      final item =
          HapticUtils.createDropdownItem(HapticFeedbackType.lightImpact);
      expect(item, isA<DropdownMenuItem<HapticFeedbackType>>());
      expect(item.value, HapticFeedbackType.lightImpact);
    });
  });

  group('HapticUtils preset helpers', () {
    test('presetConfigs contains the expected labels', () {
      expect(HapticUtils.presetConfigs.keys,
          containsAll(['Disabled', 'Light', 'Default', 'Strong']));
    });

    test('getPresetName returns the matching preset name', () {
      expect(HapticUtils.getPresetName(HapticConfig.disabled), 'Disabled');
      expect(HapticUtils.getPresetName(HapticConfig.light), 'Light');
      expect(HapticUtils.getPresetName(HapticConfig.defaultConfig),
          'Default');
      expect(HapticUtils.getPresetName(HapticConfig.strong), 'Strong');
    });

    test('getPresetName returns null for custom configs', () {
      const custom = HapticConfig(
        enabled: true,
        dotIntensity: HapticFeedbackType.vibrate,
      );
      expect(HapticUtils.getPresetName(custom), isNull);
    });
  });

  group('HapticUtils.testHaptic', () {
    test('executes when supported', () async {
      final methods = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        methods.add(call.method);
        return null;
      });
      await HapticUtils.testHaptic(HapticFeedbackType.lightImpact);
      expect(methods, contains('HapticFeedback.vibrate'));
    });

    test('does nothing when unsupported', () async {
      HapticUtils.debugHapticSupportedOverride = false;
      final methods = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        methods.add(call.method);
        return null;
      });
      await HapticUtils.testHaptic(HapticFeedbackType.lightImpact);
      expect(methods, isEmpty);
    });
  });

  group('HapticUtils.validateConfig', () {
    test('returns null when supported', () {
      expect(HapticUtils.validateConfig(HapticConfig.defaultConfig), isNull);
    });

    test('returns null when config is disabled even if unsupported', () {
      HapticUtils.debugHapticSupportedOverride = false;
      expect(HapticUtils.validateConfig(HapticConfig.disabled), isNull);
    });

    test('returns message when config is enabled but unsupported', () {
      HapticUtils.debugHapticSupportedOverride = false;
      expect(
        HapticUtils.validateConfig(HapticConfig.defaultConfig),
        isNotNull,
      );
    });
  });

  group('PlatformUtils (io)', () {
    test('returns a bool', () {
      // The value depends on the host platform; just exercise the getter.
      expect(PlatformUtils.isHapticSupported, isA<bool>());
    });
  });

  group('HapticUtils.isHapticSupported without override', () {
    test('delegates to PlatformUtils when no override is set', () {
      HapticUtils.debugHapticSupportedOverride = null;
      // Just exercise the getter path; result is platform-dependent.
      expect(HapticUtils.isHapticSupported, isA<bool>());
    });
  });
}
