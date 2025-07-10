import 'package:flutter/foundation.dart';

import '../core/error.dart';
import '../core/schema.dart';
import '../core/validation_result.dart';

/// A ValueNotifier that validates its value using a Zod schema
class ZodValueNotifier<T> extends ValueNotifier<T> {
  final Schema<T> schema;
  ValidationResult<T>? _lastValidation;
  final bool validateOnChange;

  ZodValueNotifier({
    required T initialValue,
    required this.schema,
    this.validateOnChange = true,
  }) : super(initialValue) {
    if (validateOnChange) {
      _validateValue(initialValue);
    }
  }

  /// Get the last validation result
  ValidationResult<T>? get lastValidation => _lastValidation;

  /// Check if the current value is valid
  bool get isValid => _lastValidation?.isSuccess ?? false;

  /// Get validation errors
  List<ValidationError> get errors => _lastValidation?.errors?.errors ?? [];

  /// Get the first error message
  String? get errorMessage => errors.isNotEmpty ? errors.first.message : null;

  @override
  set value(T newValue) {
    super.value = newValue;
    if (validateOnChange) {
      _validateValue(newValue);
    }
  }

  /// Manually validate the current value
  void validate() {
    _validateValue(value);
  }

  /// Validate the current value asynchronously
  Future<void> validateAsync() async {
    await _validateValueAsync(value);
  }

  /// Set value with validation
  void setWithValidation(T newValue) {
    _validateValue(newValue);
    super.value = newValue;
  }

  /// Set value with async validation
  Future<void> setWithAsyncValidation(T newValue) async {
    await _validateValueAsync(newValue);
    super.value = newValue;
  }

  /// Try to set value, returns true if valid
  bool trySetValue(T newValue) {
    _validateValue(newValue);
    if (isValid) {
      super.value = newValue;
      return true;
    }
    return false;
  }

  /// Try to set value asynchronously, returns true if valid
  Future<bool> trySetValueAsync(T newValue) async {
    await _validateValueAsync(newValue);
    if (isValid) {
      super.value = newValue;
      return true;
    }
    return false;
  }

  void _validateValue(T val) {
    _lastValidation = schema.validate(val);
    notifyListeners();
  }

  Future<void> _validateValueAsync(T val) async {
    _lastValidation = await schema.validateAsync(val);
    notifyListeners();
  }
}

/// A ChangeNotifier that manages form validation state
class ZodFormNotifier extends ChangeNotifier {
  final Map<String, Schema> _schemas = {};
  final Map<String, dynamic> _values = {};
  final Map<String, ValidationResult> _validations = {};
  bool _isValidating = false;

  /// Check if the form is currently validating
  bool get isValidating => _isValidating;

  /// Check if the entire form is valid
  bool get isValid => _validations.values.every((result) => result.isSuccess);

  /// Get all validation errors
  Map<String, List<ValidationError>> get errors => _validations.map(
        (key, result) => MapEntry(key, result.errors?.errors ?? []),
      );

  /// Get all form values
  Map<String, dynamic> get values => Map.from(_values);

  /// Add a field to the form
  void addField<T>(String fieldName, Schema<T> schema, {T? initialValue}) {
    _schemas[fieldName] = schema;
    if (initialValue != null) {
      _values[fieldName] = initialValue;
      _validateField(fieldName, initialValue);
    }
  }

  /// Remove a field from the form
  void removeField(String fieldName) {
    _schemas.remove(fieldName);
    _values.remove(fieldName);
    _validations.remove(fieldName);
    notifyListeners();
  }

  /// Set a field value
  void setFieldValue<T>(String fieldName, T value) {
    _values[fieldName] = value;
    _validateField(fieldName, value);
  }

  /// Get a field value
  T? getFieldValue<T>(String fieldName) {
    return _values[fieldName] as T?;
  }

  /// Get validation result for a field
  ValidationResult? getFieldValidation(String fieldName) {
    return _validations[fieldName];
  }

  /// Check if a field is valid
  bool isFieldValid(String fieldName) {
    return _validations[fieldName]?.isSuccess ?? false;
  }

  /// Get errors for a field
  List<ValidationError> getFieldErrors(String fieldName) {
    return _validations[fieldName]?.errors?.errors ?? [];
  }

