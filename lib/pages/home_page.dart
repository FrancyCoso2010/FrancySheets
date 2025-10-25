import 'package:flutter/material.dart';
import '../models/spartito.dart';
import '../models/parte.dart';
import '../services/spartito_storage.dart';
import '../services/parte_storage.dart';
import '../pages/pdf_viewer_page.dart';
import '../widgets/add_spartito_dialog.dart';
import '../widgets/edit_spartito_dialog.dart';
import '../pages/parti_page.dart';

enum SortOrder { alphabetic, dateAdded, instrument }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Spartito> spartiti = [];
  List<Parte> partiDisponibili = [];
  String searchQuery = '';
  SortOrder sortOrder = SortOrder.alphabetic;
  String? filtroStrumento;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    spartiti = await SpartitoStorage.load();
    partiDisponibili = await ParteStorage.load();
    _sortList();
    setState(() {});
  }

  Future<void> _save() async => SpartitoStorage.save(spartiti);

  Future<void> _addSpartito() async {
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
    switch (sortOrder) {
      case SortOrder.alphabetic:
        spartiti.sort(
          (a, b) => a.titolo.toLowerCase().compareTo(b.titolo.toLowerCase()),
        );
        break;
      case SortOrder.dateAdded:
        // mantiene l’ordine di inserimento
        break;
      case SortOrder.instrument:
        spartiti.sort(
          (a, b) => a.strumento.toLowerCase().compareTo(b.strumento.toLowerCase()),
        );
        break;
    }
  }

  List<Spartito> get _filteredList {
    final query = searchQuery.toLowerCase();
    var filtered = spartiti.where((s) {
      return s.titolo.toLowerCase().contains(query) ||
          s.autore.toLowerCase().contains(query) ||
          s.strumento.toLowerCase().contains(query);
    }).toList();

    if (filtroStrumento?.isNotEmpty == true) {
      filtered = filtered.where((s) => s.strumento == filtroStrumento).toList();
    }

    return filtered;
  }

  void _openSpartito(Spartito s) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfViewerPage(spartito: s)),
    );
  }

  Future<void> _showFiltroStrumentoDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2840),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Filtra per strumento",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: partiDisponibili.isEmpty
            ? const Text(
                "Nessuna parte disponibile",
                style: TextStyle(color: Colors.white70),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...partiDisponibili.map(
                      (parte) => ListTile(
                        title: Text(parte.nome,
                            style: const TextStyle(color: Colors.white)),
                        onTap: () => Navigator.pop(context, parte.nome),
                      ),
                    ),
                    const Divider(color: Colors.white24),
                    ListTile(
                      title: const Text(
                        "Mostra tutti",
                        style: TextStyle(color: Colors.white70),
                      ),
                      onTap: () => Navigator.pop(context, null),
                    ),
                  ],
                ),
              ),
      ),
    );

    if (filtroStrumento != selected) {
      setState(() => filtroStrumento = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filteredList;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1B2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E2C45),
        title: const Text('FrancySheets'),
        elevation: 4,
        actions: [
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
              onChanged: (value) async {
                if (value == null) return;
                setState(() {
                  sortOrder = value;
                  _sortList();
                });
                if (value == SortOrder.instrument) {
                  await _showFiltroStrumentoDialog();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),

      // 🟣 Drawer per navigazione
      drawer: Drawer(
        backgroundColor: const Color(0xFF2A2840),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF2E2C45)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.library_music, color: Colors.white),
              title: const Text('Spartiti', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // chiudi drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note, color: Colors.white),
              title: const Text('Parti / Strumenti', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PartiPage()),
                );
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // 🔍 Ricerca
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cerca spartito...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
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

          if (filtroStrumento?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Chip(
                    backgroundColor: Colors.deepPurple.shade400,
                    label: Text('Filtro: $filtroStrumento'),
                    labelStyle: const TextStyle(color: Colors.white),
                    deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                    onDeleted: () => setState(() => filtroStrumento = null),
                  ),
                ],
              ),
            ),

          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text(
                      'Nessuno spartito trovato',
                      style: TextStyle(color: Colors.white60),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      final s = lista[i];
                      return Card(
                        color: Colors.deepPurple.shade500,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.music_note, color: Colors.white),
                          title: Text(
                            s.titolo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    s.autore.isNotEmpty ? s.autore : '',
                                    style: const TextStyle(color: Colors.white70),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (s.strumento.isNotEmpty)
                                  Text(
                                    "Strumento: ${s.strumento}",
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 13),
                                  ),
                              ],
                            ),
                          ),
                          onTap: () => _openSpartito(s),
                          onLongPress: () async {
                            final result = await showDialog(
                              context: context,
                              builder: (_) => EditSpartitoDialog(spartito: s),
                            );

                            if (result == null) return;

                            if (result == 'delete') {
                              setState(() => spartiti.remove(s));
                              _save();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Spartito eliminato')),
                              );
                            } else if (result is Spartito) {
                              setState(() {
                                final index = spartiti.indexOf(s);
                                spartiti[index] = result;
                                _sortList();
                              });
                              _save();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Spartito modificato')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSpartito,
        icon: const Icon(Icons.add),
        label: const Text("Aggiungi"),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
