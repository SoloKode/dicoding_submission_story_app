import 'package:flutter/material.dart';
import 'package:submission_story_app/api/api_service.dart';
import 'package:submission_story_app/db/auth_repository.dart';
import 'package:submission_story_app/model/list_story.dart';
import 'package:submission_story_app/utils/result_state.dart';

class ApiProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final ApiService apiService;
  ApiProvider(this.authRepository, this.apiService);

  final List<ListStory> _listStoryResult = [];
  ResultState? _state;
  String _message = '';
  String get message => _message;
  List<ListStory> get result => _listStoryResult;
  ResultState? get state => _state;
  
  int? pageItems = 1;
  int sizeItems = 10;
  late int loc;

  Future<void> fetchStories() async {
    loc = await AuthRepository().getFilter();
    final userState = await authRepository.getUser();
    try {
      if (pageItems == 1) {
        _state = ResultState.loading;
        notifyListeners();
      }
      await apiService
          .getStories(userState!.token, pageItems!, sizeItems, loc)
          .then((value) {
        if (value.listStory.isEmpty) {
          _state = ResultState.noData;
          _message = 'Empty Data';
        } else {
          _message = 'has Data';
          _state = ResultState.hasData;
          _listStoryResult.addAll(value.listStory);
          if (value.listStory.length < sizeItems) {
            pageItems = null;
          } else {
            pageItems = pageItems! + 1;
          }
        }
        notifyListeners();
      }).catchError((e) {
        _state = ResultState.error;
        _message = e.toString();
        notifyListeners();
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      _state = ResultState.error;
      _message = 'Error --> $e';
      notifyListeners();
    }
  }

  void resetData() {
    _listStoryResult.clear();
    pageItems = 1;
    notifyListeners();
  }
  void addPublishedStory(ListStory story) {
    print(story);
    _listStoryResult.insert(0, story);
    notifyListeners();
  }
}
