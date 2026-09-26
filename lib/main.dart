import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/core/di/dependency_injection.dart';
import 'core/constants/app_constants.dart';
import 'core/cubit/locale/locale_cubit.dart';
import 'core/utils/app_shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'app.dart';
import 'core/helper/app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
    final sharedPreferences = await SharedPreferences.getInstance();
  await setUp(sharedPreferences: sharedPreferences);
  
  Bloc.observer = AppBlocObserver();
  await AppPreferences().init();

  runApp(EasyLocalization(
    supportedLocales: AppConstants.supportedLocales,
    path: 'assets/lang',
    startLocale: Locale(AppPreferences().getData(AppConstants.localeKey) ?? 'ar'),
    fallbackLocale: const Locale('ar'),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
      ],
      child: ThaheenTask(appRouter: AppRouter()),
    ),
  ));
}
