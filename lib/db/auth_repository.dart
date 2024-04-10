import 'package:shared_preferences/shared_preferences.dart';
import 'package:submission_story_app/model/login_result.dart';

class AuthRepository {
  final String stateKey = "state";
  final String userKey = "user";
  final String sessionTimeKey = "loginTime";
  final String localeKey = "locale";
  final String filterKey = "filter";

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.getBool(stateKey) ?? false;
  }

  Future<bool> login() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));

    final currentTime = DateTime.now().toUtc().millisecondsSinceEpoch;
    preferences.setInt(sessionTimeKey, currentTime);
    return preferences.setBool(stateKey, true);
  }

  Future<int> getSessionTime() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.getInt(sessionTimeKey) ?? 15000;
  }

  Future<String> getLocalization() async {
    final locale = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return locale.getString(localeKey) ?? 'en';
  }

  Future<bool> setLocalization(String local) async {
    final locale = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return locale.setString(localeKey, local);
  }

  Future<bool> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.setBool(stateKey, false);
  }

  Future<bool> saveUser(LoginResult user) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.setString(userKey, user.toJsonString());
  }

  Future<bool> deleteUser() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.setString(userKey, "");
  }

  Future<LoginResult?> getUser() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    final json = preferences.getString(userKey) ?? "";
    LoginResult? user;
    try {
      user = LoginResult.fromJsonString(json);
    } catch (e) {
      user = null;
    }
    return user;
  }
  Future<int> getFilter() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(filterKey) ?? 0;
  }
  Future<void> setFilter(int value) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setInt(filterKey, value);
  }
}
