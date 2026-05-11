import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/style/style.dart';

class IdentityTypeSelector extends StatelessWidget {
  final int selectedIndex;
  final List<IdentityTypeOption> options;
  final Function(int) onSelectionChanged;

  const IdentityTypeSelector({
    Key? key,
    required this.selectedIndex,
    required this.options,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        options.length,
        (index) => _buildCard(context, index),
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    final option = options[index];
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelectionChanged(index),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 8.w,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: isSelected
                ? iconDefaultColor(context)
                : backgroundColor(context),
            border:isSelected?null: Border.all(
              color:strokeGrayColor(context),
              width: 1.w,
            ),
          ),
          child: Center(
            child: Text(
              option.label,
              style: AppTypography.paragraphColor14(context).copyWith(
                color: isSelected
                    ? buttonTextColor(context)
                    : paragraphColor(context),
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }}
class IdentityTypeOption {
  final String label;
  final IconData icon;
  final TextInputType inputType;
  final String? Function(BuildContext, String?) validator;

  const IdentityTypeOption({
    required this.label,
    required this.icon,
    required this.inputType,
    required this.validator,
  });
}
