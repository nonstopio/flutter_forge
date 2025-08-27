import 'package:flutter/material.dart';
import 'package:morse_tap/morse_tap.dart';

/// A modal dialog for configuring haptic feedback settings.
///
/// Provides an intuitive interface for users to customize haptic feedback
/// intensity for different Morse code gestures and events.
class HapticConfigModal extends StatefulWidget {
  /// Creates a haptic configuration modal.
  const HapticConfigModal({
    super.key,
    required this.initialConfig,
    this.onConfigChanged,
  });

  /// The initial haptic configuration to display
  final HapticConfig initialConfig;

  /// Callback when configuration changes are applied
  final ValueChanged<HapticConfig>? onConfigChanged;

  @override
  State<HapticConfigModal> createState() => _HapticConfigModalState();

  /// Shows the haptic configuration modal.
  ///
  /// Returns the new configuration if saved, or null if canceled.
  static Future<HapticConfig?> show(
    BuildContext context, {
    required HapticConfig initialConfig,
  }) {
    return showDialog<HapticConfig>(
      context: context,
      builder: (context) => HapticConfigModal(initialConfig: initialConfig),
    );
  }
}

class _HapticConfigModalState extends State<HapticConfigModal> {
  late HapticConfig _currentConfig;
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.initialConfig;
    _selectedPreset = HapticUtils.getPresetName(_currentConfig);
  }

  void _updateConfig(HapticConfig newConfig) {
    setState(() {
      _currentConfig = newConfig;
      _selectedPreset = HapticUtils.getPresetName(newConfig);
    });
  }

  void _applyPreset(String presetName) {
    final preset = HapticUtils.presetConfigs[presetName];
    if (preset != null) {
      _updateConfig(preset);
    }
  }

  void _resetToDefaults() {
    _updateConfig(HapticConfig.defaultConfig);
  }

  void _saveAndClose() {
    widget.onConfigChanged?.call(_currentConfig);
    Navigator.of(context).pop(_currentConfig);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  Widget _buildEnabledSwitch() {
    return SwitchListTile(
      title: const Text('Enable Haptic Feedback'),
      subtitle: Text(
        HapticUtils.isHapticSupported
            ? 'Provide tactile feedback for gestures'
            : 'Not supported on this platform',
      ),
      value: _currentConfig.enabled,
      onChanged: HapticUtils.isHapticSupported
          ? (enabled) =>
                _updateConfig(_currentConfig.copyWith(enabled: enabled))
          : null,
    );
  }

  Widget _buildPresetSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Presets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: HapticUtils.presetConfigs.entries.map((entry) {
                final isSelected = _selectedPreset == entry.key;
                return FilterChip(
                  label: Text(entry.key),
                  selected: isSelected,
                  onSelected: (_) => _applyPreset(entry.key),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHapticSetting({
    required String title,
    required String description,
    required HapticFeedbackType currentType,
    required ValueChanged<HapticFeedbackType?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.touch_app, size: 20),
                  tooltip: 'Test haptic',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed:
                      _currentConfig.enabled && HapticUtils.isHapticSupported
                      ? () => HapticUtils.testHaptic(currentType)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<HapticFeedbackType>(
              initialValue: currentType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: HapticUtils.availableHapticTypes
                  .map(HapticUtils.createDropdownItem)
                  .toList(),
              onChanged: _currentConfig.enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Haptic Feedback Settings'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6, // Constrain height
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEnabledSwitch(),
              const SizedBox(height: 12),

              if (_currentConfig.enabled) ...[
                _buildPresetSelector(),
                const SizedBox(height: 12),

                _buildHapticSetting(
                  title: 'Dots (Single Tap)',
                  description: 'Haptic feedback for dot inputs',
                  currentType: _currentConfig.dotIntensity,
                  onChanged: (type) => _updateConfig(
                    _currentConfig.copyWith(dotIntensity: type),
                  ),
                ),

                _buildHapticSetting(
                  title: 'Dashes (Double Tap)',
                  description: 'Haptic feedback for dash inputs',
                  currentType: _currentConfig.dashIntensity,
                  onChanged: (type) => _updateConfig(
                    _currentConfig.copyWith(dashIntensity: type),
                  ),
                ),

                _buildHapticSetting(
                  title: 'Spaces (Long Press)',
                  description: 'Haptic feedback for space inputs',
                  currentType: _currentConfig.spaceIntensity,
                  onChanged: (type) => _updateConfig(
                    _currentConfig.copyWith(spaceIntensity: type),
                  ),
                ),

                _buildHapticSetting(
                  title: 'Correct Sequence',
                  description: 'Haptic feedback for successful completion',
                  currentType: _currentConfig.correctSequenceIntensity,
                  onChanged: (type) => _updateConfig(
                    _currentConfig.copyWith(correctSequenceIntensity: type),
                  ),
                ),

                _buildHapticSetting(
                  title: 'Incorrect Sequence',
                  description: 'Haptic feedback for errors',
                  currentType: _currentConfig.incorrectSequenceIntensity,
                  onChanged: (type) => _updateConfig(
                    _currentConfig.copyWith(incorrectSequenceIntensity: type),
                  ),
                ),

                _buildHapticSetting(
                  title: 'Input Timeout',
                  description: 'Haptic feedback for timeout events',
                  currentType: _currentConfig.timeoutIntensity,
                  onChanged: (type) => _updateConfig(
                    _currentConfig.copyWith(timeoutIntensity: type),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _resetToDefaults, child: const Text('Reset')),
        TextButton(onPressed: _cancel, child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveAndClose, child: const Text('Save')),
      ],
    );
  }
}
