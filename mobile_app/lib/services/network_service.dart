import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// ============================================================
/// Network Service - Hospital Network के लिए Optimized
/// ============================================================
class NetworkService {
  static const int _timeoutSeconds = 30;
  static const int _retryAttempts = 3;
  static const int _retryDelayMs = 2000;

  /// POST request
  static Future<http.Response> post(String url, {required Map<String, String> headers, required String body}) async {
    return await _request(url, method: 'POST', headers: headers, body: body);
  }

  /// PUT request - यह सबसे ज़रूरी है जिसके लिए एरर आ रही थी
  static Future<http.Response> put(String url, {required Map<String, String> headers, required String body}) async {
    return await _request(url, method: 'PUT', headers: headers, body: body);
  }

  /// GET request
  static Future<http.Response> get(String url, {required Map<String, String> headers}) async {
    return await _request(url, method: 'GET', headers: headers);
  }

  /// Core request handler with Retry Logic
  static Future<http.Response> _request(String url, {required String method, required Map<String, String> headers, String? body}) async {
    print('🔄 $method Request: $url');

    for (int attempt = 1; attempt <= _retryAttempts; attempt++) {
      try {
        print('📤 Attempt $attempt of $_retryAttempts...');

        http.Response response;
        final uri = Uri.parse(url);
        final finalHeaders = _addDefaultHeaders(headers);

        if (method == 'POST') {
          response = await http.post(uri, headers: finalHeaders, body: body).timeout(Duration(seconds: _timeoutSeconds));
        } else if (method == 'PUT') {
          response = await http.put(uri, headers: finalHeaders, body: body).timeout(Duration(seconds: _timeoutSeconds));
        } else {
          response = await http.get(uri, headers: finalHeaders).timeout(Duration(seconds: _timeoutSeconds));
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print('✅ $method Success: $url');
          return response;
        } else if (response.statusCode >= 500) {
          print('⚠️ Server error (${response.statusCode}) - Retrying...');
          if (attempt < _retryAttempts) {
            await Future.delayed(Duration(milliseconds: _retryDelayMs));
            continue;
          }
        }
        return response;
      } on TimeoutException catch (e) {
        print('⏱️ Timeout on attempt $attempt: $e');
        if (attempt < _retryAttempts) { await Future.delayed(Duration(milliseconds: _retryDelayMs)); continue; }
        rethrow;
      } on SocketException catch (e) {
        print('🌐 Network error on attempt $attempt: $e');
        if (attempt < _retryAttempts) { await Future.delayed(Duration(milliseconds: _retryDelayMs)); continue; }
        rethrow;
      } catch (e) {
        print('❌ Error on attempt $attempt: $e');
        if (attempt < _retryAttempts) { await Future.delayed(Duration(milliseconds: _retryDelayMs)); continue; }
        rethrow;
      }
    }
    throw Exception('Failed after $_retryAttempts attempts');
  }

  static Map<String, String> _addDefaultHeaders(Map<String, String> headers) {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'HassanBabuHospital/1.0',
    };
    defaultHeaders.addAll(headers);
    return defaultHeaders;
  }
}
