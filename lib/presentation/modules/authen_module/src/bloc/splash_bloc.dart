import '../../../../base/base_view.dart';
import '../../../../widgets/custom_navigator.dart';
import '../../../shell_module/src/ui/shell_screen.dart';
import '../ui/splash_screen.dart';

class SplashBloc extends BaseBloc<SplashScreen> {
  @override
  void onInit() {}

  @override
  void onReady() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        CustomNavigator.pushReplacement<dynamic, dynamic>(
            context, ShellScreen());
      }
    });
  }

  @override
  void onResumed() {}

  @override
  void onDispose() {}
}
