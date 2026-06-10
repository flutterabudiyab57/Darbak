import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'bloc_providers.dart';
import 'core/helpers/cache/cache_helper.dart';
import 'core/helpers/notifications/push_notification_service.dart';
import 'hive_registrar.g.dart';
import 'service_locator.dart' as di;

Future<void> initializeHive() async {
  await Hive.initFlutter();
  Hive.registerAdapters();
  await CacheHelper.init();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
   FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    return true;
  };

  try {
    // Reads native config (android/app/google-services.json,
    // ios/Runner/GoogleService-Info.plist). No firebase_options.dart.
    await Firebase.initializeApp();
    if (kDebugMode) {
      debugPrint('[FCM] Firebase.initializeApp() succeeded');
    }

     await initializeHive();

    await di.setup();

    await di.sl<PushNotificationService>().init();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[FCM] boot init failed: $e');
    }
  }

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(App());
}

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, widget) {
        return CreateBlocProviders(context);
      },
    );
  }
}
