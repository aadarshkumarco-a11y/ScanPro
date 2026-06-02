/// HTTP client wrapper for Gemini AI API communication.
///
/// Provides a typed, error-handled interface for making requests
/// to the Google Generative AI (Gemini) API with proper timeouts,
/// header management, and response parsing.
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// Provider for the [ApiClient] instance.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// HTTP client wrapper for external API calls.
class ApiClient {
  late final http.Client _client;

  ApiClient({http.Client? client}) {
    _client = client ?? http.Client();
  }

  /// Performs an authenticated GET request to the Gemini API.
  ///
  /// [url] is the full endpoint URL. [apiKey] is appended as a
  /// query parameter per Gemini API conventions.
  Future<Map<String, dynamic>> get(
    String url,
    String apiKey, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = _buildUri(url, apiKey);
    final mergedHeaders = _mergeHeaders(headers);

    try {
      final response = await _client.get(uri, headers: mergedHeaders).timeout(timeout);
      return _handleResponse(response);
    } on ServerException {
      rethrow;
    } on AIException {
      rethrow;
    } catch (e) {
      throw AIException.requestFailed(e);
    }
  }

  /// Performs an authenticated POST request to the Gemini API.
  ///
  /// [body] is JSON-encoded automatically. [apiKey] is appended as
  /// a query parameter.
  Future<Map<String, dynamic>> post(
    String url,
    String apiKey, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final uri = _buildUri(url, apiKey);
    final mergedHeaders = _mergeHeaders(headers);
    final encodedBody = body != null ? jsonEncode(body) : null;

    try {
      final response = await _client
          .post(uri, headers: mergedHeaders, body: encodedBody)
          .timeout(timeout);
      return _handleResponse(response);
    } on ServerException {
      rethrow;
    } on AIException {
      rethrow;
    } catch (e) {
      throw AIException.requestFailed(e);
    }
  }

  /// Performs a multipart file upload request.
  Future<Map<String, dynamic>> upload(
    String url,
    String apiKey, {
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 120),
  }) async {
    final uri = _buildUri(url, apiKey);
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(headers ?? {});
    request.files.addAll(files);
    if (fields != null) request.fields.addAll(fields);

    try {
      final streamResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamResponse);
      return _handleResponse(response);
    } on ServerException {
      rethrow;
    } on AIException {
      rethrow;
    } catch (e) {
      throw AIException.requestFailed(e);
    }
  }

  /// Builds a URI with the API key as a query parameter.
  Uri _buildUri(String url, String apiKey) {
    final baseUri = Uri.parse(url);
    return baseUri.replace(queryParameters: {
      ...baseUri.queryParameters,
      'key': apiKey,
    });
  }

  /// Merges custom headers with the default JSON content type.
  Map<String, String> _mergeHeaders(Map<String, String>? custom) {
    return {
      ApiConstants.headerContentType: ApiConstants.headerJsonContentType,
      ...?custom,
    };
  }

  /// Parses the HTTP response and throws typed exceptions on errors.
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) return {};
      try {
        return jsonDecode(body) as Map<String, dynamic>;
      } on FormatException catch (e) {
        throw AIException.invalidResponse(e);
      }
    }

    // Handle specific error codes
    switch (statusCode) {
      case ApiConstants.codeRateLimited:
        throw const AIException.rateLimited();
      case ApiConstants.codeUnauthorized:
      case ApiConstants.codeForbidden:
        throw const AuthException(message: 'API access denied.', code: 'API_403');
      case ApiConstants.codeNotFound:
        throw ServerException(
          message: 'Resource not found.',
          code: 'API_404',
          statusCode: statusCode,
        );
      case ApiConstants.codeServerError:
      case ApiConstants.codeServiceUnavailable:
        throw ServerException(
          message: 'Server error. Please try again later.',
          code: 'API_5XX',
          statusCode: statusCode,
        );
      default:
        throw ServerException(
          message: 'Unexpected error ($statusCode).',
          code: 'API_$statusCode',
          statusCode: statusCode,
        );
    }
  }

  /// Disposes the underlying HTTP client.
  void dispose() {
    _client.close();
  }
}
