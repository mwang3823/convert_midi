import 'package:rxdart/rxdart.dart';
import '../../../../base/base_view.dart';
import '../ui/shell_screen.dart';

class ShellBloc extends BaseBloc<ShellScreen> {
  final selectedTab = BehaviorSubject<int>.seeded(0);

  @override void onInit()    {}
  @override void onReady()   {}
  @override void onResumed() {}

  @override
  void onDispose() {
    selectedTab.close();
  }

  void onTabChanged(int index) {
    selectedTab.set(index);
  }
}
