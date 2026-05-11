import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class TextTileBranch extends StatelessWidget {
  const TextTileBranch(
      {Key? key,
      required this.content,
      required this.title,})
      : super(key: key);
  final String title;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style:AppTypography.headingColor16(context),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(width: 2.w,),
        AutoSizeText(
            content!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:AppTypography.headingColor14(context)
        ),
      ],
    );
  }
}
