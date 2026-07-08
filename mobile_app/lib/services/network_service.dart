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

  /// POST request with retry logic
  static Future<http.Response> post(
    String url, {
    required Map<String, String> headers,
    required String body,
  }) async {
    print('🔄 POST Request: $url');
    
    for (int attempt = 1; attempt <= _retryAttempts; attempt++) {
      try {
        print('📤 Attempt $attempt of $_retryAttempts...');
        
        final response = await http
            .post(
              Uri.parse(url),
              headers: _addDefaultHeaders(headers),
              body: body,
            )
            .timeout(
              Duration(seconds: _timeoutSeconds),
              onTimeout: () {
                throw TimeoutException('Request timeout after $_timeoutSeconds seconds');
              },
            );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ POST Success: $url');
          return response;
        } else if (response.statusCode >= 500) {
          // Server error - retry
          print('⚠️  Server error (${response.statusCode}) - Retrying...');
          if (attempt < _retryAttempts) {
            await Future.delayed(Duration(milliseconds: _retryDelayMs));
            continue;
          }
        }
        
        return response;
      } on TimeoutException catch (e) {
        print('⏱️  Timeout on attempt $attempt: $e');
        if (attempt < _retryAttempts) {
          await Future.delayed(Duration(milliseconds: _retryDelayMs));
          continue;
        }
        rethrow;
      } on SocketException catch (e) {
        print('🌐 Network error on attempt $attempt: $e');
        if (attempt < _retryAttempts) {
          await Future.delayed(Duration(milliseconds: _retryDelayMs));
          continue;
        }
        rethrow;
      } catch (e) {
        print('❌ Error on attempt $attempt: $e');
        if (attempt < _retryAttempts) {
          await Future.delayed(Duration(milliseconds: _retryDelayMs));
          continue;
        }
        rethrow;
      }
    }
    
    throw Exception('Failed after $_retryAttempts attempts');
  }

  /// GET request with retry logic
  static Future<http.Response> get(
    String url, {
    required Map<String, String> headers,
  }) async {
    print('🔄 GET Request: $url');
    
    for (int attempt = 1; attempt <= _retryAttempts; attempt++) {
      try {
        print('📥 Attempt $attempt of $_retryAttempts...');
        
        final response = await http
            .get(
              Uri.parse(url),
              headers: _addDefaultHeaders(headers),
            )
            .timeout(
              Duration(seconds: _timeoutSeconds),
              onTimeout: () {
                throw TimeoutException('Request timeout after $_timeoutSeconds seconds');
              },
            );

        if (response.statusCode == 200) {
          print('✅ GET Success: $url');
          return response;
        } else if (response.statusCode >= 500) {
          // Server error - retry
          print('⚠️  Server error (${response.statusCode}) - Retrying...');
          if (attempt < _retryAttempts) {
            await Future.delayed(Duration(milliseconds: _retryDelayMs));
            continue;
          }
        }
        
        return response;
      } on TimeoutException catch (e) {
        print('⏱️  Timeout on attempt $attempt: $e');
        if (attempt < _retryAttempts) {
          await Future.delayed(Duration(milliseconds: _retryDelayMs));
          continue;
        }
        rethrow;
      } on SocketException catch (e) {
        print('🌐 Network error on attempt $attempt: $e');
        if (attempt < _retryAttempts) {
          await Future.delayed(Duration(milliseconds: _retryDelayMs));
          continue;
        }
        rethrow;
      } catch (e) {
        print('❌ Error on attempt $attempt: $e');
        if (attempt < _retryAttempts) {
          await Future.delayed(Duration(milliseconds: _retryDelayMs));
          continue;
        }
        rethrow;
      }
    }
    
    throw Exception('Failed after $_retryAttempts attempts');
  }

  /// Add default headers to all requests
  static Map<String, String> _addDefaultHeaders(Map<String, String> headers) {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'HassanBabuHospital/1.0',
    };
    
    defaultHeaders.addAll(headers);
    return defaultHeaders;
  }

  /// Get user-friendly error message
  static String getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Server respond nahi kar raha. Internet slow hai ya server busy hai.';
    } else if (error is SocketException) {
      return 'Internet connection nahi hai. WiFi ya mobile data check karein.';
    } else if (error.toString().contains('Connection refused')) {
      return 'Server se connection nahi ho saka. Baad mein try karein.';
    } else if (error.toString().contains('Network is unreachable')) {
      return 'Hospital network se connection nahi ho raha. Admin se puchhen.';
    } else {
      return 'Server se connect nahi ho paaya. Baad mein try karein.';
    }
  }
}
