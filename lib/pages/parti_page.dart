// parti_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/parte.dart';
import '../services/parte_storage.dart';

class PartiPage extends StatefulWidget {
  const PartiPage({super.key});

  @override
  State<PartiPage> createState() => _PartiPageState();
}

class _PartiPageState extends State<PartiPage> {
  List<Parte> parti = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    parti = await ParteStorage.load();
    if (mounted) setState(() {});
  }

  Future<void> _save() async => ParteStorage.save(parti);

  void _addParteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Aggiungi parte'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nome (es. Clarinetto)'),
          ),
          actions: [
            TextButton(onPressed: Navigator.of(context).pop, child: const Text('Annulla')),
            FilledButton(
              onPressed: () {
                final nome = controller.text.trim();
                if (nome.isNotEmpty) {
                  setState(() => parti.add(Parte(nome: nome)));
                  _save();
                  Navigator.pop(context);
                }
              },
              child: const Text('Aggiungi'),
            ),
          ],
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        );
      },
    );
  }

  void _removeParte(Parte parte) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina parte'),
        content: Text('Eliminare "${parte.nome}"? Questa azione è irreversibile.'),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text('Annulla')),
          FilledButton.tonal(
            onPressed: () {
              setState(() => parti.remove(parte));
              _save();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parti / Strumenti'),
        backgroundColor: const Color(0xFF5B4C9C),
      ),
      body: parti.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note_outlined, size: 56, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Nessuna parte disponibile',
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 72),
              itemCount: parti.length,
              itemBuilder: (context, i) {
                final p = parti[i];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.music_note, size: 20),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          p.nome,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red.shade600,
                        onPressed: () => _removeParte(p),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addParteDialog,
        tooltip: 'Aggiungi nuova parte',
        icon: const Icon(Icons.add),
        label: const Text("Aggiungi"),
      ),
    );
  }
}