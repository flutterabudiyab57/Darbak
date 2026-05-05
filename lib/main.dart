import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bloc_providers.dart';
import 'core/helpers/cache/cache_helper.dart';
import 'modules/home/all_branching/data/models/branch_model.dart';
import 'service_locator.dart' as di;

Future<void> initializeHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(BranchModelAdapter());
  Hive.registerAdapter(WorkTimeAdapter());
  Hive.registerAdapter(AlldaysAdapter());
  Hive.registerAdapter(FriAdapter());
  Hive.registerAdapter(AfternoneAdapter());
  Hive.registerAdapter(MonAdapter());

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
     await initializeHive();

    await di.setup();
  } catch (e, stackTrace) {
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
