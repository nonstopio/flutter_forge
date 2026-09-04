class AnalyticsEvent {
  const AnalyticsEvent({required this.name, this.parameters});

  final String name;
  final Map<String, dynamic>? parameters;

  Map<String, dynamic> toMap() {
    return {'name': name, if (parameters != null) 'parameters': parameters};
  }

  @override
  String toString() => 'AnalyticsEvent(name: $name, parameters: $parameters)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsEvent &&
        other.name == name &&
        _mapEquals(other.parameters, parameters);
  }

  @override
  int get hashCode => name.hashCode ^ parameters.hashCode;

  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

class PredefinedEvents {
  static const String appOpen = 'app_open';
  static const String login = 'login';
  static const String signUp = 'sign_up';
  static const String screenView = 'screen_view';
  static const String purchase = 'purchase';
  static const String selectContent = 'select_content';
  static const String share = 'share';
  static const String search = 'search';
  static const String beginCheckout = 'begin_checkout';
  static const String addToCart = 'add_to_cart';
  static const String removeFromCart = 'remove_from_cart';
  static const String viewItem = 'view_item';
  static const String viewItemList = 'view_item_list';
}

class PredefinedParameters {
  static const String screenName = 'screen_name';
  static const String screenClass = 'screen_class';
  static const String method = 'method';
  static const String currency = 'currency';
  static const String value = 'value';
  static const String itemId = 'item_id';
  static const String itemName = 'item_name';
  static const String itemCategory = 'item_category';
  static const String contentType = 'content_type';
  static const String searchTerm = 'search_term';
  static const String userId = 'user_id';
}
