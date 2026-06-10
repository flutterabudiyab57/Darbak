import 'package:bloc/bloc.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';

import '../../data/datasources/notifications_remote_datasource.dart';
import '../../data/model/notification_model.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._dataSource) : super(NotificationsInitial());

  final NotificationsRemoteDataSource _dataSource;

  static const int _perPage = 15;

  final List<NotificationItem> _items = [];
  int _currentPage = 0;
  int _lastPage = 1;

  bool get _hasMore => _currentPage < _lastPage;

  /// First load (and pull-to-refresh / retry). Resets paging.
  Future<void> getNotifications() async {
    emit(NotificationsLoading());
    _items.clear();
    _currentPage = 0;
    _lastPage = 1;
    try {
      final page = await _dataSource.getNotifications(
        page: 1,
        perPage: _perPage,
      );
      _items.addAll(page.items);
      _currentPage = page.currentPage;
      _lastPage = page.lastPage;

      if (_items.isEmpty) {
        emit(NotificationsEmpty());
      } else {
        emit(NotificationsLoaded(items: List.of(_items), hasMore: _hasMore));
      }
    } on NoInternetConnectionException {
      emit(NotificationsNoInternet());
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Loads the next page and APPENDS. On failure the existing list stays
  /// visible and `loadMoreFailed` is flagged.
  Future<void> loadMore() async {
    final current = state;
    if (current is! NotificationsLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true, loadMoreFailed: false));
    try {
      final page = await _dataSource.getNotifications(
        page: _currentPage + 1,
        perPage: _perPage,
      );
      _items.addAll(page.items);
      _currentPage = page.currentPage;
      _lastPage = page.lastPage;
      emit(NotificationsLoaded(
        items: List.of(_items),
        hasMore: _hasMore,
        isLoadingMore: false,
        loadMoreFailed: false,
      ));
    } catch (_) {
      // Keep the list; just flag the footer.
      emit(current.copyWith(isLoadingMore: false, loadMoreFailed: true));
    }
  }

  /// Optimistically flips one item to read (hides its dot); reverts on failure.
  /// Returns nothing — callers route regardless of the mark result.
  Future<void> markOneAsRead(int id) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    final index = _items.indexWhere((n) => n.id == id);
    if (index == -1 || _items[index].isRead) return;

    final original = _items[index];
    _items[index] = original.copyWith(isRead: true);
    emit(current.copyWith(items: List.of(_items)));

    try {
      await _dataSource.markOneAsRead(id);
    } catch (_) {
      // Revert.
      _items[index] = original;
      final reverted = state;
      if (reverted is NotificationsLoaded) {
        emit(reverted.copyWith(items: List.of(_items)));
      }
    }
  }

  /// Marks every item read locally + on the server. Reverts on failure.
  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationsLoaded) return;
    if (_items.every((n) => n.isRead)) return;

    final snapshot = List.of(_items);
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    emit(current.copyWith(items: List.of(_items)));

    try {
      await _dataSource.markAllAsRead();
    } catch (_) {
      _items
        ..clear()
        ..addAll(snapshot);
      final reverted = state;
      if (reverted is NotificationsLoaded) {
        emit(reverted.copyWith(items: List.of(_items)));
      }
    }
  }
}
