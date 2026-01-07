class Spartito {
  final String? id;
  final String titolo;
  final String autore;
  final String filePath;
  final String strumento; // 👈 nuovo campo

  Spartito({
    required this.id,
    required this.titolo,
    required this.autore,
    required this.filePath,
    required this.strumento,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titolo': titolo,
        'autore': autore,
        'filePath': filePath,
        'strumento': strumento,
      };

  factory Spartito.fromJson(Map<String, dynamic> json) => Spartito(
        id: json['id'],
        titolo: json['titolo'],
        autore: json['autore'],
        filePath: json['filePath'],
        strumento: json['strumento'] ?? '',
      );
}
