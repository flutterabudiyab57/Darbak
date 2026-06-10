import 'package:equatable/equatable.dart';

import '../../data/model/notification_model.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

/// First-load spinner/skeleton.
class NotificationsLoading extends NotificationsState {}

/// No internet on first load.
class NotificationsNoInternet extends NotificationsState {}

/// First-load failure (distinct from empty).
class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Loaded successfully with at least one item.
///
/// `isLoadingMore` / `loadMoreFailed` drive the pagination footer while the
/// existing list stays visible.
class NotificationsLoaded extends NotificationsState {
  final List<NotificationItem> items;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  const NotificationsLoaded({
    required this.items,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  NotificationsLoaded copyWith({
    List<NotificationItem>? items,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) =>
      NotificationsLoaded(
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      );

  @override
  List<Object?> get props => [items, hasMore, isLoadingMore, loadMoreFailed];
}

/// Loaded successfully but the list is empty.
class NotificationsEmpty extends NotificationsState {}
