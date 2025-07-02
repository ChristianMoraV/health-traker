class User {
  final String? id; // UUID como String
  final String name;
  final String email;
  final String? password; // Opcional para actualizaciones
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String objective;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password, // Ya no es requerido
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.objective,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  // Para enviar al backend (mapear a nombres del backend)
  Map<String, dynamic> toJsonForBackend() {
    Map<String, dynamic> data = {
      'CorreoElectronico': email,
      'Nombre': name,
      'Edad': age,
      'Genero': _mapGenderForBackend(gender),
      'Altura': height,
      'PesoInicial': weight,
      'NivelActividad': _mapActivityLevelForBackend(activityLevel),
      'ObjetivoFisico': _mapObjectiveForBackend(objective),
    };
    
    // Agregar contraseña solo si está presente (para registro)
    if (password != null && password!.isNotEmpty) {
      data['HashContrasena'] = password;
    }
    
    return data;
  }

  // Mapear género al formato del backend
  String _mapGenderForBackend(String gender) {
    switch (gender.toLowerCase()) {
      case 'hombre':
      case 'masculino':
      case 'male':
        return 'masculino';
      case 'mujer':
      case 'femenino':
      case 'female':
        return 'femenino';
      default:
        return 'masculino'; // valor por defecto
    }
  }

  // Mapear nivel de actividad al formato del backend
  String _mapActivityLevelForBackend(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentario':
      case 'sedentary':
        return 'sedentario';
      case 'ligero':
      case 'light':
        return 'ligero';
      case 'moderado':
      case 'moderate':
        return 'moderado';
      case 'activo':
      case 'active':
        return 'activo';
      case 'muy_activo':
      case 'very_active':
      case 'muy activo':
        return 'muy_activo';
      default:
        return 'moderado'; // valor por defecto
    }
  }

  // Mapear objetivo al formato del backend
  String _mapObjectiveForBackend(String objective) {
    switch (objective.toLowerCase()) {
      case 'perder peso':
      case 'perder_peso':
      case 'lose_weight':
      case 'definicion':
        return 'perder_peso';
      case 'ganar peso':
      case 'ganar_peso':
      case 'gain_weight':
      case 'volumen':
        return 'ganar_peso';
      case 'mantener peso':
      case 'mantener_peso':
      case 'maintain_weight':
      case 'mantenimiento':
        return 'mantener_peso';
      case 'ganar musculo':
      case 'ganar_musculo':
      case 'gain_muscle':
        return 'ganar_musculo';
      case 'mejorar resistencia':
      case 'mejorar_resistencia':
      case 'improve_endurance':
        return 'mejorar_resistencia';
      default:
        return 'mantener_peso'; // valor por defecto
    }
  }

  // Para uso local (mantener compatibilidad)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'objective': objective,
    };
  }

  // Crear usuario desde respuesta del login (campos diferentes)
  factory User.fromLoginResponse(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['nombre'] ?? '',
      email: json['email'] ?? '',
      age: json['edad'] ?? 0,
      gender: json['genero'] ?? 'masculino',
      height: _parseDouble(json['altura']),
      weight: _parseDouble(json['peso_inicial']),
      activityLevel: json['nivel_actividad'] ?? 'moderado',
      objective: json['objetivo_fisico'] ?? 'mantener_peso',
    );
  }

  // Crear usuario desde respuesta del backend
  factory User.fromJsonBackend(Map<String, dynamic> json) {
    return User(
      id: json['IdUsuario']?.toString(),
      name: json['Nombre'] ?? '',
      email: json['CorreoElectronico'] ?? '',
      age: json['Edad'] ?? 0,
      gender: json['Genero'] ?? 'masculino',
      height: _parseDouble(json['Altura']),
      weight: _parseDouble(json['PesoInicial']),
      activityLevel: json['NivelActividad'] ?? 'moderado',
      objective: json['ObjetivoFisico'] ?? 'mantener_peso',
    );
  }

  // Método auxiliar para parsear doubles
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Crear usuario desde JSON local (mantener compatibilidad)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 'masculino',
      height: _parseDouble(json['height']),
      weight: _parseDouble(json['weight']),
      activityLevel: json['activityLevel'] ?? 'moderado',
      objective: json['objective'] ?? 'mantener_peso',
    );
  }
}
