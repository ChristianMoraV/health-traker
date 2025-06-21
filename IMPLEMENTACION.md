# 🏥 Health Tracker - Aplicación Flutter

## 📋 Resumen del Proyecto

Aplicación móvil de seguimiento de salud desarrollada en Flutter que replica el diseño de una aplicación Next.js, con funcionalidades avanzadas para estimación de métricas de salud y recomendaciones personalizadas.

## 🎨 Características de Diseño

- **Paleta de colores**: Azul, blanco y verde
- **Gradientes**: Transiciones suaves azul-verde
- **Material Design 3**: Componentes modernos y accesibles
- **Diseño responsivo**: Optimizado para dispositivos móviles

## 🔧 Funcionalidades Implementadas

### 🔐 **Sistema de Autenticación**
- **Login Screen**: 
  - Validación de formularios
  - Mostrar/ocultar contraseña
  - Simulación de carga
  - Gradientes y animaciones

- **Register Screen** (3 pasos):
  - **Paso 1**: Información personal (nombre, email, contraseñas)
  - **Paso 2**: Datos físicos (edad, género, altura, peso, nivel de actividad)
  - **Paso 3**: Selección de objetivos (volumen, definición, mantenimiento)
  - Barra de progreso visual
  - Validación completa de datos

### 🏠 **Dashboard Principal**
- **Pantalla de inicio personalizada**:
  - Saludo dinámico según la hora
  - Resumen rápido de salud (IMC, estado, objetivo)
  - Acciones rápidas (Calcular IMC, Mi Progreso, Objetivos, Estimación)
  - Progreso semanal con métricas clave
  - **Sección de IA**: Predicciones y recomendaciones personalizadas

### 📊 **Pantalla de Estimación** (3 pestañas)
- **Resumen**:
  - Objetivo y meta personalizada
  - Métricas metabólicas (TMB, TDEE)
  - Recomendaciones específicas según objetivo

- **Nutrición**:
  - Plan nutricional diario con calorías objetivo
  - Distribución de macronutrientes (proteínas, carbos, grasas)
  - Distribución de comidas por porcentajes

- **Progreso**:
  - Timeline de 12 semanas con progreso estimado
  - Evolución del peso semana a semana
  - Meta final visualizada

### ⚙️ **Pantalla de Configuración**
- **Perfil del usuario**: Edición de datos personales
- **Configuración de salud**: Actualización de métricas físicas
- **Configuración de app**: Notificaciones, biometría, modo oscuro
- **Configuración de IA**: Preferencias de recomendaciones
- **Datos y privacidad**: Exportar datos, eliminar cuenta

## 🧠 Integración con IA/ML

### 📍 **Puntos de Integración Comentados**

1. **Análisis de Progreso** (`HomeScreen`):
   ```dart
   // TODO: Aquí puedes agregar tu lógica de negocio con IA
   // - Análisis de progreso con modelos de regresión
   // - Predicciones personalizadas basadas en datos históricos
   // - Recomendaciones inteligentes usando ML
   ```

2. **Estimaciones Avanzadas** (`EstimationScreen`):
   ```dart
   // TODO: Aquí puedes integrar tu modelo de IA/ML para estimaciones más precisas
   // - Análisis de composición corporal con IA
   // - Predicciones basadas en datos históricos similares
   // - Ajustes personalizados según patrones de comportamiento
   ```

3. **Autenticación** (`AuthFlow`):
   ```dart
   // TODO: Aquí puedes agregar tu lógica de autenticación real
   // Ejemplo: await AuthService.login(email, password);
   ```

4. **Configuración de IA** (`SettingsScreen`):
   ```dart
   // TODO: Aquí puedes agregar tu lógica de configuración con IA
   // - Personalización automática basada en patrones de uso
   // - Ajustes inteligentes de notificaciones
   // - Optimización de la experiencia del usuario usando ML
   ```

## 🏗️ Arquitectura del Proyecto

```
lib/
├── 📱 app/
│   ├── 🔐 auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── widgets/
│   ├── 📊 dashboard/
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   └── settings_screen.dart
│   │   └── widgets/
│   │       └── metric_widgets.dart
│   └── 📈 estimation/
│       └── screens/
│           └── estimation_screen.dart
├── 🧩 components/
│   ├── buttons/
│   │   └── primary_button.dart
│   ├── forms/
│   │   ├── custom_text_field.dart
│   │   └── custom_dropdown.dart
│   └── cards/
│       └── info_card.dart
├── 📋 models/
│   ├── user.dart
│   └── health_estimation.dart
├── 🔧 services/
│   └── health_calculator_service.dart
├── 🎨 utils/
│   ├── colors.dart
│   └── constants.dart
└── 🛤️ routes/
    └── route_names.dart
```

## 🔬 Cálculos de Salud Implementados

### Métricas Básicas
- **IMC**: Cálculo automático peso/altura²
- **TMB**: Fórmula Mifflin-St Jeor (diferenciada por género)
- **TDEE**: TMB × factor de actividad

### Estimaciones Personalizadas
- **Calorías objetivo**: Ajustadas según objetivo (déficit/superávit)
- **Macronutrientes**: Distribución proteínas/carbos/grasas
- **Progreso semanal**: Simulación de 12 semanas
- **Tiempo a meta**: Cálculo basado en cambio semanal esperado

## 🚀 Próximos Pasos para Integración con IA

### 1. **Modelos de Regresión**
- Implementar modelos para predecir progreso real vs estimado
- Análisis de patrones de comportamiento del usuario
- Ajuste dinámico de recomendaciones

### 2. **Sistema de Recomendaciones**
- Motor de IA para sugerencias nutricionales personalizadas
- Recomendaciones de ejercicio basadas en progreso
- Alertas inteligentes sobre desviaciones del plan

### 3. **Análisis Predictivo**
- Predicción de adherencia al plan
- Estimación de probabilidad de éxito
- Identificación temprana de riesgos

### 4. **Procesamiento de Lenguaje Natural**
- Chat bot para consultas de salud
- Análisis de notas del usuario
- Generación automática de reportes

## 📱 Instrucciones de Uso

1. **Instalar dependencias**: `flutter pub get`
2. **Ejecutar la app**: `flutter run`
3. **Probar el flujo completo**:
   - Registrarse con datos reales
   - Explorar el dashboard
   - Ver estimaciones personalizadas
   - Configurar preferencias

## 🎯 **Estado Actual: ¡FRONTEND COMPLETO!**

✅ Sistema de autenticación  
✅ Dashboard con métricas en tiempo real  
✅ Estimaciones con 3 pestañas  
✅ Configuración completa  
✅ Componentes reutilizables  
✅ Cálculos de salud funcionales  
✅ Puntos de integración para IA comentados  

**¡Listo para integrar tu lógica de negocio y modelos de IA!** 🚀
