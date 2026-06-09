import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'common/config.dart';
import 'common/globals.dart';
import 'common/localization/l10n.dart';
import 'common/log_service.dart';
import 'common/theme.dart';
import 'libs/bluetooth_service.dart';
import 'presentation/modules/authen_module/src/ui/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Config.getPreferences();
  } catch (_) {
    if (!Globals.isLocaleInitialized) Globals.locale = const Locale('vi');
    if (!Globals.isApplicationModeInitialized) {
      Globals.applicationMode = 'PRODUCT';
    }
  }
  
  // Đổi thành MockBluetoothService() khi chạy trên emulator
  Globals.bluetoothService = BluetoothService();

  await LogService.instance.init();

  Globals.myApp = GlobalKey<MyAppState>();
  runApp(MyApp(key: Globals.myApp));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  GlobalKey _key = GlobalKey();

  Future<void> onRefresh() async {
    await Config.getPreferences();
    _key = GlobalKey();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        child: MaterialApp(
          key: _key,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          ),
          locale: Globals.isLocaleInitialized ? Globals.locale : null,
          supportedLocales: LangKey.supportedLocales,
          localizationsDelegates: const [
            LangKey.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: SplashScreen(),
        ),
      ),
    );
  }
}
