import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'upload_response.g.dart';

@JsonSerializable()
class UploadResponse {
  bool error;
  String message;

  UploadResponse({
    required this.error,
    required this.message,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadResponseFromJson(json);

  factory UploadResponse.fromJsonString(String source) =>
      UploadResponse.fromJson(json.decode(source));

  Map<String, dynamic> toJson() => _$UploadResponseToJson(this);
}
