import '../../../../base/base_view.dart';
import '../../../../widgets/custom_navigator.dart';
import '../../../bluetooth_module/src/ui/bluetooth_scanner_screen.dart';
import '../ui/splash_screen.dart';

class SplashBloc extends BaseBloc<SplashScreen> {
  @override
  void onInit() {}

  @override
  void onReady() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        CustomNavigator.pushReplacement<dynamic, dynamic>(
            context, BluetoothScannerScreen());
      }
    });
  }

  @override
  void onResumed() {}

  @override
  void onDispose() {}
}
