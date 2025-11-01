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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            '🎶 Aggiungi Parte',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Nome parte (es. Pianoforte)',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.deepPurpleAccent),
              ),
              filled: true,
              fillColor: const Color(0xFF1F1D36),
            ),
            onChanged: (v) => nome = v,
          ),
          actions: [
            TextButton(
              child: const Text('Annulla', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_rounded, size: 18),
              label: const Text('Salva'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2840),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Elimina parte',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Vuoi davvero eliminare "${parte.nome}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Annulla', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text('Elimina'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() => parti.remove(parte));
              _save();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF1C1B2F),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Parti / Strumenti', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F2B96), Color(0xFFA8C0FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // sfondo con gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C1B2F), Color(0xFF2E2C45)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 100),

              Expanded(
                child: parti.isEmpty
                    ? const Center(
                        child: Text(
                          'Nessuna parte aggiunta 🎺',
                          style: TextStyle(color: Colors.white60, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: parti.length,
                        itemBuilder: (context, i) {
                          final p = parti[i];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.music_note_rounded, color: Colors.white),
                              title: Text(
                                p.nome,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                onPressed: () => _removeParte(p),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addParteDialog,
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text("Aggiungi"),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
    );
  }
}
