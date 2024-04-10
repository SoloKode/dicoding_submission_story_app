import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_story_app/model/user_login.dart';
import 'package:submission_story_app/provider/auth_provider.dart';
import 'package:submission_story_app/utils/common.dart';

class LoginScreen extends StatefulWidget {
  final Function() onLogin;
  final Function() onRegister;
  const LoginScreen(
      {super.key, required this.onLogin, required this.onRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
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
                    AppLocalizations.of(context)!.loginText,
                    minFontSize: 25,
                    style: const TextStyle(
                        fontSize: 25, color: Colors.black87, height: 0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
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
                      if (value.length < 8){
                        return AppLocalizations.of(context)!.minPasswordValidator;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  context.watch<AuthProvider>().isLoadingLogin
                      ? Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                              child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              Text(AppLocalizations.of(context)!.logginIn)
                            ],
                          )),
                        )
                      : Column(
                          children: [
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
                              onPressed: () async {
                                _emailFocusNode.unfocus();
                                _passwordFocusNode.unfocus();
                                if (formKey.currentState!.validate()) {
                                  final scaffoldMessenger =
                                      ScaffoldMessenger.of(context);
                                  final UserLogin user = UserLogin(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                  final authRead = context.read<AuthProvider>();
                                  await authRead
                                      .login(user)
                                      .then((value) async {
                                    if (value) {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(AppLocalizations.of(context)!.successLogin),
                                        ),
                                      );
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      widget.onLogin();
                                    } else {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!.invalidLogin),
                                        ),
                                      );
                                    }
                                  }).onError((error, stackTrace) {
                                    String err = error.toString();
                                    if (err.contains("Failed host lookup")) {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(AppLocalizations.of(context)!.noNetwork),
                                        ),
                                      );
                                    } else {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(error.toString()),
                                        ),
                                      );
                                    }
                                  });
                                }
                              },
                              child: Text(AppLocalizations.of(context)!.loginText),
                            ),
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
                              onPressed: () {
                                _emailFocusNode.unfocus();
                                _passwordFocusNode.unfocus();
                                widget.onRegister();
                              },
                              child: Text(AppLocalizations.of(context)!.registerText),
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
