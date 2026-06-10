import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/helpers/helper/Network_error_widget.dart';
import 'package:darbak/core/router/notification_router.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/components/appbar.dart';
import '../bloc/notifications_cubit.dart';
import '../bloc/notifications_state.dart';
import '../widget/notification_card.dart';
import '../widget/notifications_empty_state.dart';
import '../widget/notifications_skeleton.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  static Widget entry() => BlocProvider<NotificationsCubit>(
        create: (_) => sl<NotificationsCubit>()..getNotifications(),
        child: const NotificationsScreen(),
      );

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: locale.isDirectionRTL(context)
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: backgroundColor(context),
        appBar: CustomAppBar(
          title:   locale.notificationsTitle,
          showBackButton: true,
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading ||
                state is NotificationsInitial) {
              return const NotificationsSkeleton();
            }
            if (state is NotificationsNoInternet) {
              return NetworkErrorWidget(
                onRetry: () =>
                    context.read<NotificationsCubit>().getNotifications(),
              );
            }
            if (state is NotificationsError) {
              return _ErrorView(
                message: locale.notificationsError,
                onRetry: () =>
                    context.read<NotificationsCubit>().getNotifications(),
              );
            }
            if (state is NotificationsEmpty) {
              return const NotificationsEmptyState();
            }
            if (state is NotificationsLoaded) {
              return _list(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _list(BuildContext context, NotificationsLoaded state) {
    final showFooter = state.isLoadingMore || state.loadMoreFailed;
    final locale = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () => context.read<NotificationsCubit>().getNotifications(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        itemCount: state.items.length + (showFooter ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: 15.h),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return _PaginationFooter(
              isLoading: state.isLoadingMore,
              failed: state.loadMoreFailed,
              retryLabel: locale.retry,
              onRetry: () => context.read<NotificationsCubit>().loadMore(),
            );
          }
          final item = state.items[index];
          return NotificationCard(
            item: item,
            onTap: () {
              context.read<NotificationsCubit>().markOneAsRead(item.id);
              routeFromNotification(
                context,
                type: item.type,
                data: item.data,
              );
            },
          );
        },
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.isLoading,
    required this.failed,
    required this.retryLabel,
    required this.onRetry,
  });

  final bool isLoading;
  final bool failed;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : failed
                ? TextButton(onPressed: onRetry, child: Text(retryLabel))
                : const SizedBox.shrink(),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 56.sp, color: mainTypographyColor(context)),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: paragraphColor(context),
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 16.sp,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          ElevatedButton(onPressed: onRetry, child: Text(locale.retry)),
        ],
      ),
    );
  }
}
