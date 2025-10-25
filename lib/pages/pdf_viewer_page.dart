import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../models/spartito.dart';

class PdfViewerPage extends StatefulWidget {
  final Spartito spartito;
  const PdfViewerPage({required this.spartito, super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late final PdfController _pdfController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    try {
      _pdfController = PdfController(
        document: Future.value(await PdfDocument.openFile(widget.spartito.filePath)),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spartito.titolo),
        backgroundColor: const Color(0xFF2E2C45),
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Impossibile aprire lo spartito',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : PdfView(
                  controller: _pdfController,
                  scrollDirection: Axis.horizontal, // horizontal swiping
                  pageSnapping: true,               // snap to page
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black),
                  onPageChanged: (page) {
                    // Optional: do something when page changes
                  },
                ),
      floatingActionButton: _isLoading || _error != null
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'prev',
                  onPressed: () {
                    _pdfController.previousPage(
                      curve: Curves.easeInOut, // smooth animation
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'next',
                  onPressed: () {
                    _pdfController.nextPage(
                      curve: Curves.easeInOut, // smooth animation
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
    );
  }
}
