# Project Base Guide — Clone Template

## Kiến trúc tổng quan

```
my_app/
├── lib/
│   ├── common/          # Shared: theme, config, globals, localization, utilities
│   ├── data/            # Models (request/response), network, local storage
│   ├── domain/          # Repository (API calls), Interaction (HTTP layer)
│   ├── presentation/    # UI (screens + blocs), base/, modules/, widgets/
│   └── sqlite/          # SQLite helpers (nếu cần offline)
├── assets/
│   ├── json/config.json
│   ├── language/        # .arb files
│   ├── image/
│   ├── icon/
│   ├── font/
│   └── sound/
└── pubspec.yaml
```

---

## 1. `pubspec.yaml` — Dependencies cốt lõi

```yaml
name: my_app
description: "My App"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.7.0

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  rxdart: 0.28.0
  shared_preferences: 2.5.3
  connectivity_plus: 6.1.3
  fluttertoast: 8.2.12
  overlay_support: 2.1.0
  intl: 0.20.2
  url_launcher: 6.3.1
  permission_handler: 11.4.0
  device_info_plus: 11.3.3
  path_provider: 2.1.5
  auto_size_text_plus: 3.0.2
  package_info_plus: 8.3.0
  dio: 5.8.0+1
  intl_utils: 2.8.12

flutter_intl:
  enabled: true
  main_locale: vi
  class_name: LangKey
  arb_dir: assets/language
  output_dir: lib/common/localization

flutter_assets_generator:
  output_dir: common

flutter:
  uses-material-design: true
  generate: true
  assets:
    - assets/image/
    - assets/icon/
    - assets/json/
    - assets/font/
    - assets/sound/
```

---

## 2. Base Pattern — `lib/presentation/base/base_view.dart`

Toàn bộ screen kế thừa `BaseView`, toàn bộ bloc kế thừa `BaseBloc<T>`:

```dart
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../common/theme.dart';

abstract class BaseView extends StatefulWidget {
  late final BuildContext context;
  late final Function(VoidCallback) setState;

  @protected
  Widget build(BuildContext context);
}

abstract class BaseBloc<S extends BaseView> extends State<S>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    widget.context = context;
    widget.setState = setState;
    WidgetsBinding.instance.addObserver(this);
    onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
  }

  @override
  void didUpdateWidget(covariant S oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget, widget)) {
      widget.context = context;
      widget.setState = setState;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }

  @override
  void dispose() {
    onDispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @protected void onInit();
  @protected void onReady();
  @protected void onResumed();
  @protected void onDispose();

  @override
  Widget build(BuildContext context) => widget.build(context);
}

// BehaviorSubject extension
extension BehaviorSubjectExtension<T> on BehaviorSubject<T> {
  set(T event, {Function? function}) {
    function?.call();
    if (!this.isClosed) this.sink.add(event);
  }

  setError(String event, {Function? function}) {
    function?.call();
    if (!this.isClosed) this.sink.addError(event);
  }

  ValueStream<T> get output => this.stream;
}

// Context extensions
extension AppContext on BuildContext {
  Size get size => MediaQuery.sizeOf(this);
  double get width => size.width;
  double get height => size.height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get top => padding.top;
  double get bottom => padding.bottom;
  double get appbar => top + kToolbarHeight;
  double sizePerRow({int count = 4, double padding = 16, double separate = 8}) {
    return (width - padding * 2 - separate * (count - 1) - 1) / count;
  }
}
```

---

## 3. Theme — `lib/common/theme.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary    = Color(0xFF184AB4);
  static const secondary  = Color(0xFF0171CC);
  static const accent     = Color(0xFFFD5E32);
  static const white      = Colors.white;
  static const black      = Colors.black;
  static const red        = Color(0xFFD70000);
  static const grey       = Color(0xFFB3B3B3);
  static const greyLight  = Color(0xFFE0E0E0);
  static const green      = Color(0xFF399D47);
  static const orange     = Color(0xFFF7941E);
  static const blue       = Color(0xFF00A1E4);
  static const background = Color(0xFFf4f4f4);
}

class AppSizes {
  static const double maxPadding   = 16.0;
  static const double minPadding   = 8.0;
  static const double borderRadius = 12.0;
}

class AppFonts {
  static const montserrat = 'Montserrat';
  static const roboto     = 'Roboto';
}

