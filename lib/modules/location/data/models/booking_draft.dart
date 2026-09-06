import 'package:darbak/modules/home/cars/data/models/cars_model.dart' hide Branch;

import 'branch.dart';

/// The completed booking selection, built once a renter has chosen a
/// pickup branch, dates, and a car, and carried forward to the additions
/// and payment screens as a constructor parameter — never through a shared
/// cubit (Constitution Principle III; FR-018/FR-019).
///
/// Immutable and deliberately narrow: **no setters, no `copyWith`**.
/// Downstream screens (additions, payment) may read this value but have no
/// way to mutate it — the only way to get a different draft is to build a
/// new one, which only happens back in the booking flow. Whether that
/// booking flow lets its own [BookingDraft] die (T065) is what actually
/// satisfies FR-017/FR-020 — this class enforces the read-only half.
///
/// [dropoffBranch] `== null` means "same as pickup" (FR-013's convention,
/// carried through from [LocationSelectionState]), not "not yet chosen" —
/// there is no separate flag for that here because a draft is only ever
/// built once the selection is already complete.
class BookingDraft {
  final Branch pickupBranch;
  final Branch? dropoffBranch;
  final DateTime pickupAt;
  final DateTime dropoffAt;
  final DataCars car;

  const BookingDraft({
    required this.pickupBranch,
    this.dropoffBranch,
    required this.pickupAt,
    required this.dropoffAt,
    required this.car,
  });

  /// The branch to submit for drop-off — [dropoffBranch] if a separate one
  /// was chosen, otherwise [pickupBranch]. Callers that need "the drop-off
  /// branch id" should read this rather than re-deriving the same
  /// null-coalescing themselves at each call site.
  Branch get effectiveDropoffBranch => dropoffBranch ?? pickupBranch;
}
