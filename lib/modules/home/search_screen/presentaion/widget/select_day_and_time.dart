import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../location/data/models/branch_work_time.dart';
import '../../../../widgets/on_boarding/time_picker.dart';
import '../../blocs/search_bloc/search_cubit.dart';
import '../../blocs/search_bloc/search_state.dart';
class SelectDayAndTimeWidget extends StatefulWidget {
  final bool isReceive;

  /// Opts this instance into time guarding (T038). `false` (the default) is
  /// what every pre-existing call site keeps getting — unrestricted slot
  /// picking except for today's already-past times, exactly as before this
  /// parameter existed. Only the daily-rent flow currently passes `true`.
  final bool enableGuarding;

  /// The branch whose work_time bounds the enabled slots. Read only when
  /// [enableGuarding] is true. `null` — including "not yet selected" — fails
  /// open (Constitution Principle IV): every slot stays enabled except the
  /// two-hours-away / dropoff-after-pickup rules below.
  final BranchWorkTime? workTime;

  const SelectDayAndTimeWidget({
    Key? key,
    required this.isReceive,
    this.enableGuarding = false,
    this.workTime,
  }) : super(key: key);

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

  /// T038: less than two hours away, outside the branch's open hours
  /// (fails open when [SelectDayAndTimeWidget.workTime] is null — Principle
  /// IV), and — for dropoff — at or before the pickup time. `null` when
  /// [SelectDayAndTimeWidget.enableGuarding] is false, which leaves
  /// [CustomDateTimePickerSheet] with no guard at all: identical to this
  /// widget's behaviour before T038.
  bool Function(DateTime)? _slotGuard(BuildContext context) {
    if (!widget.enableGuarding) return null;
    return (DateTime dt) {
      final withinWorkTime = widget.workTime?.isOpenAt(dt) ?? true;
      if (!withinWorkTime) return false;
      if (widget.isReceive) {
        return dt.isAfter(DateTime.now().add(const Duration(hours: 2)));
      }
      final pickup = BlocProvider.of<SearchCubit>(context).receiveDateValue;
      return dt.isAfter(pickup);
    };
  }

  void _showPicker(BuildContext context, bool isRTL) {
    final guard = _slotGuard(context);
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
        isSlotEnabled: guard,
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