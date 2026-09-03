import 'package:darbak/core/constants/langCode.dart';

/// The single source of the location module's active language code.
///
/// The global `langCode` defaults to `''` and is set asynchronously by
/// `LanguageCubit`, so a request issued before that completes could carry an
/// empty `Accept-Language`. This resolver defaults to `'ar'` — matching
/// `LanguageCubit` and `PreferencesConstants.lang`'s own default — rather
/// than the `'en'` fallback the rest of the app's datasources use
/// individually (see research.md R5).
///
/// Both the per-request `Accept-Language` header and every cache key MUST
/// derive from this one function, so the header and the key can never
/// diverge.
String currentLocationLanguage() => langCode.isEmpty ? 'ar' : langCode;
