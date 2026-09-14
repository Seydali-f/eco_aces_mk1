import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LogEntry {
  final DateTime time;
  final String command;
  final String result;
  LogEntry(this.time, this.command, this.result);
}

class AlertEntry {
  final DateTime time;
  final String level;
  final String message;
  AlertEntry(this.time, this.level, this.message);
}

class RoverState extends ChangeNotifier {
  // Config
  String esp32Ip = '192.168.4.1'; // Default ESP32 AP IP, user can change this
  bool isConnected = false;
  
  // Telemetry
  int battery = 0;
  double speed = 0.0;
  
  // Environment
  double temperature = 0.0;
  double humidity = 0.0;
  double ch4Level = 0.0;
  int coPpm = 0;
  
  // AI Detection
  int peopleDetected = 0;

  // Navigation
  int currentTab = 0;

  // Aux systems
  bool headlightOn = false;
  bool cameraPowerOn = false;
  bool warningHornOn = false;

  String currentCommand = 'STOPPED';
  List<LogEntry> logs = [];
  List<AlertEntry> alerts = [];

  int get activeAlertsCount => alerts.length;

  Timer? _telemetryTimer;

  RoverState() {
    _startTelemetryLoop();
    _populateInitialLogs();
  }

  void _populateInitialLogs() {
    alerts = [
      AlertEntry(DateTime.now(), 'CRITICAL', 'Awaiting ESP32 connection...'),
    ];
  }

  void _startTelemetryLoop() {
    _telemetryTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchSensors();
    });
  }

  Future<void> _fetchSensors() async {
    try {
      final response = await http.get(Uri.parse('http://$esp32Ip/sensor')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          temperature = (data['temp'] ?? temperature).toDouble();
          humidity = (data['hum'] ?? humidity).toDouble();
          ch4Level = (data['gas'] ?? ch4Level).toDouble();
          coPpm = (data['co'] ?? coPpm).toInt();
          battery = (data['bat'] ?? battery).toInt();
          
          if (!isConnected) {
            isConnected = true;
            _addLog('SYSTEM', 'Connected to ESP32');
            alerts.clear();
          }
        } catch (e) {
          // Fallback if not json
        }
      }
      isConnected = true;
    } catch (e) {
      if (isConnected) {
        isConnected = false;
        _addLog('SYSTEM', 'Connection lost');
      }
    }
    notifyListeners();
  }

  void toggleAuxSystem(String system) {
    bool newState = false;
    switch (system) {
      case 'HEADLIGHT':
        headlightOn = !headlightOn;
        newState = headlightOn;
        break;
      case 'CAMERA':
        cameraPowerOn = !cameraPowerOn;
        newState = cameraPowerOn;
        break;
      case 'WARNING_HORN':
        warningHornOn = !warningHornOn;
        newState = warningHornOn;
        break;
    }
    _addLog(system, newState ? 'ON' : 'OFF');
    notifyListeners();
  }

  void changeTab(int index) {
    currentTab = index;
    notifyListeners();
  }

  Future<void> sendCommand(String label, String commandName) async {
    currentCommand = commandName;
    notifyListeners();
    
    // Map commands to chars as per user request
    String c = 's';
    if (commandName == 'FORWARD') c = 'w';
    if (commandName == 'BACKWARD') c = 's';
    if (commandName == 'TURN LEFT') c = 'a';
    if (commandName == 'TURN RIGHT') c = 'd';
    if (commandName == 'FORWARD LEFT') c = 'q';
    if (commandName == 'FORWARD RIGHT') c = 'e';

    _addLog(commandName, 'Sent: ?c=$c');
    
    try {
      await http.get(Uri.parse('http://$esp32Ip/cmd?c=$c')).timeout(const Duration(seconds: 1));
    } catch (e) {}
  }

  Future<void> stopRover() async {
    currentCommand = 'STOPPED';
    _addLog('STOP', 'Sent: ?c=x');
    notifyListeners();
    try {
      await http.get(Uri.parse('http://$esp32Ip/cmd?c=x')).timeout(const Duration(seconds: 1));
    } catch (e) {}
  }

  Future<void> releaseCommand() async {
    await stopRover();
  }

  void _addLog(String command, String result) {
    logs.insert(0, LogEntry(DateTime.now(), command, result));
    if (logs.length > 50) logs.removeLast();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }
}
