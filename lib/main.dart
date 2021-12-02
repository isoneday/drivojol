import 'package:custojol/argument/detail_argumen.dart';
import 'package:custojol/argument/order_argument.dart';
import 'package:custojol/screen/detaildriver_screen.dart';
import 'package:custojol/screen/detailhistory_screen.dart'; 
import 'package:custojol/screen/history_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screen/auth_screen.dart';
import 'screen/beranda_screen.dart';
import 'screen/customsplash_screen.dart';
import 'screen/loginmysql_screen.dart';
import 'screen/registermysql_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateRoute: (settings) {
          // if (settings.name == WaitingDriverScreen.id) {
          //   OrderArgument argument = settings.arguments as OrderArgument;
          //   return MaterialPageRoute(builder: (context) {
          //     return WaitingDriverScreen(
          //       idbooking: argument.id,
          //       latOrigin: argument.latOrigin,
          //       lngOrigin: argument.lngOrigin,
          //     );
          //   });
          // } else if (settings.name == DetailDriverScreen.id) {
          //   OrderArgument argument = settings.arguments as OrderArgument;

          //   return MaterialPageRoute(builder: (context) {
          //     return DetailDriverScreen(
          //       idDriver: argument.id,
          //       latOrigin: argument.latOrigin,
          //       lngOrigin: argument.lngOrigin,
          //     );
          //   });
          // } else if (settings.name == DetailHistoryScreen.id) {
          //   // final argument = settings.arguments as DetailArgumen;
          //   final args = settings.arguments as DetailArgumen;
          //   return MaterialPageRoute(builder: (context) {
          //     return DetailHistoryScreen(
          //       bookingBiayaUser: args.bookingBiayaUser,
          //       bookingFrom: args.bookingFrom,
          //       bookingJarak: args.bookingJarak,
          //       bookingTujuan: args.bookingTujuan,
          //       idbooking: args.idbooking,
          //     );
          //   });
          // }
        },
        initialRoute: CustomSplashScreen.id,
        routes: {
          CustomSplashScreen.id: (context) => const CustomSplashScreen(),
          AuthScreen.id: (context) => AuthScreen(),
          LoginMysqlScreen.id: (context) => const LoginMysqlScreen(),
          RegisterMysqlSCreen.id: (context) => const RegisterMysqlSCreen(),
          BerandaScreen.id: (context) => BerandaScreen(),
          HistoryScreen.id: (context) => HistoryScreen(),
        });
  }
}
