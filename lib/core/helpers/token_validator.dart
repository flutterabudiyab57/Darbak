/// Centralized token validity check.
///
/// Rules: Token must be not null, not empty after trim(), and not the literal string "null".
class TokenValidator {
  static bool isValid(String? token) {
    if (token == null) return false;
    final trimmed = token.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed == 'null') return false;
    return true;
  }
}
