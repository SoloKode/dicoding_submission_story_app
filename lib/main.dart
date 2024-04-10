import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:submission_story_app/api/api_service.dart';
import 'package:submission_story_app/db/auth_repository.dart';
import 'package:submission_story_app/provider/api_provider.dart';
import 'package:submission_story_app/provider/auth_provider.dart';
import 'package:submission_story_app/provider/camera_provider.dart';
import 'package:submission_story_app/provider/localization_provider.dart';
import 'package:submission_story_app/provider/upload_provider.dart';
import 'package:submission_story_app/router/router_delegate.dart';
import 'package:submission_story_app/utils/common.dart';

void main() {
  runApp(const MyApp());
}

/// The main app.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyRouterDelegate myRouterDelegate;
  late AuthProvider authProvider;
  late CameraProvider cameraProvider;
  late UploadProvider uploadProvider;
  late LocalizationProvider localizationProvider;
  late ApiProvider apiProvider;
  @override
  void initState() {
    super.initState();
    final authRepository = AuthRepository();
    authProvider = AuthProvider(authRepository);
    myRouterDelegate = MyRouterDelegate(authRepository);
    cameraProvider = CameraProvider();
    uploadProvider = UploadProvider();
    localizationProvider = LocalizationProvider(authRepository);
    apiProvider = ApiProvider(authRepository, ApiService(client: Client()));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => localizationProvider),
        ChangeNotifierProvider(create: (context) => authProvider),
        ChangeNotifierProvider(create: (context) => cameraProvider),
        ChangeNotifierProvider(create: (context) => uploadProvider),
        ChangeNotifierProvider(create: (context) => apiProvider),
      ],
      builder: (context, child) {
        return Consumer<LocalizationProvider>(
          builder: (context, value, child) {
            if (value.locale == const Locale("load")) {
              return const MaterialApp(
                home: LoadingScreen(),
              );
            } else {
              return MaterialApp(
                locale: value.locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                title: 'Story App',
                home: Router(
                  routerDelegate: myRouterDelegate,
                  backButtonDispatcher: RootBackButtonDispatcher(),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: const Center(
              child: SizedBox(
                  width: 50, height: 50, child: CircularProgressIndicator()))),
    );
  }
}
