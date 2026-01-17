// lib/pages/user/mood_journal_page.dart

import 'package:calmreminder/services/journal_service.dart';
import 'package:calmreminder/services/time_service.dart';
import 'package:flutter/material.dart';
import '../../core/models/journal_entry.dart';

class MoodJournalPage extends StatefulWidget {
  const MoodJournalPage({super.key});

  @override
  State<MoodJournalPage> createState() => _MoodJournalPageState();
}

class _MoodJournalPageState extends State<MoodJournalPage> {
  List<JournalEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  // Mengambil data dari Firestore melalui Service
  Future<void> _loadEntries() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final entries = await JournalService.getEntries();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  // Dialog yang berfungsi ganda untuk Tambah dan Edit
  void _showJournalDialog({JournalEntry? existingEntry}) async {
    final bool isEdit = existingEntry != null;
    String selectedMood = existingEntry?.mood ?? '😊';
    String selectedStress = existingEntry?.stressLevel ?? 'Relax';
    final TextEditingController noteController = 
        TextEditingController(text: existingEntry?.note ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEdit ? 'Update Journal' : 'New Journal Entry',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                   // Mood Selection
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    width: double.infinity, // Pastikan mengambil lebar penuh
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8, // Jarak antar emoji secara horizontal
                          runSpacing: 12, // Jarak antar baris jika terpaksa turun
                          children: ['😊', '😐', '😰', '😢', '😤'].map((emoji) {
                            return GestureDetector(
                              onTap: () => setDialogState(() => selectedMood = emoji),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: selectedMood == emoji
                                      ? Colors.white24
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedMood == emoji
                                        ? Colors.white
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24), // Ukuran sedikit diperkecil agar lebih aman
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

                    const SizedBox(height: 16),

                    // Stress Level Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedStress,
                      dropdownColor: const Color(0xFF8B5CF6),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Stress Level',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: ['Relax', 'Mild Stress', 'High Stress']
                          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (v) => setDialogState(() => selectedStress = v!),
                    ),

                    const SizedBox(height: 16),

                    // Note Input
                    TextField(
                      controller: noteController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'How was your day?',
                        hintStyle: const TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                            onPressed: () async {
                              if (noteController.text.isEmpty) return;

                              // Tetap menggunakan TimeService API
                              final timestamp = isEdit 
                                  ? existingEntry.timestamp 
                                  : (await TimeService.getCurrentTime() ?? DateTime.now());
                              
                              final entry = JournalEntry(
                                id: isEdit 
                                    ? existingEntry.id 
                                    : DateTime.now().millisecondsSinceEpoch.toString(),
                                mood: selectedMood,
                                note: noteController.text,
                                timestamp: timestamp,
                                stressLevel: selectedStress,
                              );

                              if (isEdit) {
                                await JournalService.updateEntry(entry);
                              } else {
                                await JournalService.saveEntry(entry);
                              }
                              
                              if (!context.mounted) return;
                              Navigator.pop(context, true);
                            },
                            child: Text(
                              isEdit ? 'Update' : 'Save',
                              style: const TextStyle(
                                color: Color(0xFF8B5CF6), 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (result == true) _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA78BFA), Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Mood Journal', 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 20, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.white, size: 32),
                      onPressed: () => _showJournalDialog(),
                    ),
                  ],
                ),
              ),

              // Bagian List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _entries.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _entries.length,
                            itemBuilder: (context, index) => _buildJournalCard(_entries[index]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📝', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text('No entries yet', style: TextStyle(color: Colors.white70, fontSize: 18)),
          TextButton.icon(
            onPressed: () => _showJournalDialog(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Write first entry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCard(JournalEntry entry) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Dialog Konfirmasi Hapus
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Entry?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), 
                child: const Text('Cancel')
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), 
                child: const Text('Delete', style: TextStyle(color: Colors.red))
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await JournalService.deleteEntry(entry.id);
        _loadEntries();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted'), backgroundColor: Colors.redAccent),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8), 
          borderRadius: BorderRadius.circular(16)
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _showJournalDialog(existingEntry: entry), // Navigasi ke Edit
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(entry.mood, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.stressLevel, 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                        Text(
                          TimeService.formatDateTime(entry.timestamp),
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.white54, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.note, 
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)
              ),
            ],
          ),
        ),
      ),
    );
  }
}