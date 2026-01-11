// widgets/edit_spartito_dialog.dart
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
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titoloController;
  late final TextEditingController _autoreController;
  String? _filePath;
  String? _fileName;
  String? _strumento;
  List<Parte> _partiDisponibili = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(text: widget.spartito.titolo);
    _autoreController = TextEditingController(text: widget.spartito.autore);
    _filePath = widget.spartito.filePath;
    _fileName = File(_filePath!).uri.pathSegments.last;
    _strumento = widget.spartito.strumento;
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
        if (_strumento == null || _strumento!.isEmpty) {
          _strumento = parti.isNotEmpty ? parti.first.nome : null;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
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
    if (_formKey.currentState?.validate() != true || _filePath == null || _strumento == null) {
      _showError('Completa tutti i campi obbligatori.');
      return;
    }

    Navigator.pop(
      context,
      Spartito(
        id: widget.spartito.id,
        titolo: _titoloController.text.trim(),
        autore: _autoreController.text.trim(),
        filePath: _filePath!,
        strumento: _strumento!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(
        'Modifica Spartito',
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
                        'Nessuna parte disponibile.',
                        style: TextStyle(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _strumento,
                        decoration: InputDecoration(
                          labelText: 'Strumento *',
                          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                          border: const OutlineInputBorder(),
                        ),
                        items: _partiDisponibili
                            .map((p) => DropdownMenuItem(
                                  value: p.nome,
                                  child: Text(p.nome),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _strumento = val),
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
                              ? 'Cambia PDF'
                              : 'Attuale: $_fileName',
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
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context, 'delete'),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Elimina'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            padding: EdgeInsets.zero,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annulla', style: TextStyle(color: colorScheme.primary)),
            ),
            FilledButton(
              onPressed: _saveSpartito,
              child: const Text('Salva'),
            ),
          ],
        ),
      ],
    );
  }
}