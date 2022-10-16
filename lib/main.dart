import 'dart:async';
import 'dart:io';

import 'package:efood_multivendor_restaurant/controller/localization_controller.dart';
import 'package:efood_multivendor_restaurant/controller/theme_controller.dart';
import 'package:efood_multivendor_restaurant/helper/notification_helper.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/theme/dark_theme.dart';
import 'package:efood_multivendor_restaurant/theme/light_theme.dart';
import 'package:efood_multivendor_restaurant/util/app_constants.dart';
import 'package:efood_multivendor_restaurant/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_strategy/url_strategy.dart';

import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  if(!GetPlatform.isWeb) {
    HttpOverrides.global = new MyHttpOverrides();
  }
  setPathUrlStrategy();
  checkPerm() async {
    var status = await Permission.bluetooth.status;
    if (status.isDenied) {

      await Permission.bluetooth.request();
    }

    if (await Permission.bluetooth.status.isPermanentlyDenied) {
      openAppSettings();
    }

  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // print("======fcmToken=:$fcmToken==============");
  Map<String, Map<String, String>> _languages = await di.init();

  int _orderID;
  try {
    if (GetPlatform.isMobile) {
      checkPerm();
      final NotificationAppLaunchDetails notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        _orderID = notificationAppLaunchDetails.payload != null ? int.parse(notificationAppLaunchDetails.payload) : null;
      }
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      });
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      });
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

      // FirebaseMessaging firebaseMessaging =FirebaseMessaging.instance;
      // print("=FirebaseMessaging===${firebaseMessaging}=======");
    }
  }catch(e) {}

  runApp(MyApp(languages: _languages, orderID: _orderID));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  final int orderID;
  MyApp({@required this.languages, @required this.orderID});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetMaterialApp(
          title: AppConstants.APP_NAME,
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
          theme: themeController.darkTheme ? dark : light,
          locale: localizeController.locale,
          translations: Messages(languages: languages),
          fallbackLocale: Locale(AppConstants.languages[0].languageCode, AppConstants.languages[0].countryCode),
          initialRoute: RouteHelper.splash,
          getPages: RouteHelper.routes,
          defaultTransition: Transition.topLevel,
          transitionDuration: Duration(milliseconds: 500),
        );
      });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

