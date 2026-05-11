import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContainerTileWidget extends StatelessWidget {
  const ContainerTileWidget({Key? key, required this.widgets})
      : super(key: key);
  final List<Widget> widgets;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:   EdgeInsets.all(10.sp),
      padding: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        // gradient: LinearGradient(
        //   begin: Alignment.bottomLeft,
        //   end: Alignment.topLeft,
        //   colors: <Color>[
        //     Theme.of(context).scaffoldBackgroundColor,
        //     Color(0xff3a3b55),
        //   ],
        // ),
        borderRadius: BorderRadius.circular(25.sp),
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        //     blurRadius: 1,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
      child: Column(
        children: widgets,
      ),
    );
  }
}
