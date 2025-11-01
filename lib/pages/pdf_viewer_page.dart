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
  late PdfController _pdfController;
  bool _isLoading = true;
  String? _error;
  int _totalPages = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    try {
      final document = await PdfDocument.openFile(widget.spartito.filePath);
      _totalPages = document.pagesCount;

      _pdfController = PdfController(
        document: Future.value(document),
        initialPage: 1,
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

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      _pdfController.nextPage(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _pdfController.previousPage(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sfondo bianco
      appBar: AppBar(
        elevation: 2,
        title: Text(
          widget.spartito.titolo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.redAccent, size: 50),
                      const SizedBox(height: 16),
                      const Text(
                        'Impossibile aprire lo spartito',
                        style: TextStyle(color: Colors.black87, fontSize: 18),
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
              : Stack(
                  children: [
                    GestureDetector(
                      // 👆 Tap a sinistra/destra per cambiare pagina
                      behavior: HitTestBehavior.translucent,
                      onTapUp: (details) {
                        final width = MediaQuery.of(context).size.width;
                        if (details.localPosition.dx < width / 2) {
                          _goToPreviousPage();
                        } else {
                          _goToNextPage();
                        }
                      },
                      child: PdfView(
                        controller: _pdfController,
                        scrollDirection: Axis.horizontal,
                        pageSnapping: true, // scorre di 1 pagina alla volta
                        backgroundDecoration:
                            const BoxDecoration(color: Colors.white),
                        onPageChanged: (page) {
                          setState(() => _currentPage = page);
                        },
                      ),
                    ),

                    // 📄 Indicatore pagina in basso al centro
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_currentPage / $_totalPages',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
