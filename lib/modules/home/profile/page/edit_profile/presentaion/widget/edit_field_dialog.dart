import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/constants/assets/app_colors.dart';
import '../../../../../../../core/style/style.dart';
import '../../../../../../../language/locale.dart';
import '../../../../../../../core/helpers/text_scale_sizing.dart';
import '../../../../../../widgets/components/ad_gradient_btn.dart';

/// Single-field edit card: a white panel that slides in over a dimmed page.
///
/// Resolves to the edited text, or `null` if the user dismissed it via the
/// close button or system back — tapping the scrim does nothing. The caller
/// decides what to do with the value — this widget performs no I/O, so it stays
/// reusable for any field.
Future<String?> showEditFieldDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String initialValue,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  String? Function(String?)? validator,
}) {
  return showGeneralDialog<String>(
    context: context,
    useRootNavigator: true,
    // Tapping the scrim must not discard a half-typed edit: the card
    // closes only via its own close button, Save, or system back.
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => _EditFieldCard(
      icon: icon,
      title: title,
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      // Slides in from the side the reading direction starts on.
      final isRtl = Directionality.of(context) == TextDirection.rtl;
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(isRtl ? 1 : -1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _EditFieldCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String initialValue;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const _EditFieldCard({
    required this.icon,
    required this.title,
    required this.initialValue,
    required this.keyboardType,
    required this.obscureText,
    this.validator,
  });

  @override
  State<_EditFieldCard> createState() => _EditFieldCardState();
}

class _EditFieldCardState extends State<_EditFieldCard> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? true) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        // Lifts the card clear of the keyboard when a field is focused.
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Material(
          color: backgroundColor(context),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(widget.icon,
                          size: 22.sp, color: headingColor(context)),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headingColor16(context),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(Icons.close,
                            size: 22.sp, color: headingColor(context)),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  TextFormField(
                    controller: _controller,
                    keyboardType: widget.keyboardType,
                    obscureText: widget.obscureText,
                    autofocus: true,
                    validator: widget.validator,
                    style: AppTypography.infoValue16(context),
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: bg2Color(context),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 14.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onTap: _submit,
                    child: ADGradientButton(
                      locale.save.toString(),
                      height: 48.hs(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