class AppTextStyle {
  static TextStyle bold({double size = 14, Color color = AppColors.black}) =>
      TextStyle(fontWeight: FontWeight.bold, fontSize: size, color: color);
  static TextStyle medium({double size = 14, Color color = AppColors.black}) =>
      TextStyle(fontWeight: FontWeight.w500, fontSize: size, color: color);
  static TextStyle regular({double size = 14, Color color = AppColors.black}) =>
      TextStyle(fontWeight: FontWeight.normal, fontSize: size, color: color);
}
```

---

## 4. Config & Globals

### `assets/json/config.json`
```json
{
  "environment": "DEV",
  "DEV": {
    "appName": "My App DEV",
    "server": "https://dev.myapi.com/api/",
    "langDefault": "vi",
    "enableLang": true,
    "releaseDate": "01/01/2026"
  },
  "PRODUCT": {
    "appName": "My App",
    "server": "https://api.myapp.com/api/",
    "langDefault": "vi",
    "enableLang": false,
    "releaseDate": "01/01/2026"
  }
}
```

### `lib/common/config.dart`
```dart
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local/shared_prefs/shared_prefs.dart';
import '../data/local/shared_prefs/shared_prefs_key.dart';
import 'assets.dart';
import 'constant.dart';
import 'globals.dart';
import 'utilities.dart';

class Config {
  static Future<void> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    Globals.prefs = SharedPrefs(prefs);
    final json = Utilities.stringToJson(
      await rootBundle.loadString(Assets.jsonConfig),
    );
    Globals.applicationMode = json['environment'];
    Globals.config = Config.fromJson(json[Globals.applicationMode]);
    if ((Globals.config.langDefault ?? '').isNotEmpty) {
      Constant.langDefault = Globals.config.langDefault!;
    }
    final lang = Globals.prefs.getString(
      SharedPrefsKey.language,
      value: Constant.langDefault,
    );
    Globals.locale = Locale(lang);
  }

  String? server;
  String? langDefault;
  bool?   enableLang;
  String? releaseDate;
  String? appName;

  Config({this.server, this.langDefault, this.enableLang, this.releaseDate, this.appName});

  Config.fromJson(Map<String, dynamic> json) {
    server = json['server'];
    if (server != null && !server!.endsWith('/')) server = '$server/';
    langDefault = json['langDefault'];
    enableLang  = json['enableLang'] ?? false;
    releaseDate = json['releaseDate'];
    appName     = json['appName'];
  }
}
```

### `lib/common/globals.dart`
```dart
import 'package:flutter/material.dart';
import '../data/local/shared_prefs/shared_prefs.dart';
import '../data/models/response/login_res_model.dart';
import '../main.dart';
import 'config.dart';

class Globals {
  static late SharedPrefs prefs;
  static late Config      config;
  static late Locale      locale;
  static late GlobalKey<MyAppState> myApp;
  static late String applicationMode;

  static bool get isLocaleInitialized {
    try { locale; return true; } catch (_) { return false; }
  }
  static bool get isApplicationModeInitialized {
    try { applicationMode; return true; } catch (_) { return false; }
  }

  static LoginResModel? model; // user logged in
}
```

---

## 5. Network Layer

### `lib/data/models/base/response_model.dart`
```dart
class ResponseModel {
  int?    errorCode;
  String? errorMessage;
  Map<String, dynamic> data  = {};
  List<dynamic>        datas = [];
  bool success = false;

  ResponseModel({this.errorCode, this.errorMessage, this.success = false});

  ResponseModel.fromJson(Map<String, dynamic> json) {
    errorCode    = json['error_code'];
    errorMessage = json['error_message'];
    data  = {};
    datas = [];
    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) data  = json['data'];
      else if (json['data'] is List<dynamic>)   datas = json['data'];
    }
    success = errorCode == 0;
  }
}
```

### `lib/data/network/http/http_connection.dart`
```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

abstract class HttpConnection<T> {
  final int _timeOut = 120;
  ApiConnectionMethod? _method;
  late Uri _uri;

  String? get apiUrl;
  String? get baseUrl;
  Map<String, dynamic>? get bodyParam;
  Map<String, String>?  get headerParam;
  String get tokenKey;