  /// Get the first error message for a field
  String? getFieldErrorMessage(String fieldName) {
    final errors = getFieldErrors(fieldName);
    return errors.isNotEmpty ? errors.first.message : null;
  }

  /// Validate a specific field
  void validateField(String fieldName) {
    final value = _values[fieldName];
    _validateField(fieldName, value);
  }

  /// Validate a specific field asynchronously
  Future<void> validateFieldAsync(String fieldName) async {
    final value = _values[fieldName];
    await _validateFieldAsync(fieldName, value);
  }

  /// Validate all fields
  void validateAll() {
    for (final fieldName in _schemas.keys) {
      validateField(fieldName);
    }
  }

  /// Validate all fields asynchronously
  Future<void> validateAllAsync() async {
    _isValidating = true;
    notifyListeners();

    try {
      for (final fieldName in _schemas.keys) {
        await validateFieldAsync(fieldName);
      }
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  /// Clear all validation results
  void clearValidations() {
    _validations.clear();
    notifyListeners();
  }

  /// Clear validation for a specific field
  void clearFieldValidation(String fieldName) {
    _validations.remove(fieldName);
    notifyListeners();
  }

  /// Reset the form
  void reset() {
    _values.clear();
    _validations.clear();
    notifyListeners();
  }

  /// Set multiple values at once
  void setValues(Map<String, dynamic> values) {
    _values.addAll(values);
    for (final entry in values.entries) {
      _validateField(entry.key, entry.value);
    }
  }

  void _validateField(String fieldName, dynamic value) {
    final schema = _schemas[fieldName];
    if (schema != null) {
      _validations[fieldName] = schema.safeParse(value);
      notifyListeners();
    }
  }

  Future<void> _validateFieldAsync(String fieldName, dynamic value) async {
    final schema = _schemas[fieldName];
    if (schema != null) {
      _validations[fieldName] = await schema.safeParseAsync(value);
      notifyListeners();
    }
  }
}

/// A generic state management class for Zod validation
class ZodValidationState<T> {
  final T _value;
  final ValidationResult<T> _validation;
  final bool _isLoading;

  const ZodValidationState._({
    required T value,
    required ValidationResult<T> validation,
    required bool isLoading,
  })  : _value = value,
        _validation = validation,
        _isLoading = isLoading;

  /// Create an initial state
  factory ZodValidationState.initial(T value) {
    return ZodValidationState._(
      value: value,
      validation: ValidationResult.success(value),
      isLoading: false,
    );
  }

  /// Create a loading state
  factory ZodValidationState.loading(T value) {
    return ZodValidationState._(
      value: value,
      validation: ValidationResult.success(value),
      isLoading: true,
    );
  }

  /// Create a success state
  factory ZodValidationState.success(T value) {
    return ZodValidationState._(
      value: value,
      validation: ValidationResult.success(value),
      isLoading: false,
    );
  }

  /// Create a failure state
  factory ZodValidationState.failure(T value, List<ValidationError> errors) {
    return ZodValidationState._(
      value: value,
      validation: ValidationResult.failure(ValidationErrorCollection(errors)),
      isLoading: false,
    );
  }

  /// Get the current value
  T get value => _value;

  /// Get the validation result
  ValidationResult<T> get validation => _validation;

  /// Check if the state is loading
  bool get isLoading => _isLoading;

  /// Check if the value is valid
  bool get isValid => _validation.isSuccess;

  /// Get validation errors
  List<ValidationError> get errors => _validation.errors?.errors ?? [];

  /// Get the first error message
  String? get errorMessage => errors.isNotEmpty ? errors.first.message : null;

  /// Copy the state with new values
  ZodValidationState<T> copyWith({
    T? value,
    ValidationResult<T>? validation,
    bool? isLoading,
  }) {
    return ZodValidationState._(
      value: value ?? _value,
      validation: validation ?? _validation,
      isLoading: isLoading ?? _isLoading,
    );
  }

  /// Update the value and validation
  ZodValidationState<T> updateValue(
      T newValue, ValidationResult<T> newValidation) {
    return ZodValidationState._(
      value: newValue,
      validation: newValidation,
      isLoading: false,
    );
  }

  /// Set loading state
  ZodValidationState<T> setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ZodValidationState<T> &&
        other._value == _value &&
        other._validation == _validation &&
        other._isLoading == _isLoading;
  }

  @override
  int get hashCode =>
      _value.hashCode ^ _validation.hashCode ^ _isLoading.hashCode;

  @override
  String toString() {
    return 'ZodValidationState(value: $_value, validation: $_validation, isLoading: $_isLoading)';
  }
}

/// Extension methods for common state management patterns
extension ZodStateExtensions<T> on ZodValidationState<T> {
  /// Transform the state when valid
  ZodValidationState<R> mapValid<R>(R Function(T value) mapper) {
    if (isValid) {
      final newValue = mapper(value);
      return ZodValidationState.success(newValue);
    }

    return ZodValidationState.failure(
      mapper(value),
      errors,
    );
  }

