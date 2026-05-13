import 'package:bounce/bounce.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/assets/app_colors.dart';
import '../../core/constants/assets/assets.dart';
import '../../core/helpers/settings/settings__cubit.dart';
import '../../core/helpers/settings/settings_model.dart';
import '../../core/helpers/settings/settings_repository.dart';
import '../../language/locale.dart';
import 'Dashed_divider.dart';
import 'components/appbar.dart';

class CallUs extends StatelessWidget {
  const CallUs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (_) => SettingsCubit(SettingsRepository())..loadSettings(),
      child: const _CallUsView(),
    );
  }
}

class _CallUsView extends StatelessWidget {
  const _CallUsView();

  static const _kFallbackFacebook  = 'https://www.facebook.com/profile.php?id=61586726069749';
  static const _kFallbackInstagram = 'https://www.instagram.com/darakson_sa?igsh=MWxobzB0MGhmeDd4ZQ%3D%3D&utm_source=qr';
  static const _kFallbackTwitter   = 'https://x.com/darakson_sa?s=11';
  static const _kFallbackTikTok    = 'https://www.tiktok.com/@darakson_sa';
  static const _kFallbackSnapchat  = 'https://www.snapchat.com/add/abudiyabsa9';
  static const _kFallbackWhatsApp  = 'https://api.whatsapp.com/send/?phone=966557221483&text&app_absent=0';
  static const _kFallbackPhone     = 'tel:920026600';
  static const _kFallbackWeb       = 'https://darakson.abudiyabksa.com';

  String _resolveWhatsApp(String? raw) {
    if (raw == null || raw.isEmpty) return _kFallbackWhatsApp;
    if (raw.startsWith('http')) return raw;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final number = digits.startsWith('0') ? '966${digits.substring(1)}' : digits;
    return 'https://api.whatsapp.com/send/?phone=$number&text&type=phone_number&app_absent=0';
  }

  String _resolvePhone(String? raw) {
    if (raw == null || raw.isEmpty) return _kFallbackPhone;
    final cleaned = raw.trim().replaceAll(RegExp(r'\+$'), '');
    return 'tel:$cleaned';
  }

  String _resolve(String? raw, String fallback) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final trimmed = raw.trim();
    if (!trimmed.startsWith('http')) return 'https://$trimmed';
    return trimmed;
  }

  Future<void> _launch(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.couldNotLaunchUrl}: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: CustomAppBar(
        title: locale.callUs.toString(),
        showBackButton: true,
        // showThemeToggle: true,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final ContactsInfo? contacts = switch (state) {
            SettingsLoaded s   => s.settings.contacts,
            SettingsFallback s => s.settings.contacts,
            _ => null,
          };

          final whatsappUrl  = _resolveWhatsApp(contacts?.whatsapp);
          final phoneUrl     = _resolvePhone(contacts?.phone);
          final facebookUrl  = _resolve(contacts?.facebook,  _kFallbackFacebook);
          final instagramUrl = _resolve(contacts?.instagram, _kFallbackInstagram);
          final twitterUrl   = _resolve(contacts?.twitter,   _kFallbackTwitter);
          final tiktokUrl    = _resolve(contacts?.tiktok,    _kFallbackTikTok);
          final snapchatUrl  = _resolve(contacts?.snapchat,  _kFallbackSnapchat);
          final websiteUrl   = _resolve(contacts?.website,   _kFallbackWeb);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 12.h),
                Image.asset(
                  'assets/images/callusss.png',
                  width: MediaQuery.of(context).size.width * 0.62,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 36.h),
                _SectionTitle(
                  title: locale.contactNumbers,
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _IconTile(
                      icon: Assets.icon_whatsApp,
                      onTap: () => _launch(context, whatsappUrl),
                    ),
                    SizedBox(width: 24.w),
                    _IconTile(
                      icon: Assets.icon_phone,
                      onTap: () => _launch(context, phoneUrl),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),
                dashedDivider(context),
                SizedBox(height: 28.h),
                _SectionTitle(
                  title: locale.socialMedia,
                ),
                SizedBox(height: 18.h),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20.w,
                  runSpacing: 16.h,
                  children: [
                    _IconTile(
                      icon: Assets.icon_instagram,
                      onTap: () => _launch(context, instagramUrl),
                    ),
                    _IconTile(
                      icon: Assets.icon_facebook,
                      onTap: () => _launch(context, facebookUrl),
                    ),
                    _IconTile(
                      icon: Assets.icon_twitter,
                      color: Color(0xff1877F2),
                      onTap: () => _launch(context, twitterUrl),
                    ),
                    _IconTile(
                      icon: Assets.icon_tiktok,
                      color: Color(0xff1877F2),
                      onTap: () => _launch(context, tiktokUrl),
                    ),
                    _IconTile(
                      icon: Assets.icon_snapchat,
                      onTap: () => _launch(context, snapchatUrl),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),
                dashedDivider(context),
                SizedBox(height: 28.h),
                _SectionTitle(
                  title: locale.visitOurWebsite,
                ),
                SizedBox(height: 18.h),
                _IconTile(
                  icon: Assets.icon_web,
                  onTap: () => _launch(context, websiteUrl),
                ),
                SizedBox(height: 36.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: AppTypography.headingColor22(context),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.onTap, this.color,
  });

  final String icon;
  final VoidCallback onTap;
  final Color? color;

  bool get _isSvg => icon.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: const Duration(milliseconds: 130),
      onTap: onTap,
      child: _isSvg
          ? SvgPicture.asset(
        icon,
        width: 52.w,
        height: 52.w,
        fit: BoxFit.contain,
        color: color,
      )
          : Image.asset(
        icon,
        width: 60.w,
        height: 60.w,
        fit: BoxFit.contain,
      ),
    );
  }
}