extension BasicStringExtensions on String? {
  bool get asBool {
    if (this == null) return false;
    final lower = this!.toLowerCase();
    return lower == 'true' || lower == '1';
  }
}
