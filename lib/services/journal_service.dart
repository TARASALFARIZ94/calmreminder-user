// lib/services/journal_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/models/journal_entry.dart';

class JournalService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'journals';

  // Helper untuk mendapatkan UID User yang sedang login
  static String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

  // --- CREATE ---
  static Future<void> saveEntry(JournalEntry entry) async {
    try {
      await _db.collection(_collection).doc(entry.id).set({
        ...entry.toMap(),
        'userId': _userId, // Menandai bahwa jurnal ini milik user A
      });
    } catch (e) {
      rethrow;
    }
  }

  // --- READ ---
  static Future<List<JournalEntry>> getEntries() async {
    try {
      // Mengambil data jurnal HANYA milik user yang sedang login
      final snapshot = await _db
          .collection(_collection)
          .where('userId', isEqualTo: _userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => JournalEntry.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching journals: $e");
      return [];
    }
  }

  // --- UPDATE ---
  static Future<void> updateEntry(JournalEntry entry) async {
    try {
      await _db.collection(_collection).doc(entry.id).update(entry.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // --- DELETE ---

static Future<void> deleteEntry(String id) async {
  try {
    // Menghapus dokumen berdasarkan ID uniknya di Firestore
    await _db.collection(_collection).doc(id).delete();
  } catch (e) {
    print("Error deleting entry: $e");
    rethrow; 
  }
}
}