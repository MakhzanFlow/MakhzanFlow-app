import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'mf_locale_code'; // 'ar' | 'en'

// ─── State ────────────────────────────────────────────────────────────────────
class AppLocaleState {
  const AppLocaleState({required this.locale});
  final Locale locale;

  bool get isArabic => locale.languageCode == 'ar';

  AppLocaleState copyWith({Locale? locale}) =>
      AppLocaleState(locale: locale ?? this.locale);
}

// ─── Cubit — persisted ───────────────────────────────────────────────────────
class AppLocaleCubit extends Cubit<AppLocaleState> {
  AppLocaleCubit({SharedPreferences? prefs})
      : _prefs = prefs,
        super(const AppLocaleState(locale: Locale('ar', 'EG'))) {
    _load();
  }

  final SharedPreferences? _prefs;
  SharedPreferences? get _sp => _prefs;

  Future<void> _load() async {
    final sp = _sp ?? await SharedPreferences.getInstance();
    final code = sp.getString(_kLocaleKey);
    if (code == 'en' && state.isArabic) {
      emit(state.copyWith(locale: const Locale('en', 'US')));
    } else if (code == 'ar' && !state.isArabic) {
      emit(state.copyWith(locale: const Locale('ar', 'EG')));
    }
  }

  Future<void> _persist(String code) async {
    final sp = _sp ?? await SharedPreferences.getInstance();
    await sp.setString(_kLocaleKey, code);
  }

  void setArabic() {
    emit(state.copyWith(locale: const Locale('ar', 'EG')));
    _persist('ar');
  }

  void setEnglish() {
    emit(state.copyWith(locale: const Locale('en', 'US')));
    _persist('en');
  }

  void toggle() {
    if (state.isArabic) {
      setEnglish();
    } else {
      setArabic();
    }
  }
}

/// A Flutter [ChangeNotifier] that mirrors the [AppLocaleCubit] so that
/// pure Widget classes (not using Bloc) can listen to locale changes and
/// rebuild when the language switches.
///
/// Typical usage:
///   final localeProvider = AppLocaleProvider();
///   // in main.dart or where cubit is available:
///   context.read<AppLocaleCubit>().stream.listen(localeProvider.update);
class AppLocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar', 'EG');
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  void update(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
