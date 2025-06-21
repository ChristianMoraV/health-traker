import '../models/user.dart';
import '../models/health_estimation.dart';

class HealthCalculatorService {
  static const Map<String, double> activityFactors = {
    'sedentario': 1.2,
    'ligero': 1.375,
    'moderado': 1.55,
    'activo': 1.725,
    'muy-activo': 1.9,
  };

  /// Calcular TMB usando la fórmula de Mifflin-St Jeor
  static double calculateTMB(User user) {
    if (user.gender == 'masculino') {
      return 88.362 + (13.397 * user.weight) + (4.799 * user.height) - (5.677 * user.age);
    } else {
      return 447.593 + (9.247 * user.weight) + (3.098 * user.height) - (4.33 * user.age);
    }
  }

  /// Calcular TDEE (TMB * factor de actividad)
  static double calculateTDEE(double tmb, String activityLevel) {
    final factor = activityFactors[activityLevel] ?? 1.55;
    return tmb * factor;
  }

  /// Calcular estimación completa
  static HealthEstimation calculateEstimation(User user) {
    final tmb = calculateTMB(user);
    final tdee = calculateTDEE(tmb, user.activityLevel);
    
    double targetCalories = tdee;
    double expectedWeightChange = 0;
    int timeToGoal = 12;
    double targetWeight = user.weight;

    // Ajustar según el objetivo
    switch (user.objective) {
      case 'definicion':
        targetCalories = tdee - 500; // Déficit de 500 kcal
        expectedWeightChange = -0.5; // kg por semana
        timeToGoal = ((user.weight * 0.15) / 0.5).round(); // Perder 15% del peso
        targetWeight = user.weight * 0.85;
        break;
      case 'volumen':
        targetCalories = tdee + 300; // Superávit de 300 kcal
        expectedWeightChange = 0.3; // kg por semana
        timeToGoal = ((user.weight * 0.1) / 0.3).round(); // Ganar 10% del peso
        targetWeight = user.weight * 1.1;
        break;
      case 'mantenimiento':
        targetCalories = tdee;
        expectedWeightChange = 0;
        timeToGoal = 12;
        targetWeight = user.weight;
        break;
    }

    // Calcular macronutrientes
    final proteinPerKg = user.objective == 'definicion' ? 2.2 : 1.8;
    final protein = user.weight * proteinPerKg;
    final fat = (targetCalories * 0.25) / 9;
    final carbs = (targetCalories - (protein * 4) - (fat * 9)) / 4;

    final macros = Macronutrients(
      protein: protein,
      fat: fat,
      carbs: carbs,
    );

    // Generar progreso semanal
    final weeklyProgress = List.generate(12, (i) {
      final week = i + 1;
      double weeklyWeight;
      
      if (user.objective == 'definicion') {
        weeklyWeight = user.weight - (i * 0.5);
      } else if (user.objective == 'volumen') {
        weeklyWeight = user.weight + (i * 0.3);
      } else {
        weeklyWeight = user.weight;
      }
      
      return WeeklyProgress(
        week: week,
        weight: weeklyWeight,
        progress: (week / 12) * 100,
      );
    });

    return HealthEstimation(
      tmb: tmb,
      tdee: tdee,
      targetCalories: targetCalories,
      expectedWeightChange: expectedWeightChange,
      timeToGoal: timeToGoal,
      targetWeight: targetWeight,
      macros: macros,
      weeklyProgress: weeklyProgress,
      objective: user.objective,
    );
  }

  /// Obtener recomendaciones según el objetivo
  static List<String> getRecommendations(String objective) {
    switch (objective) {
      case 'definicion':
        return [
          'Mantén un déficit de 500 kcal diarias',
          '3-4 sesiones de cardio + entrenamiento de fuerza',
          'Consume 2.2g de proteína por kg de peso corporal',
          'Bebe al menos 2-3 litros de agua al día',
        ];
      case 'volumen':
        return [
          'Consume 300 kcal extra diarias',
          '4-5 sesiones semanales con pesos progresivos',
          'Prioriza ejercicios compuestos',
          'Descansa 7-9 horas por noche',
        ];
      case 'mantenimiento':
        return [
          'Mantén tu ingesta calórica actual',
          '3-4 sesiones de ejercicio por semana',
          'Combina cardio y entrenamiento de fuerza',
          'Mantén una dieta balanceada',
        ];
      default:
        return [];
    }
  }
}
