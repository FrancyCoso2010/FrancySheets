import 'package:flutter/material.dart';
import '../models/spartito.dart';
import '../services/spartito_storage.dart';
import '../pages/pdf_viewer_page.dart';
import '../widgets/add_spartito_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Spartito> spartiti = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    spartiti = await SpartitoStorage.load();
    setState(() {});
  }

  Future<void> _save() async {
    await SpartitoStorage.save(spartiti);
  }

  void _addSpartito() async {
    final nuovo = await showDialog<Spartito>(
      context: context,
      builder: (_) => const AddSpartitoDialog(),
    );
    if (nuovo != null) {
      setState(() => spartiti.add(nuovo));
      _save();
    }
  }

  void _open(Spartito s) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfViewerPage(spartito: s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FrancySheets')),
      body: spartiti.isEmpty
          ? const Center(
              child: Text('Nessuno spartito aggiunto',
                  style: TextStyle(color: Colors.white70)),
            )
          : ListView.builder(
              itemCount: spartiti.length,
              itemBuilder: (context, i) {
                final s = spartiti[i];
                return Card(
                  color: Colors.deepPurple.shade400,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(s.titolo, style: const TextStyle(color: Colors.white)),
                    subtitle: s.autore.isNotEmpty
                        ? Text(s.autore, style: const TextStyle(color: Colors.white70))
                        : null,
                    leading: const Icon(Icons.music_note, color: Colors.white),
                    onTap: () => _open(s),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSpartito,
        child: const Icon(Icons.add),
      ),
    );
  }
}
