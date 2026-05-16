import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

abstract class HttpConnection<T> {
  final int _timeOut = 120;
  ApiConnectionMethod? _method;
  late Uri _uri;

  String? get apiUrl;
  String? get baseUrl;
  Map<String, dynamic>? get bodyParam;
  Map<String, String>?  get headerParam;
  String get tokenKey;

  Future<Map<String, String>> _headers() async {
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  Future<T> get() async {
    _method = ApiConnectionMethod.GET;
    _uri = Uri.parse('${baseUrl!}${apiUrl!}').replace(
      queryParameters: bodyParam?.map((k, v) => MapEntry(k, v.toString())),
    );
    return _handleConnection();
  }

  Future<T> post() async {
    _method = ApiConnectionMethod.POST;
    _uri = Uri.parse('${baseUrl!}${apiUrl!}');
    return _handleConnection();
  }

  Future<T> _handleConnection() async {
    final headers = await _headers();
    http.Response? response;
    try {
      if (_method == ApiConnectionMethod.GET) {
        response = await http.get(_uri, headers: headers)
            .timeout(Duration(seconds: _timeOut));
      } else {
        response = await http.post(_uri,
            headers: headers, body: json.encode(bodyParam))
            .timeout(Duration(seconds: _timeOut));
      }
    } on TimeoutException {
      return handleError(getError('Timeout'));
    } on SocketException catch (e) {
      return handleError(getError(e.message));
    } catch (e) {
      return handleError(getError(e.toString()));
    }
    return handleResponse(response);
  }

  T getError(String? error, {int? errorCode});
  Future<T> handleError(T model);
  Future<T> handleResponse(http.Response? response);
  Future<T> retry() => _method == ApiConnectionMethod.GET ? get() : post();
}

enum ApiConnectionMethod { GET, POST }
