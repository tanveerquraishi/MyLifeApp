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
  String _status = 'Initializing...';
  String _error = '';

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
              setState(() {
                _status = 'WebView created';
              });
              if (kDebugMode) {
                print('WebView created');
              }
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
                _status = 'Loading: $url';
              });
              if (kDebugMode) {
                print('Loading started: $url');
              }
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
                _status = 'Loaded: $url';
              });
              if (kDebugMode) {
                print('Loading stopped: $url');
              }
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _loadingProgress = progress / 100;
              });
            },
            onReceivedError: (controller, request, error) {
              setState(() {
                _error = 'Error: ${error.description}';
                _status = 'Error loading';
              });
              if (kDebugMode) {
                print('WebView error: ${error.description}');
              }
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
                    SizedBox(height: 8),
                    Text(_status, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          if (_error.isNotEmpty)
            Container(
              color: Colors.red.shade100,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('WebView Error:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(_error),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = '';
                        _status = 'Retrying...';
                      });
                      _webViewController?.reload();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}