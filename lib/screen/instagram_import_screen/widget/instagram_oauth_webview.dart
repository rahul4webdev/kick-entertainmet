import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class InstagramOAuthWebView extends StatefulWidget {
  final String authUrl;
  final String redirectUri;

  const InstagramOAuthWebView({
    super.key,
    required this.authUrl,
    required this.redirectUri,
  });

  @override
  State<InstagramOAuthWebView> createState() => _InstagramOAuthWebViewState();
}

class _InstagramOAuthWebViewState extends State<InstagramOAuthWebView> {
  late WebViewControllerPlus _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith(widget.redirectUri)) {
              _handleRedirect(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  void _handleRedirect(String url) {
    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];
    if (code != null) {
      Get.back(result: code);
    } else {
      final error = uri.queryParameters['error'];
      Get.back(result: null);
      if (error != null) {
        Get.rawSnackbar(
          message: 'Instagram authorization failed: $error',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgLightGrey(context),
        leading: IconButton(
          icon: Icon(Icons.close, color: textDarkGrey(context)),
          onPressed: () => Get.back(result: null),
        ),
        title: Text(
          'Connect Instagram',
          style: TextStyleCustom.outFitSemiBold600(
            fontSize: 18,
            color: textDarkGrey(context),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
