import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../language/locale.dart';
import '../../../../widgets/components/appbar.dart';
import '../../../../../core/constants/assets/app_colors.dart';


class WebViewScreen extends StatefulWidget {
  const WebViewScreen({
    Key? key,
    required this.title,
    required this.url,
    this.onError,
  }) : super(key: key);

  final String title;
  final String url;
  final VoidCallback? onError;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _hasError = false;
          }),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
            widget.onError?.call();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: CustomAppBar(
        title: widget.title,
        showBackButton: true,
        // showThemeToggle: true,
      ),
      body: Stack(
        children: [
          if (!_hasError) WebViewWidget(controller: _controller),
          if (_isLoading && !_hasError)
            const Center(child: CircularProgressIndicator()),
          if (_hasError)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 64.sp, color: Colors.grey),
                    SizedBox(height: 16.h),
                    Text(
                      'تعذّر تحميل الصفحة',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 18.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () {
                        setState(() => _hasError = false);
                        _controller.reload();
                      },
                      child: Text(
                        locale.retry,
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}