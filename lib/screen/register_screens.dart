import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_story_app/model/user.dart';
import 'package:submission_story_app/provider/auth_provider.dart';
import 'package:submission_story_app/utils/common.dart';

class RegisterScreens extends StatefulWidget {
  final Function() onRegister;
  final Function() onLogin;
  const RegisterScreens(
      {super.key, required this.onRegister, required this.onLogin});

  @override
  State<RegisterScreens> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreens> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AutoSizeText(
                    AppLocalizations.of(context)!.storyApp,
                    minFontSize: 25,
                    style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 0),
                    textAlign: TextAlign.center,
                  ),
                  AutoSizeText(
                    AppLocalizations.of(context)!.registerText,
                    minFontSize: 25,
                    style: const TextStyle(
                        fontSize: 25, color: Colors.black87, height: 0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    focusNode: _nameFocusNode,
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.namaValidator;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: AppLocalizations.of(context)!.nameHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    focusNode: _emailFocusNode,
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emailValidator;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: AppLocalizations.of(context)!.emailHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    focusNode: _passwordFocusNode,
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: AppLocalizations.of(context)!.passwordHint,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.passwordValidator;
                      }
                      if (value.length < 8) {
                        return AppLocalizations.of(context)!
                            .minPasswordValidator;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  context.watch<AuthProvider>().isLoadingRegister
                      ? const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Column(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize:
                                    const Size.fromWidth(double.maxFinite),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () async {
                                _nameFocusNode.unfocus();
                                _passwordFocusNode.unfocus();
                                _emailFocusNode.unfocus();
                                if (formKey.currentState!.validate()) {
                                  final User user = User(
                                    name: nameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                  await Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .register(user)
                                      .then((value) {
                                    if (value.statusCode ==
                                        HttpStatus.created) {
                                      widget.onRegister();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .successRegister)),
                                      );
                                    } else {
                                      var decode = jsonDecode(value.body);
                                      String message =
                                          decode["message"].toString();
                                      String snackbarMessage = "";
                                      if (message
                                          .contains("Email is already taken")) {
                                        snackbarMessage =
                                            AppLocalizations.of(context)!.emailTaken;
                                      } else if (message
                                          .contains("must be a valid email")) {
                                        snackbarMessage = AppLocalizations.of(context)!.emailInvalid;
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "${AppLocalizations.of(context)!.registerFailed} $snackbarMessage.")),
                                      );
                                    }
                                  });
                                }
                              },
                              child: Text(
                                  AppLocalizations.of(context)!.registerText),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize:
                                    const Size.fromWidth(double.maxFinite),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () {
                                _nameFocusNode.unfocus();
                                _passwordFocusNode.unfocus();
                                _emailFocusNode.unfocus();
                                widget.onLogin();
                              },
                              child:
                                  Text(AppLocalizations.of(context)!.loginText),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
