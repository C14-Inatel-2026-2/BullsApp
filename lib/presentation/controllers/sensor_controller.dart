import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/repositories/sensor_repository.dart';
import '../../data/models/sensor_model.dart';


class SensorController extends ChangeNotifier {
  SensorController({SensorRepository? repository})
      : _repo = repository ?? SensorRepository();

  final SensorRepository _repo;

  List<SensorModel> sensors = [];
  StreamSubscription<List<SensorModel>>? _sensorsSub;

  void init() {
    _sensorsSub = _repo.sensorsStream.listen((list) {
      sensors = list;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sensorsSub?.cancel();
    super.dispose();
  }
}