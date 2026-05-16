import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/models/base/response_model.dart';
import '../../data/network/http/http_connection.dart';
import '../../data/network/api/api.dart';
import '../../data/local/shared_prefs/shared_prefs_key.dart';

class Interaction extends HttpConnection<ResponseModel> {
  final BuildContext context;
  final String? url;
  final Map<String, dynamic>? param;
  final bool showError;

  Interaction({required this.context, this.url, this.param, this.showError = true});

  @override String? get apiUrl    => url;
  @override String? get baseUrl   => API.server;
  @override Map<String, dynamic>? get bodyParam  => param;
  @override Map<String, String>?  get headerParam => null;
  @override String get tokenKey   => SharedPrefsKey.language;

  @override
  ResponseModel getError(String? error, {int? errorCode}) =>
      ResponseModel(errorMessage: error, errorCode: errorCode);

  @override
  Future<ResponseModel> handleError(ResponseModel model) async {
    return model;
  }

  @override
  Future<ResponseModel> handleResponse(http.Response? response) async {
    if ([200, 201].contains(response!.statusCode)) {
      try {
        final model = ResponseModel.fromJson(json.decode(response.body));
        return model.success ? model : handleError(model);
      } catch (_) {
        return handleError(getError('Parse error'));
      }
    }
    return handleError(
        getError('Server error', errorCode: response.statusCode));
  }
}
