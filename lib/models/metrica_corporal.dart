class MetricaCorporal {
  final String? id; // UUID como String
  final String usuarioId; // UUID como String
  final double peso;
  final double? imc;
  final double? grasaCorporal;
  final double? masaMuscular;
  final DateTime fecha;
  final String? notas;

  MetricaCorporal({
    this.id,
    required this.usuarioId,
    required this.peso,
    this.imc,
    this.grasaCorporal,
    this.masaMuscular,
    required this.fecha,
    this.notas,
  });

  // Para enviar al backend (historial de peso)
  Map<String, dynamic> toJsonForBackend() {
    return {
      'Peso': peso,
      'TipoRegistro': 'manual',
      'IndiceConfianza': 1.0,
      if (notas != null) 'Observaciones': notas,
    };
  }

  // Para uso local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'peso': peso,
      'imc': imc,
      'grasaCorporal': grasaCorporal,
      'masaMuscular': masaMuscular,
      'fecha': fecha.toIso8601String(),
      'notas': notas,
    };
  }

  // Desde respuesta del backend (historial de peso)
  factory MetricaCorporal.fromJsonBackend(Map<String, dynamic> json) {
    return MetricaCorporal(
      id: json['IdPeso'] ?? json['id'],
      usuarioId: json['IdUsuario'] ?? json['usuarioId'],
      peso: _parseDouble(json['Peso'] ?? json['peso']),
      imc: null, // Se calcula dinámicamente
      grasaCorporal: null, // No disponible en historial de peso
      masaMuscular: null, // No disponible en historial de peso
      fecha: DateTime.parse(json['FechaRegistro'] ?? json['fecha']),
      notas: json['Observaciones'] ?? json['notas'],
    );
  }

  // Helper para parsear doubles de manera segura
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Desde datos locales
  factory MetricaCorporal.fromJson(Map<String, dynamic> json) {
    return MetricaCorporal(
      id: json['id'],
      usuarioId: json['usuarioId'],
      peso: _parseDouble(json['peso']),
      imc: _parseDouble(json['imc']),
      grasaCorporal: _parseDouble(json['grasaCorporal']),
      masaMuscular: _parseDouble(json['masaMuscular']),
      fecha: DateTime.parse(json['fecha']),
      notas: json['notas'],
    );
  }

  // Calcular IMC si no está presente
  double calculateIMC(double altura) {
    return peso / ((altura / 100) * (altura / 100));
  }

  // Crear copia con nuevos valores
  MetricaCorporal copyWith({
    String? id,
    String? usuarioId,
    double? peso,
    double? imc,
    double? grasaCorporal,
    double? masaMuscular,
    DateTime? fecha,
    String? notas,
  }) {
    return MetricaCorporal(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      peso: peso ?? this.peso,
      imc: imc ?? this.imc,
      grasaCorporal: grasaCorporal ?? this.grasaCorporal,
      masaMuscular: masaMuscular ?? this.masaMuscular,
      fecha: fecha ?? this.fecha,
      notas: notas ?? this.notas,
    );
  }
}
