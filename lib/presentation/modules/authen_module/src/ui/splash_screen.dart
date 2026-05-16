import 'package:flutter/material.dart';
import '../../../../base/base_view.dart';
import '../../../../../common/theme.dart';
import '../bloc/splash_bloc.dart';

// ignore: must_be_immutable
class SplashScreen extends BaseView {
  final SplashBloc _bloc = SplashBloc();

  SplashScreen({super.key});

  @override
  SplashBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_note, size: 80, color: AppColors.white),
            const SizedBox(height: 16),
            Text(
              'MIDI Streamer',
              style: AppTextStyle.bold(size: 28, color: AppColors.white),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
