import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/utils/validators.dart';

void main() {
  test('email validation handles empty, valid, invalid and custom errors', () {
    expect(ValidatorUtil.validateEmail(' '), enterEmail);
    expect(ValidatorUtil.validateEmail('alice@example.com'), isNull);
    expect(ValidatorUtil.validateEmail('bad'), enterValidEmail);
    expect(
        ValidatorUtil.validateEmail('bad', errorMessage: 'custom'), 'custom');
  });
  test('password and name validators apply their documented patterns', () {
    expect(ValidatorUtil.validatePassword(' '), enterPassword);
    expect(ValidatorUtil.validatePassword('Abc123@'), isNull);
    expect(ValidatorUtil.validatePassword('abc'), passwordValidationMsg);
    expect(ValidatorUtil.validateName('', 'name'), '$enter name');
    expect(ValidatorUtil.validateName("O'Brien", 'name'), isNull);
    expect(ValidatorUtil.validateName('123', 'name'), '$enterValid name');
    expect(ValidatorUtil.validateName('123', 'id', pattern: r'^\d+$'), isNull);
  });
  test('generic validators distinguish blank values and mismatching patterns',
      () {
    expect(ValidatorUtil.validatePattern(' ', label: 'id', pattern: r'^\d+$'),
        emptyMessage);
    expect(ValidatorUtil.validatePattern('12', label: 'id', pattern: r'^\d+$'),
        isNull);
    expect(ValidatorUtil.validatePattern('bad', label: 'id', pattern: r'^\d+$'),
        '$enterValid id');
    expect(
        ValidatorUtil.validatePattern('bad',
            label: 'id', pattern: r'^\d+$', errorMessage: 'custom'),
        'custom');
    expect(ValidatorUtil.validateEmptyCheck(' '), emptyMessage);
    expect(ValidatorUtil.validateEmptyCheck('ok'), isNull);
    expect(ValidatorUtil.validateEmpty('', 'name'), '${enter}name');
    expect(ValidatorUtil.validateEmpty('ok', 'name'), isNull);
  });
  testWidgets(
      'form validation saves only valid forms and handles missing or throwing forms',
      (tester) async {
    expect(ValidatorUtil.isFormValid(null), isFalse);
    expect(ValidatorUtil.isFormValid(GlobalKey<FormState>()), isFalse);
    final key = GlobalKey<FormState>();
    var saved = false;
    var mode = 'valid';
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Form(
                key: key,
                child: TextFormField(
                  validator: (_) {
                    if (mode == 'throw') throw Exception('validation failed');
                    return mode == 'invalid' ? 'invalid' : null;
                  },
                  onSaved: (_) => saved = true,
                )))));
    expect(ValidatorUtil.isFormValid(key), isTrue);
    expect(saved, isTrue);
    saved = false;
    mode = 'invalid';
    expect(ValidatorUtil.isFormValid(key), isFalse);
    expect(saved, isFalse);
    mode = 'throw';
    expect(ValidatorUtil.isFormValid(key), isFalse);
  });
}
