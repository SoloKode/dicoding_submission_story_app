import 'dart:convert';
import 'dart:typed_data';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:submission_story_app/config/config.dart';
import 'package:submission_story_app/model/story_response.dart';
import 'package:submission_story_app/model/upload_response.dart';
import 'package:submission_story_app/model/user_login.dart';

import '../model/user.dart';

class ApiService {
  final http.Client client;
  ApiService({required this.client});

  Future<dynamic> userRegister(User user) async {
    const url = "${Config.baseURL}${Config.register}";
    final uri = Uri.parse(url);
    try {
      final response = await client.post(uri, body: user.toJson());
      return response;
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<dynamic> userLogin(UserLogin user) async {
    const url = "${Config.baseURL}${Config.login}";
    final uri = Uri.parse(url);
    try {
      final response = await client.post(uri, body: user.toJson());
      return response;
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<StoryResponse> getStories(String token,
      [int page = 1, int size = 5, int location = 0]) async {
    var url =
        "${Config.baseURL}${Config.stories}?page=$page&size=$size&location=$location";
    final uri = Uri.parse(url);
    try {
      final response = await client.get(
        uri,
        headers: <String, String>{'authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return StoryResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to load restaurant list: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<dynamic> uploadStory(
    List<int> bytes,
    String fileName,
    String description,
    String token,
    LatLng? position,
  ) async {
    const url = "${Config.baseURL}${Config.stories}";
    final uri = Uri.parse(url);
    late Map<String, String> fields;
    try {
      var request = http.MultipartRequest('POST', uri);
      final multiPartFile = http.MultipartFile.fromBytes(
        "photo",
        bytes,
        filename: fileName,
      );
      if (position == null) {
        fields = {
          "description": description,
        };
      } else {
        fields = {
          "description": description,
          "lat": position.latitude.toString(),
          "lon": position.longitude.toString()
        };
      }
      final Map<String, String> headers = {
        "Content-type": "multipart/form-data",
        "authorization": "Bearer $token"
      };
      request.files.add(multiPartFile);
      request.fields.addAll(fields);
      request.headers.addAll(headers);

      final http.StreamedResponse streamedResponse = await request.send();
      final int statusCode = streamedResponse.statusCode;

      final Uint8List responseList = await streamedResponse.stream.toBytes();
      final String responseData = String.fromCharCodes(responseList);
      if (statusCode == 201) {
        final UploadResponse uploadResponse = UploadResponse.fromJsonString(
          responseData,
        );
        return uploadResponse;
      } else {
        throw Exception("Upload file error");
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
