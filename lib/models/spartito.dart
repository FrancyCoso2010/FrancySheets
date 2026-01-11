import 'package:uuid/uuid.dart';

class Spartito {
  final String id;
  final String titolo;
  final String autore;
  final String filePath;
  final String strumento;

  Spartito({
    String? id,
    required this.titolo,
    required this.autore,
    required this.filePath,
    required this.strumento,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'titolo': titolo,
        'autore': autore,
        'filePath': filePath,
        'strumento': strumento,
      };

  factory Spartito.fromJson(Map<String, dynamic> json) {
    return Spartito(
      id: json['id'] as String? ?? const Uuid().v4(),
      titolo: json['titolo'] as String? ?? '',
      autore: json['autore'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      strumento: json['strumento'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Spartito &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}