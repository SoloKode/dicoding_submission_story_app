import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:submission_story_app/model/list_story.dart';
import 'package:submission_story_app/utils/common.dart';

Widget buildStoryList(
    BuildContext context, ListStory story, Function onTapped) {
  return Row(
    children: [
      Flexible(
        flex: 8,
        child: GestureDetector(
          onTap: () {
            onTapped(story);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 125,
                  height: 125,
                  child: Hero(
                    tag: story.photoUrl.toString(),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: story.photoUrl.contains("https")
                            ? Image.network(
                                story.photoUrl,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      error.toString().contains('Socket')
                                          ? AppLocalizations.of(context)!
                                              .internetIssue
                                          : '${AppLocalizations.of(context)!.issue} $error',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                },
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(story.photoUrl.toString()),
                                fit: BoxFit.cover,
                              )),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                SizedBox(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                              DateFormat('yyyy-MM-dd')
                                  .format(story.createdAt)
                                  .toString(),
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                              DateFormat('HH:mm:ss')
                                  .format(story.createdAt)
                                  .toString(),
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
