class UserMetadata {
  const UserMetadata({
    this.userId,
    this.email,
    this.name,
    this.customAttributes = const {},
  });

  final String? userId;
  final String? email;
  final String? name;
  final Map<String, dynamic> customAttributes;

  UserMetadata copyWith({
    String? userId,
    String? email,
    String? name,
    Map<String, dynamic>? customAttributes,
  }) {
    return UserMetadata(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'customAttributes': customAttributes,
    };
  }

  @override
  String toString() {
    return 'UserMetadata{userId: $userId, email: $email, name: $name, customAttributes: $customAttributes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMetadata &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          email == other.email &&
          name == other.name &&
          _mapEquals(customAttributes, other.customAttributes);

  @override
  int get hashCode =>
      userId.hashCode ^
      email.hashCode ^
      name.hashCode ^
      customAttributes.hashCode;

  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
