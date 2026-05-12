import 'dart:async';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/helpers/helper_fun.dart';
import '../../../../language/locale.dart';
import '../../../widgets/components/ad_back_button.dart';
import '../../../widgets/components/ad_home.dart';

class WebPayment extends StatefulWidget {
  const WebPayment({Key? key, required this.url}) : super(key: key);
  final String? url;

  @override
  State<WebPayment> createState() => _WebPaymentState();
}

class _WebPaymentState extends State<WebPayment> {
  late final WebViewController _controller;
  int loading = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (url.contains("payment=success")) {
              HelperFunctions.statusDialog(context: context, status: true);
              Timer(const Duration(seconds: 3), () {
                print("Payment successful URL");
              });
            } else if (url.contains("payment failed")) {
              HelperFunctions.statusDialog(context: context, status: false);
            }
            setState(() {
              loading = 100;
            });
          },
          onWebResourceError: (error) {
            print("WebView Error: ${error.description}");
          },
          onProgress: (progress) {
            setState(() {
              loading = progress;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.hs(context),
        title: Text(
          locale!.continuePaymentProcess,
          style:AppTypography.headingColor22(context),
        ),
        leading: const ADBackButton(),
        actions: const [AdHomeButton()],
      ),
      body: WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
          child: widget.url != null
              ? Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (loading < 100)
                Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue),
                    value: loading / 100,
                  ),
                ),
            ],
          )
              : Center(child: Text(locale.invalidUrl)),
        ),
      ),
    );
  }
}
