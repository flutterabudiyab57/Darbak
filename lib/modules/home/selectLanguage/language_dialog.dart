import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/constants/assets/assets.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/selectLanguage/languageCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Flag of the language currently in effect, for the settings tile's trailing
/// slot. Reads the ambient locale rather than the cubit so it repaints with the
/// rest of the screen when [LanguageCubit] rebuilds `MaterialApp.router`.
class ActiveLanguageFlag extends StatelessWidget {
  const ActiveLanguageFlag({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return SvgPicture.asset(
      isArabic ? Assets.flag_ar : Assets.flag_en,
      width: 26.w,
      height: 26.w,
    );
  }
}

/// In-place language picker for settings. The full-screen `SelectLanguage`
/// page stays as-is and keeps serving the first-run `/language` step — it just
/// isn't what settings should open, since it deliberately starts with nothing
/// selected, which reads wrong once a language is already in effect.
///
/// Switching pops first, then emits: the emit rebuilds `MaterialApp.router`, so
/// popping afterwards would tear down a dialog whose ancestors are mid-rebuild.
Future<void> showLanguageDialog(BuildContext context) {
  final cubit = context.read<LanguageCubit>();
  final locale = AppLocalizations.of(context)!;
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

  // Must be the dialog route's own context. Popping with the caller's context
  // resolves to go_router's root navigator and tears the shell page off the
  // stack instead of closing the dialog.
  void select(BuildContext dialogContext, {required bool arabic}) {
    Navigator.pop(dialogContext);
    if (arabic == isArabic) return;
    if (arabic) {
      cubit.selectArabicLanguage();
    } else {
      cubit.selectEngLanguage();
    }
  }

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: backgroundColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              locale.changeLanguage!,
              textAlign: TextAlign.center,
              style: AppTypography.headingColor20(context),
            ),
            SizedBox(height: 20.h),
            _LanguageOption(
              flag: Assets.flag_ar,
              label: locale.arabicLanguage,
              isSelected: isArabic,
              onTap: () => select(dialogContext, arabic: true),
            ),
            SizedBox(height: 12.h),
            _LanguageOption(
              flag: Assets.flag_en,
              label: locale.englishLanguage,
              isSelected: !isArabic,
              onTap: () => select(dialogContext, arabic: false),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 55.hs(context),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? buttonSecondaryColor(context) : bg2Color(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? strokeMainColor(context)
                : strokeGrayColor(context),
            width: 2.w,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(flag, width: 26.w, height: 26.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(label, style: AppTypography.headingColor18(context)),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: strokeMainColor(context),
                size: 22.sp,
              ),
          ],
        ),
      ),
    );
  }
}
