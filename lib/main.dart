// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FrancySheetsApp());
}

class FrancySheetsApp extends StatelessWidget {
  const FrancySheetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FrancySheets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1C1B2F),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.redAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E2C45),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// 🎵 MODELLO SPARTITO
class Spartito {
  final String titolo;
  final String autore;
  final String filePath;

  Spartito({
    required this.titolo,
    required this.autore,
    required this.filePath,
  });

  Map<String, dynamic> toJson() => {
        'titolo': titolo,
        'autore': autore,
        'filePath': filePath,
      };

  factory Spartito.fromJson(Map<String, dynamic> json) => Spartito(
        titolo: json['titolo'] as String,
        autore: json['autore'] as String,
        filePath: json['filePath'] as String,
      );
}

// 🏠 HOME PAGE: gestione lista spartiti
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Spartito> spartiti = [];

  @override
  void initState() {
    super.initState();
    _loadSpartiti();
  }

  Future<void> _saveSpartiti() async {
    final prefs = await SharedPreferences.getInstance();
    final spartitiJson =
        spartiti.map((s) => json.encode(s.toJson())).toList();
    await prefs.setStringList('spartiti', spartitiJson);
  }

  Future<void> _loadSpartiti() async {
    final prefs = await SharedPreferences.getInstance();
    final spartitiJson = prefs.getStringList('spartiti');
    if (spartitiJson != null) {
      setState(() {
        spartiti =
            spartitiJson.map((s) => Spartito.fromJson(json.decode(s))).toList();
      });
    }
  }

  void _showAddSpartitoDialog() {
    final formKey = GlobalKey<FormState>();
    String titolo = '';
    String autore = '';
    String? filePath;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2840),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Aggiungi Spartito",
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Titolo'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Titolo obbligatorio' : null,
                    onSaved: (value) => titolo = value!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Autore (opzionale)'),
                    onSaved: (value) => autore = value ?? '',
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );
                      if (result != null && result.files.single.path != null) {
                        filePath = result.files.single.path!;
                        if (context.mounted) {
                          (context as Element).markNeedsBuild();
                        }
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      filePath == null ? 'Seleziona PDF' : 'PDF selezionato',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Annulla'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Salva'),
              onPressed: () {
                if (formKey.currentState!.validate() && filePath != null) {
                  formKey.currentState!.save();
                  setState(() {
                    spartiti.add(Spartito(
                      titolo: titolo,
                      autore: autore,
                      filePath: filePath!,
                    ));
                  });
                  _saveSpartiti();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seleziona un file PDF')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _openSpartito(Spartito spartito) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(spartito: spartito),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FrancySheets')),
      body: spartiti.isEmpty
          ? const Center(
              child: Text("Nessuno spartito aggiunto",
                  style: TextStyle(color: Colors.white60, fontSize: 16)),
            )
          : ListView.builder(
              itemCount: spartiti.length,
              itemBuilder: (context, index) {
                final s = spartiti[index];
                return Card(
                  color: Colors.deepPurple.shade400,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(s.titolo, style: const TextStyle(color: Colors.white)),
                    subtitle: s.autore.isNotEmpty
                        ? Text(s.autore,
                            style: const TextStyle(color: Colors.white70))
                        : null,
                    leading: const Icon(Icons.music_note, color: Colors.white),
                    onTap: () => _openSpartito(s),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSpartitoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}


class PdfViewerPage extends StatefulWidget {
  final Spartito spartito;
  const PdfViewerPage({required this.spartito, super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late final PdfController _pdfController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    try {
      _pdfController = PdfController(
        document: Future.value(await PdfDocument.openFile(widget.spartito.filePath)),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spartito.titolo),
        backgroundColor: const Color(0xFF2E2C45),
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Impossibile aprire lo spartito',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : PdfView(
                  controller: _pdfController,
                  scrollDirection: Axis.horizontal, // horizontal swiping
                  pageSnapping: true,               // snap to page
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black),
                  onPageChanged: (page) {
                    // Optional: do something when page changes
                  },
                ),
      floatingActionButton: _isLoading || _error != null
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'prev',
                  onPressed: () {
                    _pdfController.previousPage(
                      curve: Curves.easeInOut, // smooth animation
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'next',
                  onPressed: () {
                    _pdfController.nextPage(
                      curve: Curves.easeInOut, // smooth animation
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
    );
  }
}
