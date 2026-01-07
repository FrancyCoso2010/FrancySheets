// widgets/add_spartito_dialog.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/spartito.dart';
import '../models/parte.dart';
import '../services/parte_storage.dart';
import 'dart:io';

class AddSpartitoDialog extends StatefulWidget {
  const AddSpartitoDialog({super.key});

  @override
  State<AddSpartitoDialog> createState() => _AddSpartitoDialogState();
}

class _AddSpartitoDialogState extends State<AddSpartitoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titoloController = TextEditingController();
  final _autoreController = TextEditingController();
  String? _filePath;
  String? _fileName;
  Parte? _parteSelezionata;
  List<Parte> _partiDisponibili = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParti();
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _autoreController.dispose();
    super.dispose();
  }

  Future<void> _loadParti() async {
    final parti = await ParteStorage.load();
    if (mounted) {
      setState(() {
        _partiDisponibili = parti;
        _parteSelezionata = parti.isNotEmpty ? parti.first : null;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );

    if (result?.files.single.path != null) {
      final path = result!.files.single.path!;
      final file = File(path);
      if (await file.exists()) {
        final size = await file.length();
        if (size == 0) {
          _showError('Il file PDF è vuoto.');
          return;
        }
        if (size > 100 * 1024 * 1024) {
          // Limite: 100 MB
          _showError('Il PDF è troppo grande (massimo 100 MB).');
          return;
        }

        setState(() {
          _filePath = path;
          _fileName = file.uri.pathSegments.last;
        });
      } else {
        _showError('File non trovato.');
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _saveSpartito() {
    if (_formKey.currentState?.validate() != true || _filePath == null || _parteSelezionata == null) {
      _showError('Completa tutti i campi obbligatori e seleziona un PDF valido.');
      return;
    }

    Navigator.pop(
      context,
      Spartito(
        id: null,
        titolo: _titoloController.text.trim(),
        autore: _autoreController.text.trim(),
        filePath: _filePath!,
        strumento: _parteSelezionata!.nome,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(
        'Aggiungi Spartito',
        style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Titolo
                    TextFormField(
                      controller: _titoloController,
                      decoration: InputDecoration(
                        labelText: 'Titolo *',
                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Titolo obbligatorio' : null,
                    ),
                    const SizedBox(height: 16),

                    // Autore
                    TextFormField(
                      controller: _autoreController,
                      decoration: InputDecoration(
                        labelText: 'Autore (opzionale)',
                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Strumento
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else if (_partiDisponibili.isEmpty)
                      Text(
                        'Nessuna parte disponibile. Vai in "Parti / Strumenti" per aggiungerne.',
                        style: TextStyle(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      )
                    else
                      DropdownButtonFormField<Parte>(
                        value: _parteSelezionata,
                        decoration: InputDecoration(
                          labelText: 'Strumento *',
                          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                          border: const OutlineInputBorder(),
                        ),
                        items: _partiDisponibili
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.nome),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _parteSelezionata = val),
                        validator: (val) => val == null ? 'Seleziona uno strumento' : null,
                      ),
                    if (!_isLoading && _partiDisponibili.isNotEmpty) const SizedBox(height: 16),

                    // PDF
                    if (!_isLoading)
                      OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          _filePath == null
                              ? 'Seleziona PDF (massimo 100 MB)'
                              : 'Selezionato: $_fileName',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: colorScheme.outline),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annulla', style: TextStyle(color: colorScheme.primary)),
        ),
        FilledButton(
          onPressed: _saveSpartito,
          child: const Text('Aggiungi'),
        ),
      ],
    );
  }
}