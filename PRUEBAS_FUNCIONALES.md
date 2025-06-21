# 🧪 Guía de Pruebas Funcionales - Health Tracker

## ✅ **Lista de Verificación Completa**

### 🔐 **1. Sistema de Autenticación**

#### **Login Screen**
- [ ] El gradiente azul-verde se muestra correctamente
- [ ] Validación de email (formato correcto)
- [ ] Validación de contraseña (mínimo 6 caracteres)
- [ ] Botón de mostrar/ocultar contraseña funciona
- [ ] Simulación de carga al hacer login
- [ ] Link para cambiar a registro funciona
- [ ] Login exitoso redirige al dashboard

**Datos de prueba:**
- Email: `test@example.com`
- Password: `123456`

#### **Register Screen (3 Pasos)**

**Paso 1 - Información Personal:**
- [ ] Validación de nombre (requerido)
- [ ] Validación de email (formato y único)
- [ ] Validación de contraseñas (coincidencia, mínimo 6 caracteres)
- [ ] Botón "Siguiente" habilitado solo con datos válidos

**Paso 2 - Datos Físicos:**
- [ ] Selección de edad (18-100)
- [ ] Dropdown de género funciona
- [ ] Validación de altura (100-250 cm)
- [ ] Validación de peso (30-300 kg)
- [ ] Dropdown de nivel de actividad funciona
- [ ] Barra de progreso muestra 66%

**Paso 3 - Objetivos:**
- [ ] Tarjetas de objetivos seleccionables
- [ ] Solo un objetivo seleccionable a la vez
- [ ] Barra de progreso muestra 100%
- [ ] Registro exitoso redirige al dashboard

### 🏠 **2. Dashboard Principal**

#### **Elementos de UI**
- [ ] Saludo dinámico según la hora del día
- [ ] Información del usuario correcta (nombre, email)
- [ ] Cálculo de IMC automático y categoría
- [ ] Objetivo del usuario mostrado correctamente

#### **Resumen Rápido**
- [ ] Tarjeta de IMC con valor calculado
- [ ] Estado de salud basado en IMC
- [ ] Objetivo actual del usuario
- [ ] Acceso rápido a estimación

#### **Acciones Rápidas** (4 tarjetas)
- [ ] "Calcular IMC" - muestra datos actuales
- [ ] "Mi Progreso" - navega a estimación (pestaña Progreso)
- [ ] "Mis Objetivos" - muestra objetivo actual
- [ ] "Estimación IA" - navega a estimación

#### **Progreso Semanal**
- [ ] Métricas actuales vs objetivos
- [ ] Progreso visual con barras
- [ ] Datos coherentes con perfil del usuario

#### **Sección de IA**
- [ ] Recomendaciones personalizadas (simuladas)
- [ ] Predicciones basadas en datos
- [ ] Llamada a acción para ver más detalles

#### **Navegación**
- [ ] Botón de configuración navega correctamente
- [ ] Botón de logout funciona

### 📊 **3. Pantalla de Estimación**

#### **Estructura General**
- [ ] 3 pestañas visibles: Resumen, Nutrición, Progreso
- [ ] Navegación entre pestañas fluida
- [ ] Botón de "Volver" al dashboard

#### **Pestaña Resumen**
- [ ] Objetivo personalizado mostrado
- [ ] Cálculo de TMB correcto (fórmula Mifflin-St Jeor)
- [ ] Cálculo de TDEE basado en nivel de actividad
- [ ] Tiempo estimado a meta (12 semanas)
- [ ] Recomendaciones específicas según objetivo

#### **Pestaña Nutrición**
- [ ] Calorías objetivo calculadas correctamente
- [ ] Distribución de macronutrientes:
  - Proteínas: 25-30%
  - Carbohidratos: 40-50%
  - Grasas: 25-30%
- [ ] Plan de comidas con porcentajes
- [ ] Valores nutricionales coherentes

#### **Pestaña Progreso**
- [ ] Timeline de 12 semanas
- [ ] Progreso semanal simulado
- [ ] Meta final clara
- [ ] Evolución del peso realista
- [ ] Gráfico de progreso visual

### ⚙️ **4. Pantalla de Configuración**

