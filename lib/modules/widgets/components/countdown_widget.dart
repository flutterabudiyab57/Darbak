import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/style/style.dart';
import '../../../language/locale.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime targetDate;

  const CountdownTimerWidget({required this.targetDate});

  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _duration = widget.targetDate.difference(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _duration = widget.targetDate.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final days = _duration.inDays;
    final hours = _duration.inHours.remainder(24);
    final minutes = _duration.inMinutes.remainder(60);
    final seconds = _duration.inSeconds.remainder(60);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 60.w,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
            child: Column(
              children: [
                Text(
                  '${NumberFormat('00').format(seconds)}',
                  style: AppTypography.headingColor16(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '${locale!.seconds}',
                  style: AppTypography.paragraphColor14(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 60.w,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
            child: Column(
              children: [
                Text(
                  '${NumberFormat('00').format(minutes)}',
                  style: AppTypography.headingColor16(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '${locale.minutes}',
                  style: AppTypography.paragraphColor14(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 60.w,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
            child: Column(
              children: [
                Text(
                  '${NumberFormat('00').format(hours)}',
                  style: AppTypography.headingColor16(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '${locale.hour}',
                  style: AppTypography.paragraphColor12(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 60.w,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
            child: Column(
              children: [
                Text(
                  '${NumberFormat('00').format(days)}',
                  style: AppTypography.headingColor16(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '${locale.day}',
                  style: AppTypography.paragraphColor14(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        ///
      ],
    );
  }
}
