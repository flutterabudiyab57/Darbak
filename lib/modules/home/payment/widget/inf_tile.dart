import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoTileWidget extends StatelessWidget {
  InfoTileWidget(
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
    return Column(
      children: [
        Padding(
          padding:   EdgeInsets.all(8.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              Text(
                price,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        showDivider
            ? Divider(
                color: Theme.of(context).colorScheme.primary,
              )
            : SizedBox(),
      ],
    );
  }
}
