import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/error.dart';
import '../core/error_codes.dart';
import '../core/schema.dart';
import '../core/validation_result.dart';

/// A TextFormField with real-time Zod validation
class ZodTextFormField extends StatefulWidget {
  final Schema<String> schema;
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function(String)? onFieldSubmitted;
  final bool autofocus;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextStyle? style;
  final InputDecoration? decoration;
  final bool validateOnChange;
  final bool showValidationIcon;
  final Duration debounceTime;
  final Color? validIconColor;
  final Color? invalidIconColor;
  final Widget? validIcon;
  final Widget? invalidIcon;
  final bool clearErrorOnChange;
  final bool showErrorImmediately;
  final String? customErrorMessage;
  final bool useAsyncValidation;

  const ZodTextFormField({
    super.key,
    required this.schema,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.style,
    this.decoration,
    this.validateOnChange = true,
    this.showValidationIcon = true,
    this.debounceTime = const Duration(milliseconds: 300),
    this.validIconColor,
    this.invalidIconColor,
    this.validIcon,
    this.invalidIcon,
    this.clearErrorOnChange = true,
    this.showErrorImmediately = false,
    this.customErrorMessage,
    this.useAsyncValidation = false,
  });

  @override
  State<ZodTextFormField> createState() => _ZodTextFormFieldState();
}

class _ZodTextFormFieldState extends State<ZodTextFormField> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  ValidationResult<String>? _lastValidation;
  bool _isValidating = false;
  bool _hasUserInteracted = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    if (widget.validateOnChange) {
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasUserInteracted) {
      _hasUserInteracted = true;
    }

    if (widget.clearErrorOnChange &&
        _lastValidation != null &&
        _lastValidation?.isSuccess != true) {
      setState(() {
        _lastValidation = null;
      });
    }

    if (widget.validateOnChange) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceTime, () {
        _validateField(_controller.text);
      });
    }

    widget.onChanged?.call(_controller.text);
  }

  Future<void> _validateField(String value) async {
    if (!mounted) return;

    setState(() {
      _isValidating = true;
    });

    try {
      ValidationResult<String> result;

      if (widget.useAsyncValidation) {
        result = await widget.schema.validateAsync(value);
      } else {
        result = widget.schema.validate(value);
      }

      if (mounted) {
        setState(() {
          _lastValidation = result;
          _isValidating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastValidation = ValidationResult.failure(ValidationErrorCollection([
            ValidationError(
              code: ValidationErrorCode.custom.code,
              message: 'Validation error: $e',
              path: [],
              expected: 'valid value',
              received: e.toString(),
            ),
          ]));
          _isValidating = false;
        });
      }
    }
  }

  String? _getErrorText() {
    if (!_hasUserInteracted && !widget.showErrorImmediately) {
      return null;
    }

    if (_lastValidation == null) {
      return null;
    }

    if (_lastValidation?.isSuccess == true) {
      return null;
    }

    if (widget.customErrorMessage != null) {
      return widget.customErrorMessage;
    }

    final errors = _lastValidation?.errors?.errors;
    if (errors == null || errors.isEmpty) {
      return null;
    }

    return errors.first.message;
  }

  Widget? _getValidationIcon() {
    if (!widget.showValidationIcon) {
      return null;
    }

    if (_isValidating) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (!_hasUserInteracted && !widget.showErrorImmediately) {
      return null;
    }

    if (_lastValidation == null) {
      return null;
    }

    if (_lastValidation?.isSuccess == true) {
      return widget.validIcon ??
          Icon(
            Icons.check_circle,
            color: widget.validIconColor ?? Colors.green,
            size: 20,
          );
    } else {
      return widget.invalidIcon ??
          Icon(
            Icons.error,
            color: widget.invalidIconColor ?? Colors.red,
            size: 20,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorText = _getErrorText();
    final validationIcon = _getValidationIcon();

    InputDecoration decoration = widget.decoration ??
        InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: validationIcon,
          border: const OutlineInputBorder(),
        );

    // Add validation icon to existing decoration if needed
    if (widget.decoration != null && validationIcon != null) {
      decoration = decoration.copyWith(
        suffixIcon: validationIcon,
      );
    }

    return TextFormField(
      controller: _controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onSaved: widget.onSaved,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      style: widget.style,
      decoration: decoration.copyWith(
        errorText: errorText,
      ),
      validator: (value) {
        // Use the schema's validator for form validation
        final result = widget.schema.validate(value ?? '');
        if (result.isSuccess) {
          return null;
        }

        if (widget.customErrorMessage != null) {
          return widget.customErrorMessage;
        }

        final errors = result.errors?.errors;
        if (errors?.isEmpty != false) {
          return 'Validation failed';
        }

        return errors!.first.message;
      },
    );
  }
}

