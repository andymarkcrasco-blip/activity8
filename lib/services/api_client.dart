import 'dart:convert';

import 'package:http/http.dart' as http;

/// Base URL of the Activity 10 REST API.
///
/// Override for another machine / deployment with:
///   flutter run -d chrome --dart-define=API_BASE=http://192.168.1.10:8000
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://localhost:8000',
);

/// Error thrown when the API cannot be reached or refuses the request.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isNetworkError => statusCode == null;

  @override
  String toString() => message;
}

/// Thin helper around the `http` package used by every service.
class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  ApiClient({String? baseUrl, http.Client? client, this.timeout = const Duration(seconds: 8)})
      : baseUrl = baseUrl ?? kApiBaseUrl,
        _client = client ?? http.Client();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleaned = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$cleaned$path').replace(queryParameters: query);
  }

  /// GET and decode a JSON object/list.
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _client.get(_uri(path, query)).timeout(timeout);
      return _decode(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Cannot reach the server at $baseUrl. Is the REST API running?\n($e)',
      );
    }
  }

  /// POST a JSON body and decode the JSON response.
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await _client
          .post(
            _uri(path),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);
      return _decode(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Cannot reach the server at $baseUrl. Is the REST API running?\n($e)',
      );
    }
  }

  dynamic _decode(http.Response res) {
    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      decoded = res.body;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }

    // FastAPI puts the explanation inside "detail".
    String message = 'Request failed (HTTP ${res.statusCode})';
    if (decoded is Map && decoded['detail'] != null) {
      message = decoded['detail'].toString();
    } else if (decoded is String && decoded.isNotEmpty) {
      message = decoded;
    }
    throw ApiException(message, statusCode: res.statusCode);
  }

  void close() => _client.close();
}
