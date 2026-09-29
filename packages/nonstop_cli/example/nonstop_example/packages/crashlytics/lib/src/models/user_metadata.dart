/// Crash-report user context. [userId] must be an opaque identifier (for
/// example the auth uid), never an email or name; [customAttributes] must not
/// contain personal data either.
class UserMetadata {
  const UserMetadata({this.userId, this.customAttributes = const {}});

  final String? userId;
  final Map<String, dynamic> customAttributes;

  UserMetadata copyWith({
    String? userId,
    Map<String, dynamic>? customAttributes,
  }) {
    return UserMetadata(
      userId: userId ?? this.userId,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'customAttributes': customAttributes};
  }

  @override
  String toString() {
    return 'UserMetadata{userId: $userId, customAttributes: $customAttributes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMetadata &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          _mapEquals(customAttributes, other.customAttributes);

  @override
  int get hashCode =>
      userId.hashCode ^
      Object.hashAllUnordered(
        customAttributes.entries.map((e) => Object.hash(e.key, e.value)),
      );

  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
