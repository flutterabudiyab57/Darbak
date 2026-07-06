import 'package:bloc_test/bloc_test.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:darbak/modules/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:darbak/modules/notifications/data/model/notification_model.dart';
import 'package:darbak/modules/notifications/presentaion/bloc/notifications_cubit.dart';
import 'package:darbak/modules/notifications/presentaion/bloc/notifications_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRemoteDataSource extends Mock
    implements NotificationsRemoteDataSource {}

// ── Factories ────────────────────────────────────────────────────────────────

NotificationItem fakeNotification({int id = 1, bool isRead = false}) =>
    NotificationItem(
      id: id,
      type: 'cashback',
      title: 'Test Title $id',
      body: 'Test Body $id',
      isRead: isRead,
      createdAt: DateTime(2025, 1, 1),
    );

NotificationsPage fakePage({
  List<NotificationItem>? items,
  int currentPage = 1,
  int lastPage = 1,
}) {
  final list = items ?? [fakeNotification()];
  return NotificationsPage(
    items: list,
    currentPage: currentPage,
    lastPage: lastPage,
    perPage: 15,
    total: list.length,
  );
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockNotificationsRemoteDataSource ds;

  setUp(() {
    ds = MockNotificationsRemoteDataSource();
  });

  // ── getNotifications ───────────────────────────────────────────────────────

  group('getNotifications', () {
    late NotificationItem item;

    blocTest<NotificationsCubit, NotificationsState>(
      '→ emits [Loading, Loaded] on success',
      setUp: () {
        item = fakeNotification();
        when(() => ds.getNotifications(page: 1, perPage: 15))
            .thenAnswer((_) async => fakePage(items: [item]));
      },
      build: () => NotificationsCubit(ds),
      act: (c) => c.getNotifications(),
      expect: () => [
        NotificationsLoading(),
        NotificationsLoaded(items: [item], hasMore: false),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      '→ emits [Loading, Empty] when list is empty',
      setUp: () {
        when(() => ds.getNotifications(page: 1, perPage: 15))
            .thenAnswer((_) async => fakePage(items: []));
      },
      build: () => NotificationsCubit(ds),
      act: (c) => c.getNotifications(),
      expect: () => [NotificationsLoading(), NotificationsEmpty()],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      '→ emits [Loading, NoInternet] on no internet',
      setUp: () {
        when(() => ds.getNotifications(page: 1, perPage: 15))
            .thenThrow(const NoInternetConnectionException());
      },
      build: () => NotificationsCubit(ds),
      act: (c) => c.getNotifications(),
      expect: () => [NotificationsLoading(), NotificationsNoInternet()],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      '→ emits [Loading, Error] on server error',
      setUp: () {
        when(() => ds.getNotifications(page: 1, perPage: 15))
            .thenThrow(Exception('server error'));
      },
      build: () => NotificationsCubit(ds),
      act: (c) => c.getNotifications(),
      expect: () => [
        NotificationsLoading(),
        const NotificationsError('Exception: server error'),
      ],
    );
  });

  // ── loadMore ───────────────────────────────────────────────────────────────

  group('loadMore', () {
    late NotificationItem item1;
    late NotificationItem item2;

    blocTest<NotificationsCubit, NotificationsState>(
      '→ appends next page to existing items',
      setUp: () {
        item1 = fakeNotification(id: 1);
        item2 = fakeNotification(id: 2);
        when(() => ds.getNotifications(page: 1, perPage: 15)).thenAnswer(
          (_) async => fakePage(items: [item1], currentPage: 1, lastPage: 2),
        );
        when(() => ds.getNotifications(page: 2, perPage: 15)).thenAnswer(
          (_) async => fakePage(items: [item2], currentPage: 2, lastPage: 2),
        );
      },
      build: () => NotificationsCubit(ds),
      act: (c) async {
        await c.getNotifications();
        await c.loadMore();
      },
      skip: 2, // skip Loading + Loaded(page 1)
      expect: () => [
        // loadMore start: isLoadingMore flag set on current list
        NotificationsLoaded(items: [item1], hasMore: true, isLoadingMore: true),
        // loadMore done: both pages merged
        NotificationsLoaded(items: [item1, item2], hasMore: false),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      '→ sets loadMoreFailed = true on failure',
      setUp: () {
        item1 = fakeNotification(id: 1);
        when(() => ds.getNotifications(page: 1, perPage: 15)).thenAnswer(
          (_) async => fakePage(items: [item1], currentPage: 1, lastPage: 2),
        );
        when(() => ds.getNotifications(page: 2, perPage: 15))
            .thenThrow(Exception('server error'));
      },
      build: () => NotificationsCubit(ds),
      act: (c) async {
        await c.getNotifications();
        await c.loadMore();
      },
      skip: 2,
      expect: () => [
        NotificationsLoaded(items: [item1], hasMore: true, isLoadingMore: true),
        // original list preserved, footer flagged
        NotificationsLoaded(items: [item1], hasMore: true, loadMoreFailed: true),
      ],
    );
  });

  // ── markOneAsRead ──────────────────────────────────────────────────────────

  group('markOneAsRead', () {
    test('→ optimistic update: item flips isRead locally', () async {
      when(() => ds.getNotifications(page: 1, perPage: 15)).thenAnswer(
        (_) async => fakePage(items: [fakeNotification(id: 1, isRead: false)]),
      );
      when(() => ds.markOneAsRead(1)).thenAnswer((_) async {});

      final cubit = NotificationsCubit(ds);
      await cubit.getNotifications();
      await cubit.markOneAsRead(1);

      final state = cubit.state as NotificationsLoaded;
      expect(state.items.first.isRead, true);
      await cubit.close();
    });

    test('→ reverts isRead on server failure', () async {
      when(() => ds.getNotifications(page: 1, perPage: 15)).thenAnswer(
        (_) async => fakePage(items: [fakeNotification(id: 1, isRead: false)]),
      );
      when(() => ds.markOneAsRead(1)).thenThrow(Exception('fail'));

      final cubit = NotificationsCubit(ds);
      await cubit.getNotifications();
      await cubit.markOneAsRead(1);

      final state = cubit.state as NotificationsLoaded;
      expect(state.items.first.isRead, false);
      await cubit.close();
    });
  });

  // ── markAllAsRead ──────────────────────────────────────────────────────────

  group('markAllAsRead', () {
    test('→ all items flipped to isRead locally', () async {
      when(() => ds.getNotifications(page: 1, perPage: 15)).thenAnswer(
        (_) async => fakePage(items: [
          fakeNotification(id: 1, isRead: false),
          fakeNotification(id: 2, isRead: false),
        ]),
      );
      when(() => ds.markAllAsRead()).thenAnswer((_) async {});

      final cubit = NotificationsCubit(ds);
      await cubit.getNotifications();
      await cubit.markAllAsRead();

      final state = cubit.state as NotificationsLoaded;
      expect(state.items.every((n) => n.isRead), true);
      await cubit.close();
    });

    test('→ reverts all on server failure', () async {
      when(() => ds.getNotifications(page: 1, perPage: 15)).thenAnswer(
        (_) async => fakePage(items: [
          fakeNotification(id: 1, isRead: false),
          fakeNotification(id: 2, isRead: false),
        ]),
      );
      when(() => ds.markAllAsRead()).thenThrow(Exception('fail'));

      final cubit = NotificationsCubit(ds);
      await cubit.getNotifications();
      await cubit.markAllAsRead();

      final state = cubit.state as NotificationsLoaded;
      expect(state.items.every((n) => n.isRead), false);
      await cubit.close();
    });
  });
}
