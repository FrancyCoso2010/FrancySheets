class Parte {
  final String nome;

  Parte({required this.nome});

  Map<String, dynamic> toJson() => {'nome': nome};

  factory Parte.fromJson(Map<String, dynamic> json) => Parte(
        nome: json['nome'] as String,
      );
}
