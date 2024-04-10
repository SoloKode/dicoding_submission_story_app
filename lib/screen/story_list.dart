import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_story_app/db/auth_repository.dart';
import 'package:submission_story_app/model/list_story.dart';
import 'package:submission_story_app/provider/api_provider.dart';
import 'package:submission_story_app/provider/auth_provider.dart';
import 'package:submission_story_app/utils/common.dart';
import 'package:submission_story_app/utils/result_state.dart';
import 'package:submission_story_app/widget/build_story_list.dart';
import 'package:submission_story_app/widget/flag_icon_widget.dart';

class StoryList extends StatefulWidget {
  final Function(ListStory) onTapped;
  final Function() cleanPublishStory;
  final Function() onLogout;
  final Function() addStory;
  final ListStory? publishedStory;
  const StoryList({
    super.key,
    required this.onTapped,
    required this.onLogout,
    required this.addStory,
    this.publishedStory,
    required this.cleanPublishStory,
  });

  @override
  State<StoryList> createState() => _StoryListState();
}

class _StoryListState extends State<StoryList> {
  final ScrollController scrollController = ScrollController();
  final ScrollController sliverScrollController = ScrollController();
  late List<ListStory> listStory;

  @override
  void initState() {
    super.initState();

    final apiProvider = context.read<ApiProvider>();
    scrollController.addListener(() {
      sliverScrollController.jumpTo(scrollController.position.pixels);

      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        if (apiProvider.pageItems != null) {
          apiProvider.fetchStories();
        }
      }
    });

    Future.microtask(() async => apiProvider.fetchStories());
  }

  @override
  void dispose() {
    scrollController.dispose();
    sliverScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authWatch = context.watch<AuthProvider>();
    final authRead = context.read<AuthProvider>();
    final apiRead = context.read<ApiProvider>();

    return Scaffold(
      body: NestedScrollView(
          controller: sliverScrollController,
          headerSliverBuilder: (_, __) {
            return [
              SliverAppBar(
                backgroundColor: Colors.orangeAccent,
                pinned: true,
                expandedHeight: 150,
                toolbarHeight: 65,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/books.jpg',
                    fit: BoxFit.fitWidth,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.storyApp,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const FlagIconWidget(),
                          IconButton(
                            onPressed: () async {
                              final result = await authRead.logout();
                              if (result) widget.onLogout();
                            },
                            tooltip: AppLocalizations.of(context)!.logoutText,
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 3.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  titlePadding: const EdgeInsets.only(left: 16),
                ),
              ),
            ];
          },
          body: authWatch.isLoadingLogout
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(AppLocalizations.of(context)!.loggingOut),
                      )
                    ],
                  ),
                )
              : Consumer<ApiProvider>(
                  builder: (context, value, child) {
                    if (value.state == ResultState.loading &&
                        value.pageItems == 1) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (value.state == ResultState.hasData) {
                      listStory = value.result;
                      if (widget.publishedStory == null) {
                        print("Published story is Null");
                      } else {
                        print("Published story Exists");
                        listStory.insert(0, widget.publishedStory!);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.cleanPublishStory();
                        });
                      }
                      return Column(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(),
                          ),
                          Flexible(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: const Size.fromWidth(
                                                double.maxFinite),
                                            backgroundColor: value.loc == 0
                                                ? Colors.orangeAccent
                                                : Colors.grey,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          onPressed: () async {
                                            await AuthRepository().setFilter(0);
                                            apiRead.resetData();
                                            apiRead.fetchStories();
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .mix)),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: const Size.fromWidth(
                                                double.maxFinite),
                                            backgroundColor: value.loc == 1
                                                ? Colors.orangeAccent
                                                : Colors.grey,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          onPressed: () async {
                                            await AuthRepository().setFilter(1);
                                            apiRead.resetData();
                                            apiRead.fetchStories();
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .locationOnly)),
                                    ),
                                  ],
                                ),
                              )),
                          Flexible(
                            flex: 30,
                            child: ListView.builder(
                              controller: scrollController,
                              shrinkWrap: true,
                              itemCount: listStory.length +
                                  (value.pageItems != null ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == listStory.length &&
                                    value.pageItems != null) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                var story = value.result[index];
                                return buildStoryList(
                                    context, story, widget.onTapped);
                              },
                            ),
                          ),
                        ],
                      );
                    } else if (value.state == ResultState.noData) {
                      return Center(
                        child: Column(
                          children: [
                            Text(AppLocalizations.of(context)!.noData),
                            const SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Provider.of<ApiProvider>(context, listen: false)
                                    .fetchStories();
                              },
                              child:
                                  Text(AppLocalizations.of(context)!.tryAgain),
                            ),
                          ],
                        ),
                      );
                    } else if (value.state == ResultState.error) {
                      if (value.message.contains('No internet connection') ||
                          value.message.contains('ClientException')) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context)!.internetIssue),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Provider.of<ApiProvider>(context,
                                          listen: false)
                                      .fetchStories();
                                },
                                child: Text(
                                    AppLocalizations.of(context)!.tryAgain),
                              ),
                            ],
                          ),
                        );
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(value.message),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Provider.of<ApiProvider>(context, listen: false)
                                    .fetchStories();
                              },
                              child:
                                  Text(AppLocalizations.of(context)!.tryAgain),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(
                        child: Material(
                          child: Text(''),
                        ),
                      );
                    }
                  },
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.addStory();
        },
        tooltip: AppLocalizations.of(context)!.addNewStory,
        child: authWatch.isLoadingLogout
            ? const CircularProgressIndicator(
                color: Colors.blue,
              )
            : const Icon(Icons.add_circle_outline_outlined),
      ),
    );
  }
}
