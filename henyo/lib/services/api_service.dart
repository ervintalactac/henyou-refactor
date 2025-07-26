import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/environment.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Secure API service for HenyoU
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  String? _authToken;
  Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
    if (token != null) {
      _defaultHeaders['Authorization'] = 'Bearer $token';
    } else {
      _defaultHeaders.remove('Authorization');
    }
  }

  /// Get headers for request
  Map<String, String> _getHeaders([Map<String, String>? additionalHeaders]) {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  /// Log API calls in debug mode
  void _logRequest(String method, String url, [dynamic body]) {
    if (Environment.enableLogging) {
      debugPrint('🌐 API Request: $method $url');
      if (body != null) {
        debugPrint('📦 Body: ${jsonEncode(body)}');
      }
    }
  }

  /// Log API responses in debug mode
  void _logResponse(String url, int statusCode, dynamic body) {
    if (Environment.enableLogging) {
      debugPrint('✅ API Response: $statusCode from $url');
      if (body != null) {
        final bodyStr = body is String ? body : jsonEncode(body);
        if (bodyStr.length > 500) {
          debugPrint('📥 Body: ${bodyStr.substring(0, 500)}...');
        } else {
          debugPrint('📥 Body: $bodyStr');
        }
      }
    }
  }

  /// Log API errors
  void _logError(String url, dynamic error) {
    if (Environment.enableLogging) {
      debugPrint('❌ API Error: $url');
      debugPrint('🔥 Error: $error');
    }
  }

  /// Parse response body
  dynamic _parseResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      // If JSON parsing fails, return raw body
      return response.body;
    }
  }

  /// Handle API response
  dynamic _handleResponse(http.Response response) {
    final body = _parseResponse(response);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      // Extract error message from response
      String errorMessage = 'Unknown error occurred';
      if (body is Map && body.containsKey('message')) {
        errorMessage = body['message'];
      } else if (body is Map && body.containsKey('error')) {
        errorMessage = body['error'];
      } else if (body is String) {
        errorMessage = body;
      }
      
      throw ApiException(
        errorMessage,
        statusCode: response.statusCode,
        data: body,
      );
    }
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(endpoint).replace(queryParameters: queryParameters);
    _logRequest('GET', uri.toString());

    try {
      final response = await _client
          .get(uri, headers: _getHeaders(headers))
          .timeout(Environment.apiTimeout);
      
      _logResponse(uri.toString(), response.statusCode, response.body);
      return _handleResponse(response);
    } on SocketException {
      _logError(uri.toString(), 'No internet connection');
      throw ApiException('No internet connection');
    } on TimeoutException {
      _logError(uri.toString(), 'Request timeout');
      throw ApiException('Request timeout');
    } catch (e) {
      _logError(uri.toString(), e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to complete request: $e');
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(endpoint);
    _logRequest('POST', uri.toString(), body);

    try {
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Environment.apiTimeout);
      
      _logResponse(uri.toString(), response.statusCode, response.body);
      return _handleResponse(response);
    } on SocketException {
      _logError(uri.toString(), 'No internet connection');
      throw ApiException('No internet connection');
    } on TimeoutException {
      _logError(uri.toString(), 'Request timeout');
      throw ApiException('Request timeout');
    } catch (e) {
      _logError(uri.toString(), e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to complete request: $e');
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(endpoint);
    _logRequest('PUT', uri.toString(), body);

    try {
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Environment.apiTimeout);
      
      _logResponse(uri.toString(), response.statusCode, response.body);
      return _handleResponse(response);
    } on SocketException {
      _logError(uri.toString(), 'No internet connection');
      throw ApiException('No internet connection');
    } on TimeoutException {
      _logError(uri.toString(), 'Request timeout');
      throw ApiException('Request timeout');
    } catch (e) {
      _logError(uri.toString(), e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to complete request: $e');
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(endpoint);
    _logRequest('DELETE', uri.toString());

    try {
      final response = await _client
          .delete(uri, headers: _getHeaders(headers))
          .timeout(Environment.apiTimeout);
      
      _logResponse(uri.toString(), response.statusCode, response.body);
      return _handleResponse(response);
    } on SocketException {
      _logError(uri.toString(), 'No internet connection');
      throw ApiException('No internet connection');
    } on TimeoutException {
      _logError(uri.toString(), 'Request timeout');
      throw ApiException('Request timeout');
    } catch (e) {
      _logError(uri.toString(), e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to complete request: $e');
    }
  }

  /// Upload file with multipart request
  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(endpoint);
    _logRequest('POST (Multipart)', uri.toString());

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_getHeaders(headers));
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      
      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }
      
      final streamedResponse = await request.send().timeout(Environment.apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      _logResponse(uri.toString(), response.statusCode, response.body);
      return _handleResponse(response);
    } on SocketException {
      _logError(uri.toString(), 'No internet connection');
      throw ApiException('No internet connection');
    } on TimeoutException {
      _logError(uri.toString(), 'Request timeout');
      throw ApiException('Request timeout');
    } catch (e) {
      _logError(uri.toString(), e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to upload file: $e');
    }
  }

  /// Download file
  Future<File> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, String>? headers,
    Function(int, int)? onProgress,
  }) async {
    final uri = Uri.parse(endpoint);
    _logRequest('GET (Download)', uri.toString());

    try {
      final request = http.Request('GET', uri);
      request.headers.addAll(_getHeaders(headers));
      
      final response = await _client.send(request);
      
      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to download file',
          statusCode: response.statusCode,
        );
      }
      
      final file = File(savePath);
      final sink = file.openWrite();
      
      int downloadedBytes = 0;
      final contentLength = response.contentLength ?? 0;
      
      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        
        if (onProgress != null && contentLength > 0) {
          onProgress(downloadedBytes, contentLength);
        }
      }
      
      await sink.close();
      _logResponse(uri.toString(), response.statusCode, 'File saved to: $savePath');
      
      return file;
    } on SocketException {
      _logError(uri.toString(), 'No internet connection');
      throw ApiException('No internet connection');
    } on TimeoutException {
      _logError(uri.toString(), 'Request timeout');
      throw ApiException('Request timeout');
    } catch (e) {
      _logError(uri.toString(), e);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to download file: $e');
    }
  }

  /// Dispose of resources
  void dispose() {
    _client.close();
  }
}

/// Extension for easy API calls on endpoints
extension ApiEndpointExtension on String {
  Future<dynamic> get({
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) {
    return ApiService().get(this, queryParameters: queryParameters, headers: headers);
  }

  Future<dynamic> post({
    dynamic body,
    Map<String, String>? headers,
  }) {
    return ApiService().post(this, body: body, headers: headers);
  }

  Future<dynamic> put({
    dynamic body,
    Map<String, String>? headers,
  }) {
    return ApiService().put(this, body: body, headers: headers);
  }

  Future<dynamic> delete({
    Map<String, String>? headers,
  }) {
    return ApiService().delete(this, headers: headers);
  }
}