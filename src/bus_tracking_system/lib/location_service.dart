import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:background_locator_2/location_dto.dart';
import 'package:path_provider/path_provider.dart';

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  static const String isolateName = 'LocatorIsolate';

  int _count = -1;

  Future<void> init(Map<dynamic, dynamic> params) async {
    print("***********Init callback handler");
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    print("$_count");
    await setLogLabel("start");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    print("***********Dispose callback handler");
    print("$_count");
    await setLogLabel("end");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    print('$_count location in dart: ${locationDto.toString()}');
    await setLogPosition(_count, locationDto);
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto.toJson());
    _count++;

    print(locationDto.latitude);
  }

  static Future<void> setLogLabel(String label) async {
    final date = DateTime.now();
    await writeToLogFile(
        '------------\n$label: ${formatDateLog(date)}\n------------\n');
  }

  static Future<void> setLogPosition(int count, LocationDto data) async {
    final date = DateTime.now();
    await writeToLogFile(
        '$count : ${formatDateLog(date)} --> ${formatLog(data)} --- isMocked: ${data.isMocked}\n');
  }

  static double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  static String formatDateLog(DateTime date) {
    return "${date.hour}:${date.minute}:${date.second}";
  }

  static String formatLog(LocationDto locationDto) {
    print(locationDto.latitude);
    return "${dp(locationDto.latitude, 4)} ${dp(locationDto.longitude, 4)}";
  }

  static Future<void> writeToLogFile(String log) async {
    final file = await _getTempLogFile();
    await file.writeAsString(log, mode: FileMode.append);
  }

  static Future<String> readLogFile() async {
    final file = await _getTempLogFile();
    return file.readAsString();
  }

  static Future<File> _getTempLogFile() async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/log.txt');
    if (!await file.exists()) {
      print(file);
      await file.writeAsString('');
    }
    return file;
  }

  static Future<void> clearLogFile() async {
    final file = await _getTempLogFile();
    await file.writeAsString('');
  }
}
