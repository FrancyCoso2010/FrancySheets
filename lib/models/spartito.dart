class Spartito {
  final String titolo;
  final String autore;
  final String filePath;

  Spartito({
    required this.titolo,
    required this.autore,
    required this.filePath,
  });

  Map<String, dynamic> toJson() => {
        'titolo': titolo,
        'autore': autore,
        'filePath': filePath,
      };

  factory Spartito.fromJson(Map<String, dynamic> json) => Spartito(
        titolo: json['titolo'],
        autore: json['autore'],
        filePath: json['filePath'],
      );
}
