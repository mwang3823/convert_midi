import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../../common/assets.dart';
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
      backgroundColor: AppColors.onPrimaryContainer,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(Assets.imgIconApp, width: 120, height: 120),
            // const Icon(Icons.music_note, size: 80, color: AppColors.white),
            const SizedBox(height: 16),
            Text(
              'MIDI Streamer',
              style: AppTextStyle.bold(size: 28, color: AppColors.white),
            ),
            const SizedBox(height: 32),
            Lottie.asset(Assets.jsonLoading, width: 150),
            // const CircularProgressIndicator(color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
