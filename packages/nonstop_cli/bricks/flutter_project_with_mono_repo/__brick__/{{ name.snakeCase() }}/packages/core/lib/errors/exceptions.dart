import 'package:localization/localization.dart';

class CoreException implements Exception {
  final String message;

  CoreException({required this.message});
}

class UserNotFoundException extends CoreException {
  UserNotFoundException() : super(message: strings.errors.user_not_found);
}
