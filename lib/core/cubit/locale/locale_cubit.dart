import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/app_shared_preferences.dart';
import '../../constants/app_constants.dart';
part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleState(_getInitialLocale()));

  static Locale _getInitialLocale() {
    final savedLocale = AppPreferences().getData(AppConstants.localeKey);
    return savedLocale == 'en' ? const Locale('en') : const Locale('ar');
  }

  Future<void> toggleLocale(BuildContext context) async {
    final newLocale = state.locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');

    await context.setLocale(newLocale);

    await AppPreferences()
        .setData(AppConstants.localeKey, newLocale.languageCode);

    emit(LocaleState(newLocale));
  }
}
