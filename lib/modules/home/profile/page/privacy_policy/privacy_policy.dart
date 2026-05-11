import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:darbak/core/constants/langCode.dart';
import 'package:darbak/core/constants/privacy_policy.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/profile/page/widget/container_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/helpers/helper/Network_error_widget.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../core/helpers/settings/settings__cubit.dart';
import '../../../../../core/helpers/settings/settings_repository.dart';
import '../../../../widgets/components/appbar.dart';
import 'Web_view_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (_) => SettingsCubit(SettingsRepository())..loadSettings(),
      child: const _PrivacyPolicyView(),
    );
  }
}

class _PrivacyPolicyView extends StatefulWidget {
  const _PrivacyPolicyView();

  @override
  State<_PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<_PrivacyPolicyView> {
  bool _noConnection = false;

  String _resolveTermsLink(SettingsState state) {
    if (state is SettingsLoaded) return state.settings.pages.terms.link;
    if (state is SettingsFallback) return state.settings.pages.terms.link;
    return '';
  }

  Future<void> _reload() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;

    if (!hasConnection) {
      setState(() => _noConnection = true);
      return;
    }

    setState(() => _noConnection = false);

    if (mounted) {
      context.read<SettingsCubit>().loadSettings();
    }
  }
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (_noConnection || state is SettingsFallback) {
          return Scaffold(
            backgroundColor: backgroundColor(context),
            appBar: CustomAppBar(
              title: locale.privacyPolicy.toString(),
              showBackButton: true,
              // showThemeToggle: true,
            ),
            body: NetworkErrorWidget(onRetry: _reload),
          );
        }

        if (state is SettingsInitial || state is SettingsLoading) {
          return Scaffold(
            backgroundColor: backgroundColor(context),
            appBar: CustomAppBar(
              title: locale.privacyPolicy.toString(),
              showBackButton: true,
              // showThemeToggle: true,
            ),
            body: const LoadingIndicator(),
          );
        }

        final termsLink = _resolveTermsLink(state);

        if (termsLink.isNotEmpty) {
          return _TermsWebViewPage(
            title: locale.privacyPolicy.toString(),
            url: termsLink,
            onWebViewFailed: _reload,
          );
        }

        return _TermsStaticPage(locale: locale);
      },
    );
  }
}

class _TermsWebViewPage extends StatefulWidget {
  const _TermsWebViewPage({
    required this.title,
    required this.url,
    required this.onWebViewFailed,
  });
  final String title;
  final String url;
  final VoidCallback onWebViewFailed;

  @override
  State<_TermsWebViewPage> createState() => _TermsWebViewPageState();
}

class _TermsWebViewPageState extends State<_TermsWebViewPage> {
  bool _webViewFailed = false;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    if (_webViewFailed) return _TermsStaticPage(locale: locale);

    return WebViewScreen(
      title: widget.title,
      url: widget.url,
      onError: () {
        setState(() => _webViewFailed = true);
        widget.onWebViewFailed();
      },
    );
  }
}

class _TermsStaticPage extends StatelessWidget {
  const _TermsStaticPage({required this.locale});
  final AppLocalizations locale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: CustomAppBar(
        title: locale.privacyPolicy.toString(),
        showBackButton: true,
        // showThemeToggle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ContainerTileWidget(
          widgets: [
            Text(
              langCode == "en" ? PRIVECYTITLEEN : PRIVECYTITLEAR,
              style: AppTypography.mainTypographyColor20(context),
            ),
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.all(12.sp),
              child: Text(
                langCode == "en" ? PrivacyEn : PrivacyAr,
                style: AppTypography.paragraphColor15(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}