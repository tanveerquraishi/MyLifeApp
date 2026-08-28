import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mylifepair_matrimony/core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InAppWebViewController? _webViewController;
  double _loadingProgress = 0;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(AppConstants.websiteUrl)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
              ),
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              if (kDebugMode) {
                print('WebView created');
              }
            },
            onLoadStart: (controller, url) {
              if (kDebugMode) {
                print('Loading started: $url');
              }
              setState(() {
                _isLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              if (kDebugMode) {
                print('Loading stopped: $url');
              }
              setState(() {
                _isLoading = false;
              });
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _loadingProgress = progress / 100;
              });
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading: ${(_loadingProgress * 100).toInt()}%'),
                    SizedBox(height: 8),
                    Text('Loading MyLifePair...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}