/// A widget that displays validation errors in a customizable format
class ZodErrorDisplay extends StatelessWidget {
  final ValidationResult result;
  final TextStyle? errorStyle;
  final Color? errorColor;
  final Widget? errorIcon;
  final EdgeInsets? padding;
  final bool showIcon;
  final bool showMultipleErrors;
  final String? customPrefix;
  final Widget Function(ValidationError error)? errorBuilder;

  const ZodErrorDisplay({
    super.key,
    required this.result,
    this.errorStyle,
    this.errorColor,
    this.errorIcon,
    this.padding,
    this.showIcon = true,
    this.showMultipleErrors = true,
    this.customPrefix,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (result.isSuccess) {
      return const SizedBox.shrink();
    }

    final errors = result.errors?.errors;
    if (errors?.isEmpty != false) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final defaultErrorColor = errorColor ?? theme.colorScheme.error;
    final defaultErrorStyle = errorStyle ??
        theme.textTheme.bodySmall?.copyWith(color: defaultErrorColor);

    if (errorBuilder != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: errors!.map((error) => errorBuilder!(error)).toList(),
      );
    }

    final errorsToShow = showMultipleErrors ? errors! : [errors!.first];

    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: errorsToShow.map((error) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showIcon) ...[
                errorIcon ??
                    Icon(
                      Icons.error_outline,
                      color: defaultErrorColor,
                      size: 16,
                    ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  '${customPrefix ?? ''}${error.message}',
                  style: defaultErrorStyle,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// A widget that provides real-time validation feedback
class ZodValidationFeedback extends StatefulWidget {
  final Schema schema;
  final dynamic value;
  final Widget Function(ValidationResult result) builder;
  final Duration debounceTime;
  final bool useAsyncValidation;

  const ZodValidationFeedback({
    super.key,
    required this.schema,
    required this.value,
    required this.builder,
    this.debounceTime = const Duration(milliseconds: 300),
    this.useAsyncValidation = false,
  });

  @override
  State<ZodValidationFeedback> createState() => _ZodValidationFeedbackState();
}

class _ZodValidationFeedbackState extends State<ZodValidationFeedback> {
  Timer? _debounceTimer;
  ValidationResult? _lastResult;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _validateValue();
  }

  @override
  void didUpdateWidget(ZodValidationFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _validateValue();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _validateValue() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceTime, () {
      _performValidation();
    });
  }

  Future<void> _performValidation() async {
    if (!mounted) return;

    setState(() {
      _isValidating = true;
    });

    try {
      ValidationResult result;

      if (widget.useAsyncValidation) {
        result = await widget.schema.safeParseAsync(widget.value);
      } else {
        result = widget.schema.safeParse(widget.value);
      }

      if (mounted) {
        setState(() {
          _lastResult = result;
          _isValidating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastResult = ValidationResult.failure(ValidationErrorCollection([
            ValidationError(
              code: ValidationErrorCode.custom.code,
              message: 'Validation error: $e',
              path: [],
              expected: 'valid value',
              received: e.toString(),
            ),
          ]));
          _isValidating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidating) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_lastResult == null) {
      return const SizedBox.shrink();
    }

    return widget.builder(_lastResult!);
  }
}

/// A form field that validates using a Zod schema
class ZodFormField<T> extends StatefulWidget {
  final Schema<T> schema;
  final T? initialValue;
  final Widget Function(T? value, void Function(T?) onChanged) builder;
  final void Function(T?)? onSaved;
  final bool autovalidate;
  final bool enabled;
  final String? customErrorMessage;
  final bool useAsyncValidation;
  final Duration debounceTime;

  const ZodFormField({
    super.key,
    required this.schema,
    this.initialValue,
    required this.builder,
    this.onSaved,
    this.autovalidate = false,
    this.enabled = true,
    this.customErrorMessage,
    this.useAsyncValidation = false,
    this.debounceTime = const Duration(milliseconds: 300),
  });

  @override
  State<ZodFormField<T>> createState() => _ZodFormFieldState<T>();
}

class _ZodFormFieldState<T> extends State<ZodFormField<T>> {
  T? _value;
  ValidationResult<T>? _lastValidation;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    if (widget.autovalidate) {
      _validateValue();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onChanged(T? newValue) {
    setState(() {
      _value = newValue;
    });

    if (widget.autovalidate) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceTime, () {
        _validateValue();
      });
    }
  }

  Future<void> _validateValue() async {
    if (!mounted) return;

    try {
      ValidationResult<T> result;

      if (widget.useAsyncValidation) {
        result = await widget.schema.validateAsync(_value);
      } else {
        result = widget.schema.validate(_value);
      }

      if (mounted) {
        setState(() {
          _lastValidation = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastValidation = ValidationResult.failure(ValidationErrorCollection([
            ValidationError(
              code: ValidationErrorCode.custom.code,
              message: 'Validation error: $e',
              path: [],
              expected: 'valid value',
              received: e.toString(),
            ),
          ]));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: widget.initialValue,
      onSaved: widget.onSaved,
      enabled: widget.enabled,
      validator: (value) {
        // Use the schema's validator for form validation
        final result = widget.schema.validate(value);
        if (result.isSuccess) {
          return null;
        }

        if (widget.customErrorMessage != null) {
          return widget.customErrorMessage;
        }

        final errors = result.errors?.errors;
        if (errors?.isEmpty != false) {
          return 'Validation failed';
        }

        return errors!.first.message;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.builder(_value, _onChanged),
            if (field.hasError) ...[
              const SizedBox(height: 8),
              Text(
                field.errorText ?? 'Validation failed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            if (widget.autovalidate &&
                _lastValidation != null &&
                _lastValidation?.isSuccess != true) ...[
              const SizedBox(height: 8),
              if (_lastValidation != null)
                ZodErrorDisplay(result: _lastValidation!),
            ],
          ],
        );
      },
    );
  }
}

/// A validation status indicator widget
class ZodValidationStatus extends StatelessWidget {
  final ValidationResult result;
  final bool showWhenValid;
  final bool showWhenInvalid;
  final Widget? validWidget;
  final Widget? invalidWidget;
  final Widget? loadingWidget;
  final bool isLoading;
  final Color? validColor;
  final Color? invalidColor;
  final String? validMessage;
  final String? invalidMessage;

  const ZodValidationStatus({
    super.key,
    required this.result,
    this.showWhenValid = true,
    this.showWhenInvalid = true,
    this.validWidget,
    this.invalidWidget,
    this.loadingWidget,
    this.isLoading = false,
    this.validColor,
    this.invalidColor,
    this.validMessage,
    this.invalidMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
    }

    if (result.isSuccess) {
      if (!showWhenValid) {
        return const SizedBox.shrink();
      }

      return validWidget ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: validColor ?? Colors.green,
                size: 16,
              ),
              if (validMessage != null) ...[
                const SizedBox(width: 4),
                Text(
                  validMessage!,
                  style: TextStyle(
                    color: validColor ?? Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          );
    } else {
      if (!showWhenInvalid) {
        return const SizedBox.shrink();
      }

      return invalidWidget ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error,
                color: invalidColor ?? Colors.red,
                size: 16,
              ),
              if (invalidMessage != null) ...[
                const SizedBox(width: 4),
                Text(
                  invalidMessage!,
                  style: TextStyle(
                    color: invalidColor ?? Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          );
    }
  }
}
