import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/style/style.dart';
import '../components/ad_gradient_btn.dart';

class _WheelColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final List<String> items;
  final BuildContext ctx;
  final double itemExtent;
  final TextStyle Function(int index)? styleBuilder;
  final ValueChanged<int>? onSelectedItemChanged;

  const _WheelColumn({
    required this.controller,
    required this.items,
    required this.ctx,
    this.itemExtent = 46,
    this.styleBuilder,
    this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: itemExtent,
      perspective: 0.003,
      diameterRatio: 1.6,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          if (index < 0 || index >= items.length) return null;
          return Center(
            child: Text(
              items[index],
              style: styleBuilder != null
                  ? styleBuilder!(index)
                  : AppTypography.paragraphColor16(ctx),
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
  int _selectedTab = 0; // 0 = Date, 1 = Time

  late List<String> _timeSlots;
  late FixedExtentScrollController _timeSlotCtrl;

  @override
  void initState() {
    super.initState();
    final dt = widget.initialDateTime;
    _focusedMonth = DateTime(dt.year, dt.month);
    _selectedDay = DateTime(dt.year, dt.month, dt.day);

    _timeSlots = _generateTimeSlots();
    final initialSlot =
        (dt.hour * 2) + (dt.minute >= 30 ? 1 : 0);
    _timeSlotCtrl = FixedExtentScrollController(initialItem: initialSlot);
  }

  @override
  void dispose() {
    _timeSlotCtrl.dispose();
    super.dispose();
  }

  List<String> _generateTimeSlots() {
    final slots = <String>[];
    for (int h = 0; h < 24; h++) {
      for (int m = 0; m < 60; m += 30) {
        final dt = DateTime(2000, 1, 1, h, m);
        final formatted =
            DateFormat('hh:mm a', widget.isRTL ? 'ar' : 'en').format(dt);
        slots.add(formatted);
      }
    }
    return slots;
  }

  bool get _isSelectedDayToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _selectedDay == today;
  }

  int get _currentMinSlot {
    final now = DateTime.now();
    final totalMinutes = now.hour * 60 + now.minute;
    return (totalMinutes / 30).ceil().clamp(0, _timeSlots.length - 1);
  }

  bool _isSlotPast(int index) {
    if (!_isSelectedDayToday) return false;
    return index < _currentMinSlot;
  }

  void _handleTimeSlotChanged(int index) {
    if (_isSlotPast(index)) {
      final target = _currentMinSlot;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _timeSlotCtrl.animateToItem(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
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
    final totalMinutes = _timeSlotCtrl.selectedItem * 30;
    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;
    return DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      hour,
      minute,
    );
  }

  Widget _buildNavButton(
      BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor(context),
          border: Border.all(color: strokeGrayColor(context), width: 1.w),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Icon(icon, size: 18.sp, color: headingColor(context)),
      ),
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
              _buildNavButton(context, Icons.chevron_left, _prevMonth),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: AppTypography.headingColor18(context),
                ),
              ),
              _buildNavButton(context, Icons.chevron_right, _nextMonth),
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
                    style: AppTypography.mainTypographyColor12(context)
                        .copyWith(color: paragraphNavyColor(context)),
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
    return SizedBox(
      height: 208.h,
      child: Stack(
        children: [
          IgnorePointer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 52.h,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: bg2Color(context).withValues(alpha: 0.6),
                    border: Border.all(
                        color: strokeGrayColor(context), width: 1.w),
                    borderRadius: BorderRadius.circular(24.r),
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
                SizedBox(height: 52.h),
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
            child: _WheelColumn(
              controller: _timeSlotCtrl,
              items: _timeSlots,
              ctx: context,
              itemExtent: 52.h,
              onSelectedItemChanged: _handleTimeSlotChanged,
              styleBuilder: (index) => AppTypography.infoLabel16(context)
                  .copyWith(
                color: paragraphNavyColor(context)
                    .withValues(alpha: _isSlotPast(index) ? 0.3 : 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, int index, String label) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? backgroundColor(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: isActive
              ? AppTypography.mainTypographyColor16(context)
              : TextStyle(
            fontFamily: 'ThmanyahSans',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: paragraphNavyColor(context),
          ),
        ),
      ),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(widget.title,
                          style: AppTypography.headingColor16(context)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bg2Color(context),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Icon(Icons.close,
                          size: 20.sp, color: headingColor(context)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Divider(color: strokeGrayColor(context), height: 1),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: bg2Color(context),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                          context, 0, widget.isRTL ? 'التاريخ' : 'Date'),
                    ),
                    Expanded(
                      child: _buildTabButton(
                          context, 1, widget.isRTL ? 'الوقت' : 'Time'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            IndexedStack(
              index: _selectedTab,
              children: [
                _buildCalendar(context),
                _buildTimePicker(context),
              ],
            ),
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
