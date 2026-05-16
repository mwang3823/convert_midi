// ignore_for_file: use_setters_to_change_properties
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

// ignore: must_be_immutable
abstract class BaseView extends StatefulWidget {
  BaseView({super.key});

  late BuildContext viewContext;
  late void Function(VoidCallback) rebuild;

  @protected
  Widget build(BuildContext context);
}

abstract class BaseBloc<S extends BaseView> extends State<S>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    widget.viewContext = context;
    widget.rebuild = setState;
    WidgetsBinding.instance.addObserver(this);
    onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
  }

  @override
  void didUpdateWidget(covariant S oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget, widget)) {
      widget.viewContext = context;
      widget.rebuild = setState;
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

  @protected
  void onInit();
  @protected
  void onReady();
  @protected
  void onResumed();
  @protected
  void onDispose();

  @override
  Widget build(BuildContext context) => widget.build(context);
}

extension BehaviorSubjectX<T> on BehaviorSubject<T> {
  void set(T event, {Function? function}) {
    function?.call();
    if (!isClosed) sink.add(event);
  }

  void setError(String event, {Function? function}) {
    function?.call();
    if (!isClosed) sink.addError(event);
  }

  ValueStream<T> get output => stream;
}

extension AppContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get width    => screenSize.width;
  double get height   => screenSize.height;
  EdgeInsets get safePadding => MediaQuery.paddingOf(this);
  double get top    => safePadding.top;
  double get bottom => safePadding.bottom;
  double get appbar => top + kToolbarHeight;

  double sizePerRow({int count = 4, double pad = 16, double gap = 8}) =>
      (width - pad * 2 - gap * (count - 1) - 1) / count;
}
