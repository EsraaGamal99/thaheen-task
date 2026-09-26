import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thaheen_task/core/routing/routes.dart';
import 'core/routing/app_router.dart';
import 'core/constants/app_constants.dart';

class ThaheenTask extends StatelessWidget {
  final AppRouter appRouter;
  const ThaheenTask({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        onGenerateRoute: appRouter.generateRoute,
        initialRoute: Routes.splashScreen,
      ),
    );
  }
}
