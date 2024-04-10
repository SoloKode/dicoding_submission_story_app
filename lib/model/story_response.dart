import 'package:json_annotation/json_annotation.dart';
import 'package:submission_story_app/model/list_story.dart';

part 'story_response.g.dart';

@JsonSerializable()
class StoryResponse {
    bool error;
    String message;
    @JsonKey(name: "listStory")
    List<ListStory> listStory;

    StoryResponse({
        required this.error,
        required this.message,
        required this.listStory,
    });

    factory StoryResponse.fromJson(Map<String, dynamic> json) => _$StoryResponseFromJson(json);

    Map<String, dynamic> toJson() => _$StoryResponseToJson(this);
}

