import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../models/spartito.dart';
import 'package:flutter/services.dart';

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

  // Overlay entry per l'indicatore pagina (evita rebuild del PDF)
  OverlayEntry? _pageIndicatorOverlay;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    try {
      final document = await PdfDocument.openFile(widget.spartito.filePath);
      if (!mounted) {
        await document.close();
        return;
      }

      _totalPages = document.pagesCount;
      _pdfController = PdfController(document: Future.value(document), initialPage: 1);

      if (mounted) {
        setState(() => _isLoading = false);
        _showPageIndicator();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showPageIndicator() {
    // Rimuove l'overlay precedente se presente e ne crea uno nuovo.
    _pageIndicatorOverlay?.remove();
    _pageIndicatorOverlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20,
        left: 0,
        right: 0,
        child: Center(
          child: GestureDetector(
            onLongPress: _showPagePicker,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_currentPage / $_totalPages',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_pageIndicatorOverlay!);
  }

  void _onPageChanged(int page) {
    if (page != _currentPage) {
      _currentPage = page;
      // Aggiorna SOLO l'overlay, niente setState!
      _updatePageIndicator();
    }
  }

  void _updatePageIndicator() {
    _pageIndicatorOverlay?.markNeedsBuild();
  }

  void _showTapFeedback(bool isLeft) {
    // Mostra un flash molto breve senza setState
    final feedback = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: isLeft ? Colors.black12 : Colors.black12,
        ),
      ),
    );

    Overlay.of(context).insert(feedback);
    Future.delayed(const Duration(milliseconds: 50), () {
      feedback.remove();
    });
  }

  void _handleTap(TapDownDetails details) {
    final width = MediaQuery.of(context).size.width;
    final dx = MediaQuery.of(context).viewPadding.left + MediaQuery.of(context).viewInsets.left;
    final tapX = details.globalPosition.dx - dx;

    // Evita il centro (dove c'è l'indicatore)
    final center = width / 2;
    if ((tapX > center - 80) && (tapX < center + 80)) return;

    final isLeft = tapX < width / 2;
    _showTapFeedback(isLeft);

    if (isLeft) {
      if (_currentPage > 1) {
        HapticFeedback.selectionClick();
        _pdfController.previousPage(
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 150),
        );
      }
    } else {
      if (_currentPage < _totalPages) {
        HapticFeedback.selectionClick();
        _pdfController.nextPage(
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 150),
        );
      }
    }
  }

  Future<void> _showPagePicker() async {
    final controller = TextEditingController(text: '$_currentPage');
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Vai a pagina'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Totale: $_totalPages'),
              const SizedBox(height: 12),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) return;
                    final num = int.tryParse(value) ?? 0;
                    if (num < 1) controller.text = '1';
                    if (num > _totalPages) controller.text = '$_totalPages';
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
            FilledButton(
              onPressed: () {
                final page = int.tryParse(controller.text);
                if (page != null && page >= 1 && page <= _totalPages) {
                  Navigator.pop(context, page);
                }
              },
              child: const Text('Vai'),
            ),
          ],
        );
      },
    );

    if (result != null && result != _currentPage) {
      _pdfController.jumpToPage(result);
    }
  }
  @override
  void dispose() {
    _pageIndicatorOverlay?.remove();
    _feedbackTimer?.cancel();
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 56),
                  const SizedBox(height: 16),
                  const Text('Impossibile aprire lo spartito', textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton.tonal(onPressed: _initPdf, child: const Text('Riprova')),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // ✅ PdfView isolato: non rebuilda mai durante l'interazione
              RepaintBoundary(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: _handleTap,
                  onLongPress: _showPagePicker,
                  child: PdfView(
                    controller: _pdfController,
                    scrollDirection: Axis.horizontal,
                    pageSnapping: true,
                    backgroundDecoration: const BoxDecoration(color: Colors.white),
                    onPageChanged: _onPageChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}