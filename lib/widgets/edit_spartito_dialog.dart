import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/spartito.dart';
import '../models/parte.dart';
import '../services/parte_storage.dart';
import 'dart:io';

class EditSpartitoDialog extends StatefulWidget {
  final Spartito spartito;

  const EditSpartitoDialog({super.key, required this.spartito});

  @override
  State<EditSpartitoDialog> createState() => _EditSpartitoDialogState();
}

class _EditSpartitoDialogState extends State<EditSpartitoDialog> {
  final formKey = GlobalKey<FormState>();
  late String titolo;
  late String autore;
  late String filePath;
  late String fileName;
  String? strumento;
  List<Parte> partiDisponibili = [];

  @override
  void initState() {
    super.initState();
    titolo = widget.spartito.titolo;
    autore = widget.spartito.autore;
    filePath = widget.spartito.filePath;
    fileName = File(filePath).uri.pathSegments.last;
    strumento = widget.spartito.strumento;
    _loadParti();
  }

  Future<void> _loadParti() async {
    partiDisponibili = await ParteStorage.load();
    if (partiDisponibili.isNotEmpty && (strumento == null || strumento!.isEmpty)) {
      strumento = partiDisponibili.first.nome;
    }
    setState(() {});
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      if (File(path).existsSync()) {
        setState(() {
          filePath = path;
          fileName = File(filePath).uri.pathSegments.last;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File non valido o non trovato')),
        );
      }
    }
  }

  void _saveSpartito() {
    if (!formKey.currentState!.validate() || strumento == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa tutti i campi obbligatori')),
      );
      return;
    }

    formKey.currentState!.save();
    Navigator.pop(
      context,
      Spartito(
        titolo: titolo,
        autore: autore,
        filePath: filePath,
        strumento: strumento!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2840),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Modifica Spartito", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titolo
              TextFormField(
                initialValue: titolo,
                decoration: const InputDecoration(
                  labelText: 'Titolo',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (v) => v == null || v.isEmpty ? 'Titolo obbligatorio' : null,
                onSaved: (v) => titolo = v!,
              ),
              const SizedBox(height: 12),

              // Autore
              TextFormField(
                initialValue: autore,
                decoration: const InputDecoration(
                  labelText: 'Autore (opzionale)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (v) => autore = v ?? '',
              ),
              const SizedBox(height: 12),

              // Strumento
              DropdownButtonFormField<String>(
                value: strumento,
                dropdownColor: const Color(0xFF2E2C45),
                decoration: const InputDecoration(
                  labelText: 'Strumento',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: partiDisponibili
                    .map((p) => DropdownMenuItem(
                          value: p.nome,
                          child: Text(p.nome, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => strumento = val),
                validator: (val) => val == null ? 'Seleziona uno strumento' : null,
              ),
              const SizedBox(height: 12),

              // PDF
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filePath.isEmpty ? 'Seleziona PDF' : 'PDF selezionato: $fileName',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (filePath.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ],
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
        // Pulsante elimina
        TextButton.icon(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          label: const Text('Elimina', style: TextStyle(color: Colors.redAccent)),
          onPressed: () => Navigator.pop(context, 'delete'),
        ),
        TextButton(
          child: const Text('Annulla', style: TextStyle(color: Colors.white70)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Salva'),
          onPressed: _saveSpartito,
        ),
      ],
    );
  }
}
