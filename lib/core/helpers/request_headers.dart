import 'token_validator.dart';

/// Helper to build HTTP request headers with proper Authorization handling.
///
/// Rules:
/// - If token is null, empty after trim(), or the literal string "null", omit Authorization header.
/// - Never emit "Bearer null".
/// - Preserves other headers (Content-Type, Accept, Accept-Language, etc.)
class RequestHeaders {
  /// Build headers for http package requests.
  /// Merges [otherHeaders] and conditionally adds Authorization if token is valid.
  static Map<String, String> forHttp({
    String? token,
    Map<String, String>? otherHeaders,
  }) {
    final headers = <String, String>{...?otherHeaders};

    if (TokenValidator.isValid(token)) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Build headers for Dio Options.
  /// Merges [otherHeaders] and conditionally adds Authorization if token is valid.
  static Map<String, dynamic> forDio({
    String? token,
    Map<String, dynamic>? otherHeaders,
  }) {
    final headers = <String, dynamic>{...?otherHeaders};

    if (TokenValidator.isValid(token)) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