#### **Secciones Principales**
- [ ] Perfil del Usuario
- [ ] Configuración de Salud
- [ ] Configuración de App
- [ ] Configuración de IA
- [ ] Datos y Privacidad

#### **Perfil del Usuario**
- [ ] Datos actuales mostrados correctamente
- [ ] Botón "Editar Perfil" (preparado para funcionalidad)

#### **Configuración de Salud**
- [ ] Métricas actuales (peso, altura, actividad)
- [ ] Última actualización mostrada
- [ ] Botón para actualizar datos

#### **Configuración de App**
- [ ] Switches de notificaciones
- [ ] Configuración de biometría
- [ ] Modo oscuro (preparado)

#### **Configuración de IA**
- [ ] Opciones de personalización
- [ ] Frecuencia de recomendaciones
- [ ] Nivel de análisis

#### **Datos y Privacidad**
- [ ] Opciones de exportar datos
- [ ] Configuración de privacidad
- [ ] Opción de eliminar cuenta

### 🧮 **5. Cálculos de Salud**

#### **Verificaciones Matemáticas**
- [ ] IMC = peso(kg) / altura(m)²
- [ ] TMB Hombre = 88.362 + (13.397 × peso) + (4.799 × altura) - (5.677 × edad)
- [ ] TMB Mujer = 447.593 + (9.247 × peso) + (3.098 × altura) - (4.330 × edad)
- [ ] TDEE = TMB × factor_actividad
- [ ] Calorías objetivo ajustadas según meta (+/- 300-500 cal)

#### **Casos de Prueba Específicos**

**Usuario Ejemplo 1:**
- Hombre, 25 años, 175cm, 70kg, moderado, volumen
- IMC esperado: 22.9 (Normal)
- TMB esperado: ~1,750 kcal
- TDEE esperado: ~2,400 kcal
- Objetivo: +400 kcal (2,800 kcal totales)

**Usuario Ejemplo 2:**
- Mujer, 30 años, 165cm, 60kg, sedentario, definición
- IMC esperado: 22.0 (Normal)
- TMB esperado: ~1,350 kcal
- TDEE esperado: ~1,620 kcal
- Objetivo: -400 kcal (1,220 kcal totales)

## 🎯 **Pruebas de Flujo Completo**

### **Flujo 1: Usuario Nuevo**
1. Abrir app → Login Screen
2. Ir a "Crear cuenta"
3. Completar 3 pasos de registro
4. Ver dashboard personalizado
5. Navegar a estimación
6. Revisar las 3 pestañas
7. Ir a configuración
8. Volver al dashboard

### **Flujo 2: Usuario Existente**
1. Login con credenciales
2. Ver dashboard actualizado
3. Usar acciones rápidas
4. Verificar cálculos en estimación
5. Actualizar configuración
6. Logout y volver a login

## 🚨 **Puntos Críticos de Verificación**

### **Responsividad**
- [ ] UI se adapta a diferentes tamaños de pantalla
- [ ] Textos legibles en dispositivos pequeños
- [ ] Botones tienen tamaño adecuado para toque

### **Performance**
- [ ] Transiciones suaves entre pantallas
- [ ] Carga rápida de datos
- [ ] No lag en la navegación

### **Validaciones**
- [ ] Todos los campos requeridos validados
- [ ] Mensajes de error claros
- [ ] Rangos de datos coherentes

### **Consistencia Visual**
- [ ] Paleta de colores azul-blanco-verde
- [ ] Tipografía consistente
- [ ] Espaciado y alineación uniformes

## ✨ **Comentarios TODO Verificados**

- [ ] AuthFlow: Lógica de autenticación comentada
- [ ] HomeScreen: Integración de IA comentada
- [ ] EstimationScreen: Modelos ML comentados
- [ ] SettingsScreen: Configuración IA comentada
- [ ] Servicios: APIs externas comentadas

## 🎉 **¡Checklist de Entrega Completo!**

- [ ] ✅ Todas las pantallas funcionando
- [ ] ✅ Navegación completa implementada
- [ ] ✅ Cálculos de salud precisos
- [ ] ✅ UI/UX según especificaciones
- [ ] ✅ Comentarios TODO para IA
- [ ] ✅ Código bien estructurado
- [ ] ✅ Documentación completa

---

**¡La aplicación está lista para integrar la lógica de negocio y modelos de IA!** 🚀
