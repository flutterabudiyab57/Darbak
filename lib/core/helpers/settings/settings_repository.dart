
import 'package:dio/dio.dart';
import 'package:darbak/core/helpers/settings/settings_model.dart';

import '../../constants/api_path.dart';
import '../../constants/langCode.dart';

final SettingsModel _kFallbackSettings = SettingsModel(
  app: AppInfo(
    name: 'Darbak',
    copyright: 'All Rights reserved to Darbak Copyright © 2025',
    logo: 'https://ui-avatars.com/api/?name=darakson&bold=true',
  ),
  contacts: ContactsInfo(
    facebook:   'https://www.facebook.com/abudiyabsa',
    instagram:  'https://www.instagram.com/abudiyabsa/',
    snapchat:   'https://www.snapchat.com/add/abudiyabsa9',
    twitter:    'https://x.com/Abudiyabksa?t=WRK7v2AcKjqjtoYcZ_iZ9A&s=09',
    tiktok:     'https://www.tiktok.com/@darakson_sa',
    phone:      '920026600',
    email:      'booking@abudiyab.com.sa',
    branchName: 'الإدارة العامة - الرياض',
    address:    'شارع الكتاب - حى الملك عبد العزيز',
    whatsapp:   'https://api.whatsapp.com/send/?phone=966557492493&text&type=phone_number&app_absent=0',
    website:    'https://darakson.abudiyabksa.com',
  ),
  apps: AppsLinks(
    apple:   'https://apps.apple.com/us/app/darakson-%D8%AF%D8%B1%D8%A7%D9%83%D8%B3%D9%88%D9%86/id6743080006?platform=iphone',
    android: 'https://play.google.com/store/apps/details?id=com.app.rentdarakson',
    huawei:  'https://appgallery.huawei.com/#/app/C114522197',
  ),
  pages: PagesInfo(
    about:   AboutPage(link: '', content: ''),
    terms:   TermsPage(link: '', title: '', articles: []),
    privacy: PrivacyPage(link: '', content: ''),
  ),
);

class SettingsRepository {
  SettingsRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<SettingsModel> fetchSettings() async {
    try {
      final response = await _dio.get(
        settings,
        options: Options(
          headers: {
            "Accept":          "application/json",
            "Accept-Language": langCode.isEmpty ? "en" : langCode,
          },
        ),
      );
      // print('⚙️ [Settings] Raw response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final model = SettingsModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        return model;
      }

      throw SettingsException('Unexpected status code: ${response.statusCode}');
    } on DioException catch (e) {
      print('⚙️ [Settings] DioException: ${e.message}');
      throw SettingsException('Network error: ${e.message}');
    } catch (e) {
      print('⚙️ [Settings] Error: $e');
      throw SettingsException('Parse error: $e');
    }
  }

  Future<SettingsModel> fetchSettingsSafe() async {
    try {
      return await fetchSettings();
    } catch (_) {
      print('⚙️ [Settings] Using fallback settings');
      return _kFallbackSettings;
    }
  }

  SettingsModel get fallback => _kFallbackSettings;
}

class SettingsException implements Exception {
  SettingsException(this.message);
  final String message;

  @override
  String toString() => 'SettingsException: $message';
}