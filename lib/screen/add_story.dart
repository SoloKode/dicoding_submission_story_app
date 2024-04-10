import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:submission_story_app/db/auth_repository.dart';
import 'package:submission_story_app/model/list_story.dart';
import 'package:submission_story_app/provider/camera_provider.dart';
import 'package:submission_story_app/provider/upload_provider.dart';
import 'package:submission_story_app/utils/common.dart';

class AddStory extends StatefulWidget {
  final Function(ListStory) setStory;
  const AddStory({super.key, required this.setStory});

  @override
  AddStoryState createState() => AddStoryState();
}

class AddStoryState extends State<AddStory> {
  final descriptionController = TextEditingController();
  final _descriptionFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  GoogleMapController? mapController;
  bool _isChecked = false;
  final jakarta = const LatLng(-6.121435, 106.774124);
  final Set<Marker> markers = {};
  LatLng? positionSelected;
  String? addressSelected;

  @override
  void dispose() {
    descriptionController.dispose();
    if (mapController != null) {
      mapController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addNewStory),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              context.watch<CameraProvider>().imagePath == null
                  ? Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 100,
                            ),
                            Text(
                              AppLocalizations.of(context)!.uploadPhoto,
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.blueGrey, width: 2),
                          ),
                          child: _showImage()),
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () => _onGalleryView(),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(Icons.photo),
                                  Text(
                                      AppLocalizations.of(context)!.galleryText,
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () => _onCameraView(),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(Icons.camera_alt),
                                  Text(AppLocalizations.of(context)!.cameraText,
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Form(
                      key: formKey,
                      child: TextFormField(
                        focusNode: _descriptionFocusNode,
                        controller: descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: AppLocalizations.of(context)!.description,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .descriptionValidator;
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 10),
                      child: CheckboxListTile(
                        title:
                            Text(AppLocalizations.of(context)!.shareLocation),
                        value: _isChecked,
                        onChanged: (newValue) {
                          setState(() {
                            _isChecked = newValue!;
                          });
                        },
                      ),
                    ),
                    if (_isChecked)
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius as needed
                            child: SizedBox(
                              height: 300,
                              child: GoogleMap(
                                mapToolbarEnabled: false,
                                onTap: (location) async {
                                  List<Placemark> placemarks =
                                      await placemarkFromCoordinates(
                                    location.latitude,
                                    location.longitude,
                                  );
                                  setState(() {
                                    markers.add(Marker(
                                      infoWindow: InfoWindow(title : "${placemarks.first.administrativeArea}, ${placemarks.first.subAdministrativeArea}"),
                                        markerId: const MarkerId("tapLocation"),
                                        position: location,
                                        onTap: () {
                                          mapController!.animateCamera(
                                            CameraUpdate.newLatLngZoom(
                                                location, 10),
                                          );
                                        }));
                                    positionSelected = location;
                                  });
                                },
                                markers: markers,
                                onMapCreated: (controller) {
                                  setState(() {
                                    mapController = controller;
                                  });
                                },
                                initialCameraPosition: CameraPosition(
                                  target: jakarta,
                                  zoom: 5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size.fromWidth(double.maxFinite),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          _descriptionFocusNode.unfocus();
                          if (formKey.currentState!.validate()) {
                            _onUpload();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              context.watch<UploadProvider>().isUploading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Column(
                                      children: [
                                        const Icon(Icons.upload),
                                        Text(
                                            AppLocalizations.of(context)!
                                                .uploadText,
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _onUpload() async {
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    final uploadProvider = context.read<UploadProvider>();
    final provider = context.read<CameraProvider>();

    final imagePath = provider.imagePath;
    final imageFile = provider.imageFile;

    if (imagePath == null || imageFile == null) return;

    final fileName = imageFile.name;
    final bytes = await imageFile.readAsBytes();
    final newBytes = await uploadProvider.compressImage(bytes);
    final userState = await AuthRepository().getUser();
    
    await uploadProvider.upload(
        newBytes, fileName, descriptionController.text, positionSelected);

    if (uploadProvider.uploadResponse != null) {
      provider.setImageFile(null);
      provider.setImagePath(null);
    }

    scaffoldMessengerState.showSnackBar(
      SnackBar(content: Text(uploadProvider.message)),
    );
    if(uploadProvider.message.contains("success")){
      widget.setStory(ListStory(
              id: "published",
              name: userState!.name,
              description: descriptionController.text,
              photoUrl: imagePath,
              createdAt: DateTime.now(),
              lat: positionSelected?.latitude != null ? positionSelected!.latitude : null,
              lon: positionSelected?.longitude != null ? positionSelected!.longitude : null));
    }
  }

  _onGalleryView() async {
    final provider = context.read<CameraProvider>();

    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    final isWindows = defaultTargetPlatform == TargetPlatform.windows;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (isMacOS || isLinux || isWindows || isIOS) return;

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onCameraView() async {
    final provider = context.read<CameraProvider>();

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isNotMobile = !(isAndroid || isiOS);
    if (isNotMobile) return;

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  Widget _showImage() {
    final imagePath = context.read<CameraProvider>().imagePath;
    return kIsWeb
        ? Image.network(
            imagePath.toString(),
            fit: BoxFit.cover,
          )
        : Image.file(
            File(imagePath.toString()),
            fit: BoxFit.cover,
          );
  }
}
