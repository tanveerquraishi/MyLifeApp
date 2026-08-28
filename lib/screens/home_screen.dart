import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mylifepair_matrimony/core/constants/app_constants.dart';
import 'package:mylifepair_matrimony/core/services/network_service.dart';
import 'package:mylifepair_matrimony/core/services/download_service.dart';
import 'package:mylifepair_matrimony/core/services/permission_service.dart';
import 'package:mylifepair_matrimony/utils/app_rating.dart';
import 'package:mylifepair_matrimony/widgets/offline_page.dart';
import 'package:mylifepair_matrimony/widgets/error_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NetworkService _networkService = NetworkService();
  final PermissionService _permissionService = PermissionService();
  
  InAppWebViewController? _webViewController;
  double _loadingProgress = 0;
  bool _isLoading = true;
  bool _isOffline = false;
  bool _canGoBack = false;
  bool _isRefreshing = false;
  
  DateTime? _backPressTime;
  bool _hasShownRatingDialog = false;

  @override
  void initState() {
    super.initState();
    _networkService.initialize();
    _checkNetworkStatus();
    _requestPermissions();
    _checkRatingPrompt();
  }

  @override
  void dispose() {
    _networkService.dispose();
    super.dispose();
  }

  void _checkNetworkStatus() {
    _networkService.connectionStatus.listen((isConnected) {
      setState(() {
        _isOffline = !isConnected;
      });
    });
  }

  Future<void> _requestPermissions() async {
    await _permissionService.requestAllPermissions();
  }

  Future<void> _checkRatingPrompt() async {
    if (_hasShownRatingDialog) return;
    
    final shouldShow = await AppRating.shouldShowRatingDialog();
    if (shouldShow && mounted) {
      _hasShownRatingDialog = true;
      await AppRating.showRatingDialog(context);
    }
  }

  Future<bool> _handleBackButton() async {
    if (_webViewController != null && await _webViewController!.canGoBack()) {
      _webViewController!.goBack();
      return false;
    } else {
      // Show exit dialog
      final shouldExit = await _showExitDialog();
      return shouldExit ?? false;
    }
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit MyLifePair Matrimony?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _handleDoubleBack() {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(_backPressTime ?? currentTime);
    
    _backPressTime = currentTime;
    
    if (difference < const Duration(seconds: AppConstants.backPressTimeout)) {
      // Exit app
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  bool _isExternalLink(String url) {
    return AppConstants.externalLinkPatterns.any((pattern) => url.contains(pattern));
  }

  Future<NavigationActionPolicy> _handleNavigation(NavigationAction action) {
    final url = action.request.url.toString();
    
    if (_isExternalLink(url)) {
      _launchExternalUrl(url);
      return Future.value(NavigationActionPolicy.CANCEL);
    }
    
    return Future.value(NavigationActionPolicy.ALLOW);
  }

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    
    if (_webViewController != null) {
      await _webViewController!.reload();
    }
    
    setState(() {
      _isRefreshing = false;
    });
  }

  void _onDownloadStart(InAppWebViewController controller, String url) {
    if (DownloadService.isSupportedFileType(url)) {
      DownloadService.downloadFile(url);
    }
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh'),
              onTap: () {
                Navigator.pop(context);
                _webViewController?.reload();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share App'),
              onTap: () {
                Navigator.pop(context);
                _shareApp();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Open Website'),
              onTap: () {
                Navigator.pop(context);
                _launchExternalUrl(AppConstants.websiteUrl);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Exit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share(
      '${AppConstants.appName}\nVisit: ${AppConstants.websiteUrl}',
      subject: AppConstants.appName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackButton,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showMenu,
            ),
          ],
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(4),
                  child: LinearProgressIndicator(
                    value: _loadingProgress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : null,
        ),
        body: _isOffline
            ? OfflinePage(
                onRetry: () {
                  _webViewController?.reload();
                },
              )
            : RefreshIndicator(
                onRefresh: _onRefresh,
                child: Stack(
                  children: [
                    InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(AppConstants.websiteUrl),
                    headers: {
                      'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36'
                    }
                  ),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: AppConstants.enableJavaScript,
                      useShouldOverrideUrlLoading: true,
                      useOnDownloadStart: true,
                      clearCache: true,
                    ),
                    android: AndroidInAppWebViewOptions(
                      allowFileAccess: true,
                      allowContentAccess: true,
                      mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                      safeBrowsingEnabled: true,
                      useHybridComposition: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                    ),
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                    if (kDebugMode) {
                      print('WebView created successfully');
                    }
                  },
                  onLoadStart: (controller, url) {
                    if (kDebugMode) {
                      print('Loading started: $url');
                    }
                    setState(() {
                      _isLoading = true;
                      _loadingProgress = 0;
                    });
                  },
                  onLoadStop: (controller, url) {
                    if (kDebugMode) {
                      print('Loading stopped: $url');
                    }
                    setState(() {
                      _isLoading = false;
                      _loadingProgress = 1.0;
                    });
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      _loadingProgress = progress / 100;
                    });
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) {
                    return _handleNavigation(navigationAction);
                  },
                  onDownloadStart: (controller, url) {
                    _onDownloadStart(controller, url.toString());
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
                      debugPrint('WebView Error: ${consoleMessage.message}');
                    }
                  },
                  onReceivedError: (controller, request, error) {
                    if (kDebugMode) {
                      print('WebView error: ${error.description}');
                      print('Error type: ${error.type}');
                      print('Failed URL: ${request.url}');
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    _updateCanGoBack();
                  },
                ),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _updateCanGoBack() async {
    if (_webViewController != null) {
      final canGoBack = await _webViewController!.canGoBack();
      setState(() {
        _canGoBack = canGoBack;
      });
    }
  }
}