import 'package:flutter/material.dart';
import '../models/spartito.dart';
import '../services/spartito_storage.dart';
import '../pages/pdf_viewer_page.dart';
import '../widgets/add_spartito_dialog.dart';

enum SortOrder { alphabetic, dateAdded, instrument }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Spartito> spartiti = [];
  String searchQuery = '';
  SortOrder sortOrder = SortOrder.alphabetic;

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
      setState(() {
        spartiti.add(nuovo);
        _sortList();
      });
      _save();
    }
  }

  void _sortList() {
    setState(() {
      switch (sortOrder) {
        case SortOrder.alphabetic:
          spartiti.sort((a, b) => a.titolo.toLowerCase().compareTo(b.titolo.toLowerCase()));
          break;
        case SortOrder.dateAdded:
          // niente da fare: ordine di aggiunta = naturale
          break;
        case SortOrder.instrument:
          spartiti.sort((a, b) => a.strumento.toLowerCase().compareTo(b.strumento.toLowerCase()));
          break;
      }
    });
  }

  List<Spartito> get _filteredList {
    final lower = searchQuery.toLowerCase();
    final filtered = spartiti.where((s) {
      return s.titolo.toLowerCase().contains(lower) ||
          s.autore.toLowerCase().contains(lower) ||
          s.strumento.toLowerCase().contains(lower);
    }).toList();
    return filtered;
  }

  void _open(Spartito s) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfViewerPage(spartito: s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filteredList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FrancySheets'),
        actions: [
          // 🔹 Dropdown ordinamento
          DropdownButtonHideUnderline(
            child: DropdownButton<SortOrder>(
              value: sortOrder,
              dropdownColor: const Color(0xFF2E2C45),
              icon: const Icon(Icons.sort, color: Colors.white),
              items: const [
                DropdownMenuItem(
                  value: SortOrder.alphabetic,
                  child: Text('A-Z', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: SortOrder.dateAdded,
                  child: Text('Data di aggiunta', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: SortOrder.instrument,
                  child: Text('Strumento', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    sortOrder = value;
                    _sortList();
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Barra di ricerca
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca spartito...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF2A2840),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text('Nessuno spartito trovato',
                        style: TextStyle(color: Colors.white60)),
                  )
                : ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      final s = lista[i];
                      return Card(
                        color: Colors.deepPurple.shade400,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(s.titolo, style: const TextStyle(color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (s.autore.isNotEmpty)
                                Text(s.autore,
                                    style: const TextStyle(color: Colors.white70)),
                              if (s.strumento.isNotEmpty)
                                Text('Strumento: ${s.strumento}',
                                    style: const TextStyle(color: Colors.white54, fontSize: 13)),
                            ],
                          ),
                          leading: const Icon(Icons.music_note, color: Colors.white),
                          onTap: () => _open(s),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSpartito,
        child: const Icon(Icons.add),
      ),
    );
  }
}
