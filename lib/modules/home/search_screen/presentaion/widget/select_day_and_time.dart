import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../widgets/on_boarding/time_picker.dart';
import '../../blocs/search_bloc/search_cubit.dart';
import '../../blocs/search_bloc/search_state.dart';
class SelectDayAndTimeWidget extends StatefulWidget {
  final bool isReceive;
  const SelectDayAndTimeWidget({Key? key, required this.isReceive})
      : super(key: key);

  @override
  State<SelectDayAndTimeWidget> createState() => _SelectDayAndTimeWidgetState();
}

class _SelectDayAndTimeWidgetState extends State<SelectDayAndTimeWidget> {
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDateTime = widget.isReceive
        ? now.add(const Duration(hours: 2))
        : now.add(const Duration(hours: 26));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = BlocProvider.of<SearchCubit>(context);
      if (widget.isReceive) {
        cubit.receiveDateValue = selectedDateTime;
      } else {
        cubit.driveDateValue = selectedDateTime;
      }
    });
  }

  void _showPicker(BuildContext context, bool isRTL) {
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxWidth: double.infinity,),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomDateTimePickerSheet(
        initialDateTime: selectedDateTime,
        isRTL: isRTL,
        title: widget.isReceive
            ? (isRTL ? 'تاريخ الاستلام' : 'Pick-up')
            : (isRTL ? 'تاريخ التسليم' : 'Drop-off'),
        onConfirm: (dt) {
          setState(() => selectedDateTime = dt);
          final cubit = BlocProvider.of<SearchCubit>(context);
          if (widget.isReceive) {
            cubit.receiveDateValue = dt;
          } else {
            cubit.driveDateValue = dt;
          }
          cubit.changeState();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final isRTL = locale!.isDirectionRTL(context);

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => _showPicker(context, isRTL),
          child: Container(
            width: double.infinity,
            padding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              border: Border.all(
                  color: strokeGrayColor(context), width: 1.5.w),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isReceive
                      ? (isRTL ? 'حدد تاريخ الاستلام' : 'Pick-up')
                      : (isRTL ? 'حدد تاريخ التسليم' : 'Drop-off'),
                  style: AppTypography.headingColor16(context),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 15.sp,
                        color: iconDefaultColor(context)),
                    SizedBox(width: 6.w),
                    Text(
                      DateFormat('EEE, d MMMM yyyy')
                          .format(selectedDateTime),
                      style:
                      AppTypography.mainTypographyColor14(context),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time_rounded,
                        size: 15.sp,
                        color: iconDefaultColor(context)),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormat('hh:mm a').format(selectedDateTime),
                      style:
                      AppTypography.mainTypographyColor14(context),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.edit_outlined,
                        size: 20.sp,
                        color: mainTypographyColor(context)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}