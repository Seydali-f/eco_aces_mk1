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
  String esp32Ip = '10.65.97.208'; // Default ESP32 AP IP, user can change this
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
  int peopleDetected = 6;

  // Navigation
  int currentTab = 0;

  // Aux systems
  bool headlightOn = false;
  bool cameraPowerOn = false;
  bool warningHornOn = false;

  String currentCommand = 'STOPPED';
  List<LogEntry> logs = [];
  List<AlertEntry> alerts = [];

  // History (last 60 seconds)
  List<double> tempHistory = List.filled(60, 0.0, growable: true);
  List<double> gasHistory = List.filled(60, 0.0, growable: true);

  int get activeAlertsCount => alerts.length;

  Timer? _telemetryTimer;

  String weatherTemp = 'Loading...';
  String weatherDesc = 'Fetching weather';
  IconData weatherIcon = Icons.cloud;

  RoverState() {
    _startTelemetryLoop();
    _populateInitialLogs();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // 1. Get location from IP
      final geoRes = await http.get(Uri.parse('https://get.geojs.io/v1/ip/geo.json'));
      if (geoRes.statusCode == 200) {
        final geoData = json.decode(geoRes.body);
        final lat = geoData['latitude'];
        final lon = geoData['longitude'];

        // 2. Get weather from Open-Meteo
        final weatherRes = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true'));
        if (weatherRes.statusCode == 200) {
          final weatherData = json.decode(weatherRes.body);
          final current = weatherData['current_weather'];
          
          double temp = current['temperature'];
          int weatherCode = current['weathercode'];
          
          weatherTemp = '${temp.toStringAsFixed(1)}°C';
          
          // Decode WMO weather code (simplified)
          if (weatherCode == 0) { weatherDesc = 'Clear sky'; weatherIcon = Icons.wb_sunny; }
          else if (weatherCode <= 3) { weatherDesc = 'Partly cloudy'; weatherIcon = Icons.cloud_queue; }
          else if (weatherCode <= 48) { weatherDesc = 'Foggy'; weatherIcon = Icons.foggy; }
          else if (weatherCode <= 57) { weatherDesc = 'Drizzle'; weatherIcon = Icons.grain; }
          else if (weatherCode <= 67) { weatherDesc = 'Rain'; weatherIcon = Icons.water_drop; }
          else if (weatherCode <= 77) { weatherDesc = 'Snow'; weatherIcon = Icons.ac_unit; }
          else if (weatherCode <= 82) { weatherDesc = 'Showers'; weatherIcon = Icons.umbrella; }
          else { weatherDesc = 'Thunderstorm'; weatherIcon = Icons.flash_on; }
          
          notifyListeners();
        }
      }
    } catch (e) {
      weatherTemp = '--°C';
      weatherDesc = 'Weather offline';
      notifyListeners();
    }
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
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/proxy_sensors?ip=$esp32Ip')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          temperature = (data['temperature'] ?? temperature).toDouble();
          humidity = (data['humidity'] ?? humidity).toDouble();
          ch4Level = (data['gasRaw'] ?? ch4Level).toDouble();
          // coPpm and battery are not provided by this ESP32, keep them as is or reset
          
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
    
    // Update history
    tempHistory.removeAt(0);
    tempHistory.add(temperature);
    gasHistory.removeAt(0);
    gasHistory.add(ch4Level);
    
    notifyListeners();
  }

  void toggleAuxSystem(String system) async {
    bool newState = false;
    switch (system) {
      case 'HEADLIGHT':
        headlightOn = !headlightOn;
        newState = headlightOn;
        break;
      case 'CAMERA':
        cameraPowerOn = !cameraPowerOn;
        newState = cameraPowerOn;
        try {
          if (newState) {
            await http.get(Uri.parse('http://127.0.0.1:5000/start_camera')).timeout(const Duration(seconds: 2));
          } else {
            await http.get(Uri.parse('http://127.0.0.1:5000/stop_camera')).timeout(const Duration(seconds: 2));
          }
        } catch (e) {
          debugPrint("Failed to toggle AI camera backend: $e");
        }
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
    String c = 'S';
    if (commandName == 'FORWARD') c = 'F';
    if (commandName == 'BACKWARD') c = 'B';
    if (commandName == 'TURN LEFT') c = 'L';
    if (commandName == 'TURN RIGHT') c = 'R';
    if (commandName == 'FORWARD LEFT') c = 'L'; // Assuming turn left handles this
    if (commandName == 'FORWARD RIGHT') c = 'R';

    _addLog(commandName, 'Sent: ?go=$c');
    
    try {
      await http.get(Uri.parse('http://127.0.0.1:5000/proxy_action?ip=$esp32Ip&go=$c')).timeout(const Duration(seconds: 1));
    } catch (e) {}
  }

  Future<void> stopRover() async {
    currentCommand = 'STOPPED';
    _addLog('STOP', 'Sent: ?go=S');
    notifyListeners();
    try {
      await http.get(Uri.parse('http://127.0.0.1:5000/proxy_action?ip=$esp32Ip&go=S')).timeout(const Duration(seconds: 1));
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
