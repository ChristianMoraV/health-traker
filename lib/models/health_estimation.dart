class HealthEstimation {
  final double tmb; // Tasa Metabólica Basal
  final double tdee; // Gasto Energético Total Diario
  final double targetCalories;
  final double expectedWeightChange;
  final int timeToGoal;
  final double targetWeight;
  final Macronutrients macros;
  final List<WeeklyProgress> weeklyProgress;
  final String objective;

  HealthEstimation({
    required this.tmb,
    required this.tdee,
    required this.targetCalories,
    required this.expectedWeightChange,
    required this.timeToGoal,
    required this.targetWeight,
    required this.macros,
    required this.weeklyProgress,
    required this.objective,
  });
}

class Macronutrients {
  final double protein;
  final double fat;
  final double carbs;

  Macronutrients({
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  double get proteinCalories => protein * 4;
  double get fatCalories => fat * 9;
  double get carbsCalories => carbs * 4;
  double get totalCalories => proteinCalories + fatCalories + carbsCalories;

  double proteinPercentage(double totalCals) => (proteinCalories / totalCals) * 100;
  double fatPercentage(double totalCals) => (fatCalories / totalCals) * 100;
  double carbsPercentage(double totalCals) => (carbsCalories / totalCals) * 100;
}

class WeeklyProgress {
  final int week;
  final double weight;
  final double progress;

  WeeklyProgress({
    required this.week,
    required this.weight,
    required this.progress,
  });
}

class MealDistribution {
  static const double breakfast = 0.25;
  static const double lunch = 0.35;
  static const double dinner = 0.30;
  static const double snacks = 0.10;

  static double breakfastCalories(double totalCalories) => totalCalories * breakfast;
  static double lunchCalories(double totalCalories) => totalCalories * lunch;
  static double dinnerCalories(double totalCalories) => totalCalories * dinner;
  static double snacksCalories(double totalCalories) => totalCalories * snacks;
}
