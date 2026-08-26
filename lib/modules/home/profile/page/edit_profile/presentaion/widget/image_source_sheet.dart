import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../../core/constants/assets/app_colors.dart';
import '../../../../../../../core/style/style.dart';
import '../../../../../../../language/locale.dart';
import '../../../../../../widgets/Dashed_divider.dart';
import '../../../../../../widgets/components/ad_gradient_btn.dart';

/// Asks the user whether to pick from the gallery or the camera.
///
/// Resolves to `null` if the sheet was dismissed without choosing. This lives
/// here rather than in EditProfileCubit: a cubit that builds widgets cannot be
/// tested or reused without a BuildContext, and the strings belong to the UI
/// layer where AppLocalizations is available.
Future<ImageSource?> showImageSourceSheet(BuildContext context) {
  final locale = AppLocalizations.of(context)!;

  return showModalBottomSheet<ImageSource>(
    useRootNavigator: true,
    context: context,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    backgroundColor: backgroundColor(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Wrap(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: strokeGrayColor(sheetContext),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Text(
              locale.chooseImageSource,
              style: AppTypography.headingColor18(sheetContext),
            ),
          ),
          Divider(height: 1.h, color: strokeGrayColor(sheetContext)),
          _option(
            sheetContext,
            icon: Icons.photo_library_rounded,
            label: locale.gallery,
            source: ImageSource.gallery,
          ),
          dashedDivider(sheetContext),
          _option(
            sheetContext,
            icon: Icons.camera_alt_rounded,
            label: locale.camera,
            source: ImageSource.camera,
          ),
          dashedDivider(sheetContext),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: GestureDetector(
              onTap: () => Navigator.pop(sheetContext),
              child: ADGradientButton(
                locale.cancel.toString(),
                height: 50.h,
              ),
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    ),
  );
}

Widget _option(
  BuildContext context, {
  required IconData icon,
  required String label,
  required ImageSource source,
}) {
  return ListTile(
    leading: Icon(icon, color: iconDefaultColor(context), size: 18.sp),
    title: Text(label, style: AppTypography.paragraphColor15(context)),
    onTap: () => Navigator.pop(context, source),
  );
}
