import 'package:flutter/material.dart';

/// Maps the backend `type` string to its icon-box background, icon color and a
/// Material fallback icon (no per-type SVG assets exist yet — swap later).
///
/// Background swatches are the brand-fixed colors from the Figma; they have no
/// existing theme token, so they live here as named constants.
enum NotificationType {
  cashback,
  booking,
  offer,
  update,
  unknown;

  static NotificationType fromString(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'cashback':
        return NotificationType.cashback;
      case 'booking':
        return NotificationType.booking;
      case 'offer':
        return NotificationType.offer;
      case 'update':
        return NotificationType.update;
      default:
        return NotificationType.unknown;
    }
  }

  /// 40x40 icon-box background (Figma swatches).
  Color get backgroundColor {
    switch (this) {
      case NotificationType.cashback:
        return const Color(0xFFD0FAE5); // green
      case NotificationType.booking:
        return const Color(0xFFDBEAFE); // blue
      case NotificationType.offer:
        return const Color(0xFFF3E8FF); // purple
      case NotificationType.update:
        return const Color(0xFFFFEDD4); // orange
      case NotificationType.unknown:
        return const Color(0xFFE5E7EB); // neutral grey
    }
  }

  /// Icon tint — a darker shade of the box color.
  Color get iconColor {
    switch (this) {
      case NotificationType.cashback:
        return const Color(0xFF009966);
      case NotificationType.booking:
        return const Color(0xFF06479B);
      case NotificationType.offer:
        return const Color(0xFF8304B0);
      case NotificationType.update:
        return const Color(0xFFDD5406);
      case NotificationType.unknown:
        return const Color(0xFF707070);
    }
  }

  /// Material-icon fallback per type.
  IconData get icon {
    switch (this) {
      case NotificationType.cashback:
        return Icons.payments;
      case NotificationType.booking:
        return Icons.event_available;
      case NotificationType.offer:
        return Icons.local_offer;
      case NotificationType.update:
        return Icons.system_update;
      case NotificationType.unknown:
        return Icons.notifications;
    }
  }
}
