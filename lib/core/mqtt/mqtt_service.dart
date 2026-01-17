import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';

// MENGATASI ERROR: Menggunakan server_client agar bisa jalan di Android/iOS
import 'package:mqtt_client/mqtt_server_client.dart'; 

import '../models/sensor_data.dart';
import '../logic/stress_logic.dart';

class MqttService with ChangeNotifier {
  MqttService() {
    print("DEBUG: MqttService diinisialisasi untuk Android/Mobile");
  }

  // Gunakan MqttServerClient (bukan Browser) untuk Android
  late MqttServerClient client;
  SensorData? latest;

  Future<void> connect() async {
    const String host = '6edfad2acaf04ec9aae0a1e285878cb8.s1.eu.hivemq.cloud';
    
    // Inisialisasi Server Client
    client = MqttServerClient.withPort(
      host, 
      'flutter_mobile_client_${DateTime.now().millisecondsSinceEpoch}',
      8883, // Port standar HiveMQ Cloud (SSL)
    );

    // Konfigurasi Keamanan & Protokol
    client.secure = true; // WAJIB true untuk HiveMQ Cloud
    client.setProtocolV311();
    client.keepAlivePeriod = 60;
    client.logging(on: true);

    // Konfigurasi Pesan Koneksi
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client.clientIdentifier)
        .authenticateAs(
          'calmreminder', 
          'Calmreminder123', 
        )
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMessage;

    try {
      debugPrint("⏳ Mencoba menyambungkan ke HiveMQ Cloud (Mobile)...");
      await client.connect();
      debugPrint("✅ MQTT Terhubung!");
    } catch (e) {
      debugPrint("❌ Gagal Terhubung: $e");
      client.disconnect();
      return;
    }

    // Subscribe
    client.subscribe('sensor/data/calmreminder', MqttQos.atMostOnce);

    // Listen Data
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> events) {
      final MqttPublishMessage recMess = events[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      debugPrint("📥 Pesan Diterima: $payload");

      try {
        final Map<String, dynamic> jsonData = jsonDecode(payload);
        SensorData data = SensorData.fromJson(jsonData);

        final stress = StressLogic.analyze(
          heartRate: data.heartRate,
          temp: data.temp,
          accX: data.accX,
          accY: data.accY,
          accZ: data.accZ,
        );

        latest = data.copyWithStress(stress);
        notifyListeners();
        
      } catch (e) {
        debugPrint("❌ Error Parsing JSON: $e");
      }
    });
  }

  void disconnect() {
    client.disconnect();
    debugPrint("🔌 MQTT Terputus");
  }
}