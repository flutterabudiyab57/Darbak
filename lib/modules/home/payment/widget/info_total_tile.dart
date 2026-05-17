import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoTotalTileWidget extends StatelessWidget {
  InfoTotalTileWidget(
      {Key? key,
        required this.text,
        required this.price,
        this.showDivider = true})
      : super(key: key);
  final String text;
  final String price;
  final bool showDivider;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.4)
      ),
      child: Column(
        children: [
          Padding(
            padding:   EdgeInsets.all(8.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  price,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
