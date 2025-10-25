import 'package:flutter/material.dart';
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
    setState(() {});
  }

  Future<void> _save() async {
    await ParteStorage.save(parti);
  }

  void _addParteDialog() {
    String nome = '';
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2840),
          title: const Text('Aggiungi Parte', style: TextStyle(color: Colors.white)),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Nome parte (es. Piano)'),
            onChanged: (v) => nome = v,
          ),
          actions: [
            TextButton(
              child: const Text('Annulla'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Salva'),
              onPressed: () {
                if (nome.trim().isNotEmpty) {
                  setState(() => parti.add(Parte(nome: nome.trim())));
                  _save();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _removeParte(Parte parte) {
    setState(() => parti.remove(parte));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parti / Strumenti')),
      body: parti.isEmpty
          ? const Center(
              child: Text('Nessuna parte aggiunta',
                  style: TextStyle(color: Colors.white60)),
            )
          : ListView.builder(
              itemCount: parti.length,
              itemBuilder: (context, i) {
                final p = parti[i];
                return Card(
                  color: Colors.deepPurple.shade400,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(p.nome, style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _removeParte(p),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addParteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
