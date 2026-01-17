// lib/core/models/journal_entry.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String mood;
  final String note;
  final DateTime timestamp;
  final String stressLevel;

  JournalEntry({
    required this.id,
    required this.mood,
    required this.note,
    required this.timestamp,
    required this.stressLevel,
  });

  // Digunakan untuk mengirim data ke Firestore (Create/Update)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood,
      'note': note,
      // Firestore lebih baik menyimpan sebagai Timestamp asli daripada String
      'timestamp': Timestamp.fromDate(timestamp), 
      'stressLevel': stressLevel,
    };
  }

  // Digunakan untuk mengambil data dari Firestore (Read)
  factory JournalEntry.fromMap(Map<String, dynamic> map, String documentId) {
    return JournalEntry(
      id: documentId, // Mengambil ID dari document Firestore
      mood: map['mood'] ?? '',
      note: map['note'] ?? '',
      // Menangani konversi dari Timestamp Firestore ke DateTime Dart
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      stressLevel: map['stressLevel'] ?? 'Relax',
    );
  }

  // Tetap pertahankan format JSON jika kamu menggunakannya untuk local storage/MQTT
  Map<String, dynamic> toJson() => {
        'id': id,
        'mood': mood,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
        'stressLevel': stressLevel,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'],
        mood: json['mood'],
        note: json['note'],
        timestamp: DateTime.parse(json['timestamp']),
        stressLevel: json['stressLevel'],
      );
}