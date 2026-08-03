import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../modules/notifications/presentaion/widget/notification_type.dart';
import 'routes.dart';

/// THE single source of truth for "a notification of type X was tapped → go here".
///
/// Both the in-app notifications screen AND Phase C FCM message taps must route
/// through this function so the mapping lives in exactly one place. Unknown /
/// unmapped types fall back to the home/main screen.
///
/// `data` is the notification's raw payload (used for deep-link ids when present).
void routeFromNotification(
  BuildContext context, {
  required String? type,
  Map<String, dynamic> data = const {},
}) {
  switch (NotificationType.fromString(type)) {
    case NotificationType.cashback:
      context.pushNamed(Routes.cashback);
      break;

    case NotificationType.booking:
      // Bookings tab (shell branch 2).
      context.go('/bookings');
      break;

    case NotificationType.offer:
      final offerId = _asIntOrNull(data['offer_id'] ?? data['id']);
      if (offerId != null) {
        context.pushNamed(Routes.offerDetails, extra: offerId);
      } else {
        context.pushNamed(Routes.offers, extra: true);
      }
      break;

    case NotificationType.update:
    case NotificationType.unknown:
      _goHome(context);
      break;
  }
}

/// Home/main = shell branch 0. Used for `update` and any unmapped type.
void _goHome(BuildContext context) => context.go('/home');

int? _asIntOrNull(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '');
}
