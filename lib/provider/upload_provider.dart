import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:submission_story_app/api/api_service.dart';
import 'package:submission_story_app/db/auth_repository.dart';
import 'package:submission_story_app/model/upload_response.dart';
import 'package:image/image.dart' as img;

class UploadProvider extends ChangeNotifier {
  bool isUploading = false;
  String message = "";
  UploadResponse? uploadResponse;

  Future<void> upload(
    List<int> bytes,
    String fileName,
    String description,
    LatLng? position
  ) async {
    isUploading = true;
    notifyListeners();
    final userState = await AuthRepository().getUser();
    try {
      message = "";
      uploadResponse = null;
      notifyListeners();
      uploadResponse = await ApiService(client: Client()).uploadStory(
          bytes, fileName, description, userState!.token, position);
      message = uploadResponse?.message ?? "success";
      isUploading = false;
      notifyListeners();
    } catch (e) {
      isUploading = false;
      message = e.toString();
      notifyListeners();
    }
  }

  Future<List<int>> compressImage(List<int> bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;
    final img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;
    int compressQuality = 100;
    int length = imageLength;
    List<int> newByte = [];
    do {
      ///
      compressQuality -= 10;
      newByte = img.encodeJpg(
        image,
        quality: compressQuality,
      );
      length = newByte.length;
    } while (length > 1000000);
    return newByte;
  }
}
