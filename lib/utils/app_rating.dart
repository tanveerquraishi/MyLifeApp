import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mylifepair_matrimony/core/constants/app_constants.dart';

class AppRating {
  static Future<int> getLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.keyLaunchCount) ?? 0;
  }

  static Future<void> incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = await getLaunchCount();
    await prefs.setInt(AppConstants.keyLaunchCount, currentCount + 1);
  }

  static Future<bool> hasRated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyRated) ?? false;
  }

  static Future<void> setRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyRated, true);
  }

  static Future<bool> shouldShowRatingDialog() async {
    final launchCount = await getLaunchCount();
    final hasRatedApp = await hasRated();
    
    if (hasRatedApp) return false;
    
    return launchCount >= AppConstants.ratingPromptLaunchCount;
  }

  static Future<void> showRatingDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enjoying MyLifePair?'),
          content: const Text('Please rate us on Play Store.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await setRated();
                await launchUrl(Uri.parse(AppConstants.playStoreUrl));
              },
              child: const Text('Rate Now'),
            ),
          ],
        );
      },
    );
  }
}