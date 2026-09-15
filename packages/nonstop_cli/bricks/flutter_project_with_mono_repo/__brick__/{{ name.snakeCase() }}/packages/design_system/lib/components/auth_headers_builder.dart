{{#network}}import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:network/network.dart';

/// Supplies bearer headers without starting a new refresh on every rebuild.
/// Inject a provider in tests; the composition-root registration is the default.
/// Use a new key when the signed-in identity changes.
class AuthHeadersBuilder extends StatefulWidget {
  const AuthHeadersBuilder({
    super.key,
    required this.builder,
    this.validateToken = false,
    this.provider,
    this.logger,
  });

  final Widget Function(BuildContext context, Map<String, String> headers)
  builder;
  final bool validateToken;
  final AuthTokenProvider? provider;
  final Logger? logger;

  @override
  State<AuthHeadersBuilder> createState() => _AuthHeadersBuilderState();
}

class _AuthHeadersBuilderState extends State<AuthHeadersBuilder> {
  Future<Map<String, String>>? _headers;

  AuthTokenProvider? get _provider =>
      widget.provider ??
      (di.has<AuthTokenProvider>() ? di.get<AuthTokenProvider>() : null);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void didUpdateWidget(covariant AuthHeadersBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider ||
        oldWidget.validateToken != widget.validateToken) {
      _refresh();
    }
  }

  void _refresh() {
    _headers = widget.validateToken ? _load() : null;
  }

  Map<String, String> _fromToken(String? token) =>
      token == null || token.isEmpty ? {} : {'Authorization': 'Bearer $token'};

  void _log(Object error, StackTrace stack) {
    final logger =
        widget.logger ?? (di.has<Logger>() ? di.get<Logger>() : null);
    logger?.e('Unable to obtain image authentication headers', error, stack);
  }

  Future<Map<String, String>> _load() async {
    try {
      return _fromToken(await _provider?.getValidToken());
    } catch (error, stack) {
      _log(error, stack);
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.validateToken) {
      Map<String, String> headers;
      try {
        headers = _fromToken(_provider?.getCurrentToken());
      } catch (error, stack) {
        _log(error, stack);
        headers = {};
      }
      return widget.builder(context, headers);
    }
    return FutureBuilder<Map<String, String>>(
      key: ValueKey(_headers),
      future: _headers,
      builder: (context, snapshot) =>
          widget.builder(context, snapshot.data ?? {}),
    );
  }
}
{{/network}}
