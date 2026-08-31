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
      useRootNavigator: true,
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
            padding:
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: backgroundColor(context),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.isReceive
                      ? (isRTL ? 'وقت الإستلام' : 'Pick-up')
                      : (isRTL ? 'وقت التسليم' : 'Drop-off'),
                  textAlign: TextAlign.center,
                  style: AppTypography.secondaryTypographyColor20w500(context),
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDateTime.day.toString(),
                      textAlign: TextAlign.center,
                      style: AppTypography.headingColor18(context).copyWith(
                        fontSize: 55.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('MMM').format(selectedDateTime),
                          textAlign: TextAlign.center,
                          style: AppTypography.headingColor18(context).copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('EEE').format(selectedDateTime),
                          textAlign: TextAlign.center,
                          style: AppTypography.headingColor18(context).copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Text(
                  DateFormat('h:mm a').format(selectedDateTime),
                  textAlign: TextAlign.center,
                  style: AppTypography.headingColor18(context).copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: paragraphNavyColor(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}