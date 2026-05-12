import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension TextScaledSize on num {
  double hs(BuildContext context) =>
      h * MediaQuery.textScalerOf(context).scale(1.0);
  double ws(BuildContext context) =>
      w * MediaQuery.textScalerOf(context).scale(1.0);
  double sps(BuildContext context) =>
      sp * MediaQuery.textScalerOf(context).scale(1.0);
}
