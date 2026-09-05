import 'package:equatable/equatable.dart';

/// Base type for events broadcast on the app-wide event channel.
///
/// Use this for the handful of things that genuinely cross feature
/// boundaries - "the signed-in user changed", "this list is stale" - and keep
/// everything else inside the feature that owns it.
abstract class GlobalEventType extends Equatable {
  const GlobalEventType();

  @override
  List<Object?> get props => [];
}

/// Example event: something invalidated the current user's profile.
///
/// Replace this with your own events; it is here to show the shape.
class RefreshProfile extends GlobalEventType {
  const RefreshProfile();
}

class FireGlobalEvent extends Equatable {
  final GlobalEventType eventType;

  const FireGlobalEvent({required this.eventType});

  @override
  List<Object?> get props => [eventType];
}
