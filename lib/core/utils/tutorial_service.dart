import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialService {
  static String _getTutorialKey(String userId) => 'has_seen_tutorial_$userId';

  // GlobalKeys for target elements
  static final GlobalKey addCustomerKey = GlobalKey();
  static final GlobalKey newOrderKey = GlobalKey();
  static final GlobalKey ordersTabKey = GlobalKey();
  static final GlobalKey settingsTabKey = GlobalKey();

  static Future<bool> hasSeenTutorial(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getTutorialKey(userId)) ?? false;
  }

  static Future<void> markTutorialSeen(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getTutorialKey(userId), true);
  }

  static void showTutorial(BuildContext context, String userId) {
    TutorialCoachMark(
      targets: _createTargets(context),
      colorShadow: Theme.of(context).colorScheme.primary,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        markTutorialSeen(userId);
      },
      onClickTarget: (target) {},
      onClickOverlay: (target) {},
      onSkip: () {
        markTutorialSeen(userId);
        return true;
      },
    ).show(context: context);
  }

  static List<TargetFocus> _createTargets(BuildContext context) {
    return [
      TargetFocus(
        identify: "Target 1",
        keyTarget: addCustomerKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "1. Add Your First Client",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 10),
                Text(
                  "Start by creating a profile for your customer. You can record their measurements here for future use.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Target 2",
        keyTarget: newOrderKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "2. Create an Order or Quote",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 10),
                Text(
                  "Tap here to create a new job. You can set it as a 'Quote' initially, and later convert it into an active order once the customer deposits!",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Target 3",
        keyTarget: ordersTabKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "3. Manage Orders & Invoices",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 10),
                Text(
                  "Track all your jobs here. You can update their statuses (e.g. 'Fitting' or 'Completed') and generate professional PDF Invoices to share with clients.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Target 4",
        keyTarget: settingsTabKey,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "4. Shop Setup & Upgrades",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 10),
                Text(
                  "Head to Settings to set up your Shop Name, Logo, and connected Bank Account for Invoices. You can also upgrade to Premium to unlock unlimited features!",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }
}
