import 'package:equatable/equatable.dart';

abstract class GlobalEventType extends Equatable {
  const GlobalEventType();

  @override
  List<Object?> get props => [];
}

class RefreshSurveyAssignment extends GlobalEventType {
  final String? id;

  const RefreshSurveyAssignment(this.id);
}

class RefreshProfile extends GlobalEventType {
  const RefreshProfile();
}

class FireGlobalEvent extends Equatable {
  final GlobalEventType eventType;

  const FireGlobalEvent({required this.eventType});

  @override
  List<Object?> get props => [eventType];
}
