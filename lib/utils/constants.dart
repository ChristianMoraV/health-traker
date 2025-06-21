/// Constantes globales de la aplicación
class AppConstants {
  // Información de la app
  static const String appName = 'Health Tracker';
  static const String appVersion = '1.0.0';
  
  // Configuraciones de UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  static const double defaultElevation = 4.0;
  static const double smallElevation = 2.0;
  static const double largeElevation = 8.0;
  
  // Configuraciones de formularios
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  
  // Configuraciones de salud
  static const double minWeight = 30.0; // kg
  static const double maxWeight = 300.0; // kg
  static const double minHeight = 100.0; // cm
  static const double maxHeight = 250.0; // cm
  static const int minAge = 13;
  static const int maxAge = 100;
  
  // Niveles de actividad
  static const List<String> activityLevels = [
    'Sedentario',
    'Ligeramente activo',
    'Moderadamente activo',
    'Muy activo',
    'Extremadamente activo',
  ];
  
  // Objetivos de fitness
  static const List<String> fitnessGoals = [
    'Perder peso',
    'Mantener peso',
    'Ganar músculo',
    'Definición muscular',
  ];
  
  // Configuraciones de estimación
  static const int defaultTimelineWeeks = 12;
  static const double defaultProteinPerKg = 2.2; // gramos por kg
  static const double defaultFatPercentage = 0.25; // 25% de calorías totales
}
