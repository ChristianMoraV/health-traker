# 🏥 Health Tracker - Flutter App

Aplicación móvil para seguimiento de salud y fitness con cálculos personalizados de métricas corporales.

## 🛠️ Requisitos Previos

### 1. Flutter SDK
```bash
flutter --version
```
**Versión mínima:** Flutter 3.0.0+

### 2. Android Studio
- Solo para Android SDK y configuración inicial del emulador
- **NO necesitas abrirlo para desarrollar**

### 3. Visual Studio Code
Con las extensiones:
- Flutter
- Dart

### 4. Verificar Configuración
```bash
flutter doctor
```
Asegúrate de que todos los elementos tengan ✅

## 📥 Instalación

```bash
# 1. Clonar repositorio
git clone https://github.com/ChristianMoraV/health-traker.git
cd health-traker

# 2. Instalar dependencias
flutter pub get
```

## 🚀 Ejecutar la Aplicación

### 🎯 **Método Recomendado: VS Code**

1. **Abrir emulador:**
   - `Ctrl + Shift + P`
   - Buscar: `Flutter: Launch Emulator`
   - Seleccionar emulador

2. **Ejecutar app:**
   - Presionar `F5`

### 🔧 **Método Alternativo: Terminal**

```bash
# Ver emuladores disponibles
flutter emulators

# Abrir emulador específico
flutter emulators --launch <emulator_id>

# Ejecutar app
flutter run
```

## ⚡ Desarrollo

Una vez ejecutando:
- **`Ctrl + S`** = Hot Reload automático
- **`r`** en terminal = Hot Reload manual
- **`R`** en terminal = Hot Restart
- **`q`** en terminal = Salir

## 🧪 Datos de Prueba

- **Email:** cualquier email válido
- **Contraseña:** cualquier contraseña
- **Datos físicos:** Edad: 25, Altura: 175cm, Peso: 70kg

## 🔧 Comandos Útiles

```bash
flutter pub get          # Instalar dependencias
flutter clean           # Limpiar proyecto
flutter analyze         # Analizar código
flutter build apk       # Construir APK
```

## 🐛 Solución de Problemas

```bash
# Sin dispositivos conectados
flutter emulators --launch <emulator_id>

# Error de dependencias
flutter clean && flutter pub get

# Error de build
flutter clean && flutter pub get && flutter build apk
```

## 🚀 Quick Start

```bash
git clone https://github.com/ChristianMoraV/health-traker.git
cd health-traker
flutter pub get
```

En VS Code: `Ctrl + Shift + P` → `Flutter: Launch Emulator` → `F5`

---

**👨‍💻 Autor:** [Christian Mora](https://github.com/ChristianMoraV)
