import 'package:flutter/material.dart';

/// Paleta de colores para la aplicación de salud
/// Basada en los colores azul, blanco y verde especificados
class AppColors {
  // Colores primarios
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color white = Color(0xFFFFFFFF);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryGreen],
  );
  
  // Variaciones de azul
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color darkBlue = Color(0xFF1E40AF);
  static const Color blueAccent = Color(0xFF60A5FA);
  
  // Variaciones de verde
  static const Color lightGreen = Color(0xFF34D399);
  static const Color darkGreen = Color(0xFF059669);
  static const Color greenAccent = Color(0xFF6EE7B7);
  
  // Colores neutros
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color borderColor = Color(0xFFE2E8F0); // Color para bordes
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  
  // Colores de estado
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Sombras
  static const Color shadow = Color(0x1A000000);
}
