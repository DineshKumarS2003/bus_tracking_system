import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/tracking_screen_controller.dart';

class TrackingScreenView extends GetView<TrackingScreenController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackingScreenController>(builder: (controller) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'Tracking',
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: controller.polylines.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Getting Your Location Please Wait.....'),
                      SizedBox(
                        height: 20,
                      ),
                      CircularProgressIndicator(
                        color: Colors.blueAccent,
                      )
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                        child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: controller.destinationLocation,
                        zoom: 11,
                      ),
                      markers: controller.markers.toSet(),
                      polylines: controller.polylines,
                      onMapCreated: (GoogleMapController mapController) {
                        controller.mapController = mapController;
                      },
                    )),
                    /*  Expanded(
                        child: GoogleMap(
                          mapType: MapType.normal,
                          markers: controller.markers.toSet(),
                          polylines: controller.polylines,
                          initialCameraPosition: CameraPosition(
                            target: controller.destinationLocation,
                            zoom: 10.7746,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            //controller;
                          },
                        ),
                      ),*/
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            int.parse(controller.travelTime.split(".").first) >=
                                    60
                                ? 'Time: ${(int.parse(controller.travelTime.split(".").first) / 60).toString().split(".").first} Hrs ${int.parse(controller.travelTime.split(".").first) % 60} Mins '
                                : 'Time: ${controller.travelTime.split(".").first} Mins ',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Distance: ${controller.distance} Km',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Latitude: ${controller.destinationLocation.latitude}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Longitude: ${controller.destinationLocation.longitude}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ));
    });
  }

  Future<BitmapDescriptor> getResizedAssetIcon(String assetPath,
      {int width = 110}) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    ByteData? byteData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
