import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

void navigateTo(context,widget ){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
  );

}
void navigateAndFinish(
    context,widget
    )=>
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>widget,
        ),
            (route) {
          return false;
        }
    );

Widget defaultSizeBox(context)=>SizedBox(
height: MediaQuery.of(context).size.height*0.17,
);
///defaultTextStyle
TextStyle defaultTextStyle(int size,FontWeight weight,Color color,)=>GoogleFonts.almarai(
    fontSize: size.sp,
    fontWeight: weight,
    color: color,
);
///defaultButtonStyle
Widget defaultButton(context,Text text)=>Container(
  width: MediaQuery.of(context).size.width,
  height:43.sp,
  decoration: BoxDecoration(
    color:  Theme.of(context).colorScheme.onPrimary,
    borderRadius: BorderRadius.circular(5.sp)
  ),
  child: Center(child: text)
);
Widget defaultSizeBoxTwo(Size size)=>SizedBox(height: size.height*0.025,);