  /// Transform the state when invalid
  ZodValidationState<T> mapInvalid(
      T Function(List<ValidationError> errors) mapper) {
    if (!isValid) {
      final newValue = mapper(errors);
      return ZodValidationState.failure(newValue, errors);
    }

    return this;
  }

  /// Execute a function when valid
  ZodValidationState<T> whenValid(void Function(T value) callback) {
    if (isValid) {
      callback(value);
    }
    return this;
  }

  /// Execute a function when invalid
  ZodValidationState<T> whenInvalid(
      void Function(List<ValidationError> errors) callback) {
    if (!isValid) {
      callback(errors);
    }
    return this;
  }

  /// Execute a function when loading
  ZodValidationState<T> whenLoading(void Function() callback) {
    if (isLoading) {
      callback();
    }
    return this;
  }

  /// Fold the state into a single value
  R fold<R>({
    required R Function(T value) onValid,
    required R Function(List<ValidationError> errors) onInvalid,
    required R Function() onLoading,
  }) {
    if (isLoading) {
      return onLoading();
    }

    if (isValid) {
      return onValid(value);
    }

    return onInvalid(errors);
  }
}

/// A validation controller for managing complex validation scenarios
class ZodValidationController<T> extends ChangeNotifier {
  final Schema<T> schema;
  ZodValidationState<T> _state;

  ZodValidationController({
    required this.schema,
    required T initialValue,
  }) : _state = ZodValidationState.initial(initialValue);

  /// Get the current state
  ZodValidationState<T> get state => _state;

  /// Get the current value
  T get value => _state.value;

  /// Check if the value is valid
  bool get isValid => _state.isValid;

  /// Check if the controller is loading
  bool get isLoading => _state.isLoading;

  /// Get validation errors
  List<ValidationError> get errors => _state.errors;

  /// Get the first error message
  String? get errorMessage => _state.errorMessage;

  /// Update the value and validate
  void updateValue(T newValue) {
    _state = _state.setLoading(true);
    notifyListeners();

    final validation = schema.validate(newValue);
    _state = _state.updateValue(newValue, validation);
    notifyListeners();
  }

  /// Update the value and validate asynchronously
  Future<void> updateValueAsync(T newValue) async {
    _state = _state.setLoading(true);
    notifyListeners();

    final validation = await schema.validateAsync(newValue);
    _state = _state.updateValue(newValue, validation);
    notifyListeners();
  }

  /// Validate the current value
  void validate() {
    _state = _state.setLoading(true);
    notifyListeners();

    final validation = schema.validate(_state.value);
    _state = _state.copyWith(validation: validation, isLoading: false);
    notifyListeners();
  }

  /// Validate the current value asynchronously
  Future<void> validateAsync() async {
    _state = _state.setLoading(true);
    notifyListeners();

    final validation = await schema.validateAsync(_state.value);
    _state = _state.copyWith(validation: validation, isLoading: false);
    notifyListeners();
  }

  /// Reset to initial state
  void reset(T initialValue) {
    _state = ZodValidationState.initial(initialValue);
    notifyListeners();
  }

  /// Clear validation errors
  void clearErrors() {
    _state = _state.copyWith(
      validation: ValidationResult.success(_state.value),
    );
    notifyListeners();
  }
}
