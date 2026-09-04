import 'dart:async';

import 'package:developer/src/routes/index.dart';
import 'package:feature_flags/feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class OpenDevToolsWrapper extends StatefulWidget {
  const OpenDevToolsWrapper({
    super.key,
    required this.child,
    this.tapCount = 5,
    this.tapWindow = const Duration(seconds: 2),
    this.enableHaptics = true,
    this.enableVisualFeedback = false,
  });

  final Widget child;
  final int tapCount;
  final Duration tapWindow;
  final bool enableHaptics;
  final bool enableVisualFeedback;

  @override
  State<OpenDevToolsWrapper> createState() => _OpenDevToolsWrapperState();
}

class _OpenDevToolsWrapperState extends State<OpenDevToolsWrapper>
    with SingleTickerProviderStateMixin {
  int _currentTapCount = 0;
  Timer? _resetTimer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _currentTapCount++;
    });

    // Provide haptic feedback for progress
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }

    // Visual feedback animation
    if (widget.enableVisualFeedback && !_isAnimating) {
      _isAnimating = true;
      _animationController.forward().then((_) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _isAnimating = false;
            });
          }
        });
      });
    }

    // Check if we've reached the required tap count
    if (_currentTapCount >= widget.tapCount) {
      _navigateToDeveloperScreen();
      return;
    }

    // Reset the timer
    _resetTimer?.cancel();
    _resetTimer = Timer(widget.tapWindow, _resetTapCount);
  }

  void _navigateToDeveloperScreen() {
    // Provide success haptic feedback
    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }

    // Reset state
    _resetTapCount();

    // Navigate to developer screen
    if (mounted) {
      context.push(DeveloperRoutes.developer);
    }
  }

  void _resetTapCount() {
    _resetTimer?.cancel();
    if (mounted) {
      setState(() {
        _currentTapCount = 0;
      });
    }
  }

  Widget _buildChild() {
    if (widget.enableVisualFeedback) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      );
    }
    return widget.child;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FeatureFlagWrapper(
      flagKey: 'developer_screen_enabled',
      builder: (context, isEnabled) {
        if (!isEnabled) {
          return widget.child; // Just return the child if feature is disabled
        }

        return GestureDetector(
          onTap: _handleTap,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              _buildChild(),
              // Optional debug indicator (only visible in debug and with visual feedback enabled)
              if (widget.enableVisualFeedback && _currentTapCount > 0) ...[
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$_currentTapCount/${widget.tapCount}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
