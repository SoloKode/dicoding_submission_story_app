import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:submission_story_app/api/api_service.dart';
import 'package:submission_story_app/db/auth_repository.dart';
import 'package:submission_story_app/model/login_result.dart';
import 'package:submission_story_app/model/user.dart';
import 'package:submission_story_app/model/user_login.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  AuthProvider(this.authRepository);

  bool isLoadingLogin = false;
  bool isLoadingLogout = false;
  bool isLoadingRegister = false;
  bool isLoggedIn = false;
  late LoginResult loginResult;

  Future<bool> login(UserLogin user) async {
    isLoadingLogin = true;
    notifyListeners();
    await ApiService(client: Client()).userLogin(user).then((value) async {
      if (value.statusCode == HttpStatus.ok) {
        var decode = jsonDecode(value.body);
        loginResult = LoginResult.fromJson(decode["loginResult"]);

        await saveUser(loginResult);
        final userState = await authRepository.getUser();
        if (loginResult == userState) {
          await authRepository.login();
        }
      } else {
        return false;
      }
    }).onError((error, stackTrace) {
      isLoadingLogin = false;
      notifyListeners();
      throw Exception(error);
    });
    isLoggedIn = await authRepository.isLoggedIn();
    isLoadingLogin = false;
    notifyListeners();
    return isLoggedIn;
  }

  Future<bool> logout() async {
    isLoadingLogout = true;
    notifyListeners();
    final logout = await authRepository.logout();
    if (logout) {
      await authRepository.deleteUser();
    }
    isLoggedIn = await authRepository.isLoggedIn();
    isLoadingLogout = false;
    notifyListeners();
    return !isLoggedIn;
  }

  Future<bool> saveUser(LoginResult user) async {
    final userState = await authRepository.saveUser(user);
    return userState;
  }

  Future<dynamic> register(User user) async {
    isLoadingRegister = true;
    notifyListeners();
    var registerState = await ApiService(client: Client()).userRegister(user);
    isLoadingRegister = false;
    notifyListeners();
    return registerState;
  }
}
