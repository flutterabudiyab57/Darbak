// PROVISIONAL parsing — see notification_model.dart. When the real API JSON
// arrives, only NotificationsPage.fromJson / NotificationItem.fromJson change;
// this datasource's request shape may also need its path/method confirmed
// (see the TODO(api) constants in api_path.dart).
import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/helpers/exception/exceptions.dart';
import 'package:dio/dio.dart';

import '../model/notification_model.dart';

class NotificationsRemoteDataSource {
  // Uses the DI Dio so AppInterceptors attaches the Bearer token + Accept-Language.
  final Dio dio;

  NotificationsRemoteDataSource(this.dio);

  /// GET notifications list, paginated via `per_page`.
  /// Throws [NoInternetConnectionException] when offline, [Failure] on Dio errors.
  Future<NotificationsPage> getNotifications({
    required int page,
    int perPage = 15,
  }) async {
    final response = await safeApiCall(
      () => dio.get(
        notificationsList,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      ),
    );
    final body = response.data;
    final map = (body is Map)
        ? Map<String, dynamic>.from(body)
        : <String, dynamic>{'data': body};
    return NotificationsPage.fromJson(map);
  }

  /// POST mark a single notification as read.
  Future<void> markOneAsRead(int id) async {
    await safeApiCall(() => dio.post('$notificationsMarkOneRead/$id'));
  }

  /// POST mark all notifications as read.
  Future<void> markAllAsRead() async {
    await safeApiCall(() => dio.post(notificationsMarkAllRead));
  }
}
