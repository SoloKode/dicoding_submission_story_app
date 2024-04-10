import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:submission_story_app/model/list_story.dart';
import 'package:submission_story_app/utils/common.dart';

class StoryDetail extends StatefulWidget {
  final ListStory story;
  const StoryDetail({super.key, required this.story});

  @override
  State<StoryDetail> createState() => _StoryDetailState();
}

class _StoryDetailState extends State<StoryDetail> {
  late final storyLocation;
  final Set<Marker> markers = {};
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();

    if (widget.story.lat != null && widget.story.lon != null) {
      storyLocation = LatLng(widget.story.lat!, widget.story.lon!);
    } else {
      storyLocation = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (mapController != null) {
      mapController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.storyBy(widget.story.name)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Hero(
                    tag: widget.story.photoUrl.toString(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: widget.story.photoUrl.contains("https")
                            ? Image.network(
                                widget.story.photoUrl,
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
                                File(widget.story.photoUrl.toString()),
                                fit: BoxFit.cover,
                              )
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.calendar_month_outlined),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        DateFormat('yyyy-MM-dd')
                            .format(widget.story.createdAt)
                            .toString(),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.timer_outlined),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        DateFormat('HH:mm:ss')
                            .format(widget.story.createdAt)
                            .toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.description,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.story.description,
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Text("Writer's Location",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            if (storyLocation != null)
              Padding(
                padding: const EdgeInsets.only(
                    left: 22.0, right: 22.0, bottom: 22.0),
                child: Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      color: Colors.grey,
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: GoogleMap(
                          mapToolbarEnabled: false,
                          markers: markers,
                          onMapCreated: (controller) async {
                            List<Placemark> placemarks =
                                await placemarkFromCoordinates(
                                    widget.story.lat!, widget.story.lon!);
                            final marker = Marker(
                              infoWindow: InfoWindow(
                                  title:
                                      "${placemarks.first.administrativeArea}, ${placemarks.first.subAdministrativeArea}"),
                              markerId: const MarkerId("dicoding"),
                              position: storyLocation,
                              onTap: () {
                                mapController!.animateCamera(
                                  CameraUpdate.newLatLngZoom(storyLocation, 20),
                                );
                              },
                            );

                            setState(() {
                              mapController = controller;
                              markers.add(marker);
                            });
                          },
                          initialCameraPosition: CameraPosition(
                            zoom: 20,
                            target:
                                LatLng(widget.story.lat!, widget.story.lon!),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text("Unavailable Location",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}