  Future<Map<String, String>> _headers() async {
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      // lang, deviceId, platform, Authorization Bearer ...
    };
  }

  Future<T> get() async {
    _method = ApiConnectionMethod.GET;
    _uri = Uri.parse(baseUrl! + apiUrl!).replace(
      queryParameters: bodyParam?.map((k, v) => MapEntry(k, v.toString())),
    );
    return _handleConnection();
  }

  Future<T> post() async {
    _method = ApiConnectionMethod.POST;
    _uri = Uri.parse(baseUrl! + apiUrl!);
    return _handleConnection();
  }

  Future<T> _handleConnection() async {
    final headers = await _headers();
    http.Response? response;
    try {
      if (_method == ApiConnectionMethod.GET) {
        response = await http.get(_uri, headers: headers)
            .timeout(Duration(seconds: _timeOut));
      } else {
        response = await http.post(_uri,
            headers: headers, body: json.encode(bodyParam))
            .timeout(Duration(seconds: _timeOut));
      }
    } on TimeoutException {
      return handleError(getError('Timeout'));
    } on SocketException catch (e) {
      return handleError(getError(e.message));
    } catch (e) {
      return handleError(getError(e.toString()));
    }
    return handleResponse(response);
  }

  T getError(String? error, {int? errorCode});
  Future<T> handleError(T model);
  Future<T> handleResponse(http.Response? response);
  Future<T> retry() => _method == ApiConnectionMethod.GET ? get() : post();
}

enum ApiConnectionMethod { GET, POST }
```

### `lib/domain/interaction/interaction.dart`
```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/models/base/response_model.dart';
import '../../data/network/http/http_connection.dart';
import '../../data/network/api/api.dart';
import '../../data/local/shared_prefs/shared_prefs_key.dart';

class Interaction extends HttpConnection<ResponseModel> {
  final BuildContext context;
  final String? url;
  final Map<String, dynamic>? param;
  final bool showError;

  Interaction({required this.context, this.url, this.param, this.showError = true});

  @override String? get apiUrl    => url;
  @override String? get baseUrl   => API.server;
  @override Map<String, dynamic>? get bodyParam  => param;
  @override Map<String, String>?  get headerParam => null;
  @override String get tokenKey   => SharedPrefsKey.token;

  @override
  ResponseModel getError(String? error, {int? errorCode}) =>
      ResponseModel(errorMessage: error, errorCode: errorCode);

  @override
  Future<ResponseModel> handleError(ResponseModel model) async {
    if (model.errorCode == 401) {
      // refresh token → retry()
    } else if (showError) {
      // show error dialog
    }
    return model;
  }

  @override
  Future<ResponseModel> handleResponse(http.Response? response) async {
    if ([200, 201].contains(response!.statusCode)) {
      try {
        final model = ResponseModel.fromJson(json.decode(response.body));
        return model.success ? model : handleError(model);
      } catch (_) {
        return handleError(getError('Parse error'));
      }
    }
    return handleError(getError('Server error', errorCode: response.statusCode));
  }
}
```

### `lib/data/network/api/api.dart`
```dart
import '../../common/globals.dart';

class API {
  static String get server => Globals.config.server ?? '';
  static int    get successCode => 0;

  static login()        => 'api/auth/sign-in';
  static logout()       => 'api/auth/sign-out';
  static refreshToken() => 'api/auth/refresh-token';
  // thêm các endpoint khác
}
```

### `lib/domain/repository.dart`
```dart
import 'package:flutter/material.dart';
import 'data/network/api/api.dart';
import 'domain/interaction/interaction.dart';

class Repository {
  static login(BuildContext context, Map<String, dynamic> param) =>
      Interaction(context: context, url: API.login(), param: param).post();

  static logout(BuildContext context) =>
      Interaction(context: context, url: API.logout(), param: {}).post();
  // thêm static method tương ứng mỗi endpoint
}
```

---

## 6. Local Storage

### `lib/data/local/shared_prefs/shared_prefs_key.dart`
```dart
class SharedPrefsKey {
  static const token          = 'token';
  static const refresh_token  = 'refresh_token';
  static const username       = 'username';
  static const password       = 'password';
  static const is_login       = 'is_login';
  static const language       = 'language';
  static const platform       = 'platform';
  static const device_id      = 'device_id';
  static const user_model     = 'user_model';
  static const version_name   = 'version_name';
  static const push_token_key = 'push_token';
}
```

### `lib/data/local/shared_prefs/shared_prefs.dart`
```dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  final SharedPreferences _prefs;
  SharedPrefs(this._prefs);

  String getString(String key, {String value = ''}) => _prefs.getString(key) ?? value;
  int    getInt   (String key, {int    value = 0 }) => _prefs.getInt(key)    ?? value;
  bool   getBool  (String key, {bool   value = false}) => _prefs.getBool(key) ?? value;
  double getDouble(String key, {double value = 0.0}) => _prefs.getDouble(key) ?? value;

  setString(String key, String? value) => _prefs.setString(key, value ?? '');
  setInt   (String key, int?    value) => _prefs.setInt(key, value ?? 0);
  setBool  (String key, bool?   value) => _prefs.setBool(key, value ?? false);
  setDouble(String key, double? value) => _prefs.setDouble(key, value ?? 0.0);
  remove   (String key) => _prefs.remove(key);
  clearAll ()           => _prefs.clear();
}
```

---

## 7. Cách tạo một Module mới

```
presentation/modules/
  feature_module/
    src/
      bloc/feature_bloc.dart
      ui/feature_screen.dart
```

### `feature_screen.dart`
```dart
import 'package:flutter/material.dart';
import '../../../../base/base_view.dart';
import 'feature_bloc.dart';

class FeatureScreen extends BaseView {
  final FeatureBloc _bloc = FeatureBloc();

  @override
  FeatureBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feature')),
      body: StreamBuilder<String>(
        stream: _bloc.title.output,
        builder: (_, snap) => Center(child: Text(snap.data ?? '')),
      ),
    );
  }
}
```

### `feature_bloc.dart`
```dart
import 'package:rxdart/rxdart.dart';
import '../../../../../domain/repository.dart';
import '../../../../base/base_view.dart';
import '../ui/feature_screen.dart';

class FeatureBloc extends BaseBloc<FeatureScreen> {
  final title = BehaviorSubject<String>.seeded('');

  @override void onInit() {}

  @override
  void onReady() {
    _loadData();
  }

  @override void onResumed() {}

  @override
  void onDispose() {
    title.close();
  }

  _loadData() async {
    final response = await Repository.someApi(context);
    if (response.success) {
      title.set(response.data['title'] ?? '');
    }
  }
}
```

---

## 8. `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'common/config.dart';
import 'common/globals.dart';
import 'common/localization/l10n.dart';
import 'common/theme.dart';
import 'presentation/modules/authen_module/src/ui/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Config.getPreferences();
  } catch (_) {
    if (!Globals.isLocaleInitialized) Globals.locale = const Locale('vi');
    if (!Globals.isApplicationModeInitialized) Globals.applicationMode = 'PRODUCT';
  }
  Globals.myApp = GlobalKey<MyAppState>();
  runApp(MyApp(key: Globals.myApp));
}

class MyApp extends StatefulWidget {
  MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  GlobalKey _key = GlobalKey();

  onRefresh() async {
    await Config.getPreferences();
    _key = GlobalKey();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        child: MaterialApp(
          key: _key,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            fontFamily: AppFonts.montserrat,
            useMaterial3: false,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          ),
          locale: Globals.locale,
          supportedLocales: LangKey.delegate.supportedLocales,
          localizationsDelegates: [
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
```

---

## Quy tắc bắt buộc khi clone

| Quy tắc | Áp dụng |
|---|---|
| Screen kế thừa `BaseView`, Bloc kế thừa `BaseBloc<Screen>` | Mọi màn hình |
| State dùng `BehaviorSubject` + `.set()` / `.output` | Tất cả reactive state |
| API call qua `Repository.method(context, param)` | Không gọi Interaction trực tiếp từ UI |
| Response luôn là `ResponseModel` — check `.success` | Sau mỗi API call |
| Config đa môi trường qua `config.json` + `Config.fromJson` | DEV / STAG / PRODUCT |
| `Globals.prefs` cho local storage, `Globals.config` cho server config | Khắp app |
| `context.width` / `context.height` thay `MediaQuery.of(context).size` | Trong `build()` |
| `CustomText` thay `Text`, `CustomScaffold` thay `Scaffold` | Mọi widget UI |
| Đóng tất cả `BehaviorSubject` trong `onDispose()` | Tránh memory leak |
| Không navigate trực tiếp — dùng `CustomNavigator.push/pushReplacement` | Navigation |
