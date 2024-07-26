import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

BusData busDataFromJson(String str) => BusData.fromJson(json.decode(str));

String busDataToJson(BusData data) => json.encode(data.toJson());

class BusData {
  String routeNo;
  String college;
  List<String> route;
  String lat;
  String lng;
  String time;
  String originLat;
  String originLng;

  BusData(
      {required this.routeNo,
      required this.college,
      required this.route,
      required this.lat,
      required this.lng,
      required this.time,
      required this.originLat,
      required this.originLng});

  factory BusData.fromJson(Map<String, dynamic> json) => BusData(
        routeNo: json["RouteNo"],
        college: json["College"],
        route: List<String>.from(json["Route"].map((x) => x)),
        lat: json["lat"],
        lng: json["lng"],
        time: json["time"],
        originLat: json["originLat"],
        originLng: json["originLng"],
      );

  Map<String, dynamic> toJson() => {
        "RouteNo": routeNo,
        "College": college,
        "Route": List<dynamic>.from(route.map((x) => x)),
        "lat": lat,
        "lng": lng,
        "time": time,
        "originLat": originLat,
        "originLng": originLng
      };

  factory BusData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BusData(
        routeNo: data['RouteNo'],
        college: data['College'],
        route: List<String>.from(data['Route'].map((x) => x)),
        lat: data['lat'],
        lng: data['lng'],
        time: data["time"] ?? "",
        originLat: data["originLat"],
        originLng: data["originLng"]);
  }

  Map<String, dynamic> toFirestore() => {
        "RouteNo": routeNo,
        "College": college,
        "Route": List<dynamic>.from(route.map((x) => x)),
        "lat": lat,
        "lng": lng,
        "time": time,
        "originLat": originLat,
        "originLng": originLng
      };
}
