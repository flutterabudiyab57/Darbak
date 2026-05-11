import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/shell/app_shell.dart';
import 'package:darbak/shared/commponents.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';


class ADHomeButton extends StatelessWidget {
  final bool isBackHandled;
  final VoidCallback? onPressed;

  const ADHomeButton({Key? key, this.onPressed, this.isBackHandled = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Bounce(
        onTap: isBackHandled ? onPressed : () => navigateAndFinish(context, const AppShell()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(child: Text(locale!.goHome.toString(),style: defaultTextStyle(14, FontWeight.w600, Theme.of(context).colorScheme.onPrimary),))],
        ),

    );
  }
}
