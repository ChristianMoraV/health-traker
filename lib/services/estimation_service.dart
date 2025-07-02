import '../models/user.dart';
import '../models/health_estimation.dart';
import 'api_service.dart';
import 'auth_service.dart';

class EstimationService {
  /// Obtener predicción usando IA del backend
  static Future<HealthEstimation> getAIPrediction(User user) async {
    if (AuthService.currentUserId == null) {
      throw Exception('No hay usuario logueado');
    }

    try {
      // Preparar datos para enviar al backend
      final requestData = {
        'edad': user.age,
        'genero': user.gender,
        'altura': user.height,
        'peso': user.weight,
        'nivel_actividad': user.activityLevel,
        'objetivo': user.objective,
      };

      // Llamar al endpoint de predicción simple
      final response = await ApiService.post('/predicciones/simple', requestData);
      
      // Convertir respuesta del backend a modelo local
      return _convertBackendResponse(response, user);
    } catch (e) {
      throw Exception('Error al obtener predicción: $e');
    }
  }

  /// Obtener métricas corporales del usuario
  static Future<List<Map<String, dynamic>>> getMetricasUsuario() async {
    if (AuthService.currentUserId == null) {
      throw Exception('No hay usuario logueado');
    }

    try {
      final response = await ApiService.get('/metricas-corporales/${AuthService.currentUserId}');
      
      if (response['metricas'] != null) {
        return List<Map<String, dynamic>>.from(response['metricas']);
      }
      
      return [];
    } catch (e) {
      throw Exception('Error al obtener métricas: $e');
    }
  }

  /// Guardar nueva métrica corporal
  static Future<void> saveMetrica(Map<String, dynamic> metricaData) async {
    if (AuthService.currentUserId == null) {
      throw Exception('No hay usuario logueado');
    }

    try {
      final requestData = {
        'usuario_id': AuthService.currentUserId,
        ...metricaData,
      };

      await ApiService.post('/metricas-corporales/', requestData);
    } catch (e) {
      throw Exception('Error al guardar métrica: $e');
    }
  }

  /// Convertir respuesta del backend a modelo HealthEstimation
  static HealthEstimation _convertBackendResponse(Map<String, dynamic> response, User user) {
    // Extraer datos de la predicción
    final prediccion = response['prediccion'] ?? {};
    
    // Calcular macronutrientes basado en las calorías objetivo
    final targetCalories = (prediccion['calorias_objetivo'] ?? 2000).toDouble();
    final protein = (targetCalories * 0.25) / 4; // 25% proteína
    final fat = (targetCalories * 0.25) / 9; // 25% grasa
    final carbs = (targetCalories * 0.50) / 4; // 50% carbohidratos

    final macros = Macronutrients(
      protein: protein,
      fat: fat,
      carbs: carbs,
    );

    // Generar progreso semanal basado en la predicción
    final weeklyProgress = List.generate(12, (i) {
      final week = i + 1;
      final pesoObjetivo = (prediccion['peso_objetivo'] ?? user.weight).toDouble();
      final progresoPorSemana = (pesoObjetivo - user.weight) / 12;
      
      return WeeklyProgress(
        week: week,
        weight: user.weight + (progresoPorSemana * i),
        progress: (week / 12) * 100,
      );
    });

    return HealthEstimation(
      tmb: (prediccion['tmb'] ?? 1500).toDouble(),
      tdee: (prediccion['tdee'] ?? 2000).toDouble(),
      targetCalories: targetCalories,
      expectedWeightChange: (prediccion['cambio_peso_semanal'] ?? 0).toDouble(),
      timeToGoal: (prediccion['tiempo_objetivo'] ?? 12).toInt(),
      targetWeight: (prediccion['peso_objetivo'] ?? user.weight).toDouble(),
      macros: macros,
      weeklyProgress: weeklyProgress,
      objective: user.objective,
    );
  }
}
