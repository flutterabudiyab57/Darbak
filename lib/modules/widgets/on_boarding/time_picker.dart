import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/style/style.dart';
import '../Dashed_divider.dart';
import '../components/ad_gradient_btn.dart';

class _WheelColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final List<String> items;
  final BuildContext ctx;

  const _WheelColumn({
    required this.controller,
    required this.items,
    required this.ctx,
  });

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 46.h,
      perspective: 0.003,
      diameterRatio: 1.6,
      physics: const FixedExtentScrollPhysics(),
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          if (index < 0 || index >= items.length) return null;
          return Center(
            child: Text(
              items[index],
              style: AppTypography.paragraphColor16(ctx),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

class CustomDateTimePickerSheet extends StatefulWidget {
  final DateTime initialDateTime;
  final bool isRTL;
  final String title;
  final Function(DateTime) onConfirm;

  const CustomDateTimePickerSheet({
    Key? key,
    required this.initialDateTime,
    required this.isRTL,
    required this.title,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<CustomDateTimePickerSheet> createState() =>
      _CustomDateTimePickerSheetState();
}

class _CustomDateTimePickerSheetState
    extends State<CustomDateTimePickerSheet> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;
  late FixedExtentScrollController _periodCtrl;

  final List<String> _periods = ['ص', 'م'];
  late List<String> _hours;
  late List<String> _minutes;

  @override
  void initState() {
    super.initState();
    final dt = widget.initialDateTime;
    _focusedMonth = DateTime(dt.year, dt.month);
    _selectedDay = DateTime(dt.year, dt.month, dt.day);

    _hours = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
    _minutes = List.generate(60, (i) => i.toString().padLeft(2, '0'));

    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final periodIndex = dt.hour < 12 ? 0 : 1;

    _hourCtrl = FixedExtentScrollController(initialItem: hour12 - 1);
    _minCtrl = FixedExtentScrollController(initialItem: dt.minute);
    _periodCtrl = FixedExtentScrollController(initialItem: periodIndex);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  DateTime _buildResult() {
    final hour12 = _hourCtrl.selectedItem + 1;
    final minute = _minCtrl.selectedItem;
    final isAM = _periodCtrl.selectedItem == 0;
    final hour24 = isAM
        ? (hour12 == 12 ? 0 : hour12)
        : (hour12 == 12 ? 12 : hour12 + 12);
    return DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      hour24,
      minute,
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth =
    DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
    DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final startWeekday = firstDayOfMonth.weekday % 7;
    final monthLabel =
    DateFormat('MMMM yyyy', widget.isRTL ? 'ar' : 'en')
        .format(_focusedMonth);

    final dayLabels = widget.isRTL
        ? ['أح', 'إث', 'ث', 'أر', 'خ', 'ج', 'س']
        : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: Icon(Icons.chevron_left,
                    size: 28.sp, color: headingColor(context)),
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: AppTypography.headingColor16(context),
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: Icon(Icons.chevron_right,
                    size: 28.sp, color: headingColor(context)),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: dayLabels
                .map(
                  (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: AppTypography.mainTypographyColor12(context),
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox();
              final day = index - startWeekday + 1;
              final date = DateTime(
                  _focusedMonth.year, _focusedMonth.month, day);
              final isSelected = date == _selectedDay;
              final isToday = date == today;
              final isPast = date.isBefore(today);

              return GestureDetector(
                onTap: isPast ? null : () => setState(() => _selectedDay = date),
                child: Container(
                  margin: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? mainTypographyColor(context)
                        : isToday
                        ? mainTypographyColor(context).withValues(alpha: 0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: isSelected
                          ? AppTypography.buttonText14(context).copyWith(
                        color: backgroundColor(context),
                      )
                          : isPast
                          ? AppTypography.paragraphColor14(context)
                          .copyWith(
                        color: strokeGrayColor(context),
                      )
                          : AppTypography.paragraphColor14(context),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      children: [
        dashedDivider(context),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  widget.isRTL ? 'ساعة' : 'Hour',
                  textAlign: TextAlign.center,
                  style: AppTypography.mainTypographyColor12(context),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                flex: 2,
                child: Text(
                  widget.isRTL ? 'دقيقة' : 'Min',
                  textAlign: TextAlign.center,
                  style: AppTypography.mainTypographyColor12(context),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                flex: 1,
                child: const SizedBox(),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        SizedBox(
          height: 200.h,
          child: Stack(
            children: [
              IgnorePointer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 46.h,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: strokeGrayColor(context), width: 1.w),
                          bottom: BorderSide(
                              color: strokeGrayColor(context), width: 1.w),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              backgroundColor(context),
                              backgroundColor(context).withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 46.h),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              backgroundColor(context),
                              backgroundColor(context).withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _WheelColumn(
                        controller: _hourCtrl,
                        items: _hours,
                        ctx: context,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      flex: 2,
                      child: _WheelColumn(
                        controller: _minCtrl,
                        items: _minutes,
                        ctx: context,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      flex: 1,
                      child: _WheelColumn(
                        controller: _periodCtrl,
                        items: _periods,
                        ctx: context,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: strokeGrayColor(context),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 12.h),
            Text(widget.title, style: AppTypography.headingColor16(context)),
            SizedBox(height: 4.h),
            Divider(color: strokeGrayColor(context), height: 1),
            _buildCalendar(context),
            SizedBox(height: 8.h),
            _buildTimePicker(context),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GestureDetector(
                onTap: () {
                  widget.onConfirm(_buildResult());
                  Navigator.pop(context);
                },
                child: ADGradientButton(
                  widget.isRTL ? 'تأكيد الاختيار' : 'Confirm',
                  height: 48.h,
                  backgroundColor: mainTypographyColor(context),
                  textColor: backgroundColor(context),
                  icon: Icons.check_rounded,
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}