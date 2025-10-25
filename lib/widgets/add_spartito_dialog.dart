import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/spartito.dart';

class AddSpartitoDialog extends StatefulWidget {
  const AddSpartitoDialog({super.key});

  @override
  State<AddSpartitoDialog> createState() => _AddSpartitoDialogState();
}

class _AddSpartitoDialogState extends State<AddSpartitoDialog> {
  final formKey = GlobalKey<FormState>();
  String titolo = '';
  String autore = '';
  String? filePath;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2840),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Aggiungi Spartito",
          style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Titolo'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Titolo obbligatorio' : null,
                onSaved: (v) => titolo = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Autore (opzionale)'),
                onSaved: (v) => autore = v ?? '',
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null && result.files.single.path != null) {
                    setState(() => filePath = result.files.single.path!);
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: Text(
                  filePath == null ? 'Seleziona PDF' : 'PDF selezionato',
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
        TextButton(
          child: const Text('Annulla'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Salva'),
          onPressed: () {
            if (formKey.currentState!.validate() && filePath != null) {
              formKey.currentState!.save();
              Navigator.pop(
                context,
                Spartito(titolo: titolo, autore: autore, filePath: filePath!),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Seleziona un file PDF')),
              );
            }
          },
        ),
      ],
    );
  }
}
