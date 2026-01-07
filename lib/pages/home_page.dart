// home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/spartito.dart';
import '../models/parte.dart';
import '../services/spartito_storage.dart';
import '../services/parte_storage.dart';
import '../pages/pdf_viewer_page.dart';
import '../widgets/add_spartito_dialog.dart';
import '../widgets/edit_spartito_dialog.dart';
import '../pages/parti_page.dart';

enum SortOrder { alphabetic, instrument }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Spartito> _spartiti = [];
  List<Parte> _partiDisponibili = [];
  List<Spartito> _filteredSpartiti = [];
  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.alphabetic;
  String? _filtroStrumento;
  bool _isLoading = true;

  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final spartitiData = await SpartitoStorage.load();
    final partiData = await ParteStorage.load();

    if (mounted) {
      setState(() {
        _spartiti = spartitiData;
        _partiDisponibili = partiData;
        _sortSpartiti();
        _updateFilteredSpartiti();
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async => SpartitoStorage.save(_spartiti);

  Future<void> _addSpartito() async {
    final nuovo = await showDialog<Spartito>(
      context: context,
      builder: (_) => const AddSpartitoDialog(),
    );

    if (nuovo != null) {
      setState(() {
        _spartiti.add(nuovo);
        _sortSpartiti();
        _updateFilteredSpartiti();
      });
      _save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aggiunto: "${nuovo.titolo}"')),
        );
      }
    }
  }

  void _sortSpartiti() {
    switch (_sortOrder) {
      case SortOrder.alphabetic:
        _spartiti.sort((a, b) => a.titolo.toLowerCase().compareTo(b.titolo.toLowerCase()));
      case SortOrder.instrument:
        _spartiti.sort((a, b) => a.strumento.toLowerCase().compareTo(b.strumento.toLowerCase()));
    }
  }

  void _updateFilteredSpartiti() {
    final query = _searchQuery.toLowerCase();
    var filtered = _spartiti.where((s) {
      return s.titolo.toLowerCase().contains(query) ||
          s.autore.toLowerCase().contains(query) ||
          s.strumento.toLowerCase().contains(query);
    }).toList();

    if (_filtroStrumento?.isNotEmpty == true) {
      filtered = filtered.where((s) => s.strumento == _filtroStrumento!).toList();
    }

    _filteredSpartiti = filtered;
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
      builder: (context) {
        return AlertDialog(
          title: const Text("Filtra per strumento"),
          content: SizedBox(
            width: double.maxFinite,
            child: _partiDisponibili.isEmpty
                ? const Text("Nessuna parte disponibile")
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ..._partiDisponibili.map(
                          (parte) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(parte.nome),
                            onTap: () => Navigator.pop(context, parte.nome),
                          ),
                        ),
                        const Divider(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            "Mostra tutti",
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                          onTap: () => Navigator.pop(context, null),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );

    if (_filtroStrumento != selected) {
      setState(() {
        _filtroStrumento = selected;
        _updateFilteredSpartiti();
      });
    }
  }

  void _handleEditResult(Spartito oldSpartito, dynamic result) {
    if (result == 'delete') {
      setState(() {
        _spartiti.removeWhere((s) => s.id == oldSpartito.id);
        _updateFilteredSpartiti();
      });
      _save();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eliminato: "${oldSpartito.titolo}"')),
        );
      }
    } else if (result is Spartito) {
      setState(() {
        final index = _spartiti.indexWhere((s) => s.id == oldSpartito.id);
        if (index >= 0) _spartiti[index] = result;
        _sortSpartiti();
        _updateFilteredSpartiti();
      });
      _save();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Modificato: "${oldSpartito.titolo}"')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
          _updateFilteredSpartiti();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FrancySheets'),
        centerTitle: true,
        backgroundColor: const Color(0xFF5B4C9C),
        actions: [
          if (_sortOrder == SortOrder.instrument)
            IconButton(
              tooltip: 'Filtra per strumento',
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: _showFiltroStrumentoDialog,
            ),
          DropdownButtonHideUnderline(
            child: DropdownButton<SortOrder>(
              value: _sortOrder,
              icon: const Icon(Icons.sort),
              items: const [
                DropdownMenuItem(value: SortOrder.alphabetic, child: Text('A–Z')),
                DropdownMenuItem(value: SortOrder.instrument, child: Text('Strumento')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _sortOrder = value;
                  _sortSpartiti();
                  _updateFilteredSpartiti();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF5B4C9C), Color(0xFF7A6DE0)]),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'FrancySheets',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.library_music),
              title: const Text('Spartiti'),
              selected: true,
              selectedTileColor: colorScheme.surfaceContainerHighest,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Parti / Strumenti'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PartiPage()));
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca spartito, autore o strumento...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _onSearchChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 10),
          if (_filtroStrumento?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                children: [
                  InputChip(
                    label: Text(_filtroStrumento!),
                    onDeleted: () {
                      setState(() {
                        _filtroStrumento = null;
                        _updateFilteredSpartiti();
                      });
                    },
                    backgroundColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600),
                    deleteIconColor: colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _filteredSpartiti.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.music_note_outlined, size: 56, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Nessun risultato per "$_searchQuery"'
                                        : _filtroStrumento != null
                                            ? 'Nessuno spartito per $_filtroStrumento'
                                            : 'Nessuno spartito nella libreria',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
                                  ),
                                  if (_searchQuery.isEmpty && _filtroStrumento == null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Premi il pulsante + per aggiungerne uno!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7), fontSize: 14),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 72),
                            itemCount: _filteredSpartiti.length,
                            itemBuilder: (context, i) {
                              final s = _filteredSpartiti[i];
                              return _SpartitoCard(
                                key: ValueKey(s.id), // ✅ Key univoca!
                                spartito: s,
                                onOpen: () => _openSpartito(s),
                                onEditResult: (result) => _handleEditResult(s, result),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSpartito,
        tooltip: 'Aggiungi nuovo spartito',
        icon: const Icon(Icons.add),
        label: const Text("Nuovo"),
      ),
    );
  }
}

class _SpartitoCard extends StatelessWidget {
  final Spartito spartito;
  final VoidCallback onOpen;
  final Function(dynamic) onEditResult;

  const _SpartitoCard({
    super.key,
    required this.spartito,
    required this.onOpen,
    required this.onEditResult,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onOpen,
      onLongPress: () async {
        HapticFeedback.lightImpact(); // ✅ Feedback tattile
        final result = await showDialog(
          context: context,
          builder: (_) => EditSpartitoDialog(spartito: spartito),
        );
        onEditResult(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border(
            bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spartito.titolo,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (spartito.autore.isNotEmpty)
                    Text(
                      spartito.autore,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (spartito.strumento.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  spartito.strumento,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}