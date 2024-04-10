import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_story_app/db/auth_repository.dart';
import 'package:submission_story_app/model/list_story.dart';
import 'package:submission_story_app/provider/camera_provider.dart';
import 'package:submission_story_app/screen/add_story.dart';
import 'package:submission_story_app/screen/login_screen.dart';
import 'package:submission_story_app/screen/register_screens.dart';
import 'package:submission_story_app/screen/splash_screen.dart';
import 'package:submission_story_app/screen/story_detail.dart';
import 'package:submission_story_app/screen/story_list.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;

  MyRouterDelegate(this.authRepository)
      : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  final AuthRepository authRepository;
  ListStory? story;

  List<Page> historyStack = [];
  bool? isLoggedIn;
  bool isRegister = false;
  bool? addStory;
  ListStory? storyList;

  _init() async {
    await Future.delayed(const Duration(seconds: 3));
    isLoggedIn = await authRepository.isLoggedIn();
    if (isLoggedIn == true) {
      int sessionTime = await authRepository.getSessionTime();
      final currentTime = DateTime.now().toUtc().millisecondsSinceEpoch;
      if (currentTime - sessionTime > 3600000) {
        isLoggedIn = false;
        await authRepository.logout();
        await authRepository.deleteUser();
      }
    }
    notifyListeners();
  }

  void setListStory(ListStory story) {
    storyList = story;
    notifyListeners();
  }

  List<Page> get _splashStack => const [
        MaterialPage(
          key: ValueKey("Splash_Page"),
          child: SplashScreen(),
        ),
      ];
  List<Page> get _loggedOutStack => [
        MaterialPage(
          key: const ValueKey("Login_Page"),
          child: LoginScreen(
            onLogin: () {
              isLoggedIn = true;
              notifyListeners();
            },
            onRegister: () {
              isRegister = true;
              notifyListeners();
            },
          ),
        ),
        if (isRegister == true)
          MaterialPage(
            key: const ValueKey("Register_Page"),
            child: RegisterScreens(
              onRegister: () {
                isRegister = false;
                notifyListeners();
              },
              onLogin: () {
                isRegister = false;
                notifyListeners();
              },
            ),
          ),
      ];
  List<Page> get _loggedInStack => [
        MaterialPage(
          key: const ValueKey("Story_List_Page"),
          child: StoryList(
            onTapped: (ListStory st) {
              story = st;
              notifyListeners();
            },
            onLogout: () {
              isLoggedIn = false;
              notifyListeners();
            },
            addStory: () {
              addStory = true;
              notifyListeners();
            },
            publishedStory: storyList,
            cleanPublishStory: () {
              storyList = null;
              notifyListeners();
            },
          ),
        ),
        if (story != null)
          MaterialPage(
            key: ValueKey("Detail_${story!.id}"),
            child: StoryDetail(
              story: story!,
            ),
          ),
        if (addStory == true)
          MaterialPage(
              key: const ValueKey("Add_New_Story"),
              child: AddStory(
                setStory: setListStory,
              )),
      ];
  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      historyStack = _splashStack;
    } else if (isLoggedIn == true) {
      historyStack = _loggedInStack;
    } else {
      historyStack = _loggedOutStack;
    }
    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onPopPage: (route, result) {
        final cameraProvider = context.read<CameraProvider>();
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }
        cameraProvider.imagePath = null;
        cameraProvider.imageFile = null;
        isRegister = false;
        story = null;
        addStory = false;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async {
    /* Do Nothing */
  }
}
