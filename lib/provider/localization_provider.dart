import 'package:flutter/cupertino.dart';
import 'package:submission_story_app/db/auth_repository.dart';

class LocalizationProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  LocalizationProvider(this.authRepository) {
    getLocalization();
  }
  Locale _locale = const Locale("load");
  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    await authRepository.setLocalization(locale.toString());
  }

  Future<void> getLocalization() async {
    final repo = await authRepository.getLocalization();
    if (repo == "id") {
      _locale = const Locale("id");
    } else {
      _locale = const Locale("en");
    }
    notifyListeners();
  }
}
