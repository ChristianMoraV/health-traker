import 'package:flutter/material.dart';
import '../../../components/cards/info_card.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../models/user.dart';
import '../../../models/health_estimation.dart';
import '../../../services/health_calculator_service.dart';
import '../../../services/prediction_service.dart';

class EstimationScreen extends StatefulWidget {
  final User user;
  final VoidCallback onBack;

  const EstimationScreen({
    super.key,
    required this.user,
    required this.onBack,
  });

  @override
  State<EstimationScreen> createState() => _EstimationScreenState();
}

class _EstimationScreenState extends State<EstimationScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HealthEstimation? _estimation;
  bool _isCalculating = true;
  int _selectedDays = 30; // Días para la predicción

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateEstimation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _calculateEstimation() async {
    setState(() {
      _isCalculating = true;
    });

    try {
      // Verificar que el usuario tenga ID
      if (widget.user.id == null) {
        throw Exception('Usuario sin ID válido');
      }

      // Usar PredictionService para obtener predicción con IA real
      final predictions = await PredictionService.predictWeight(widget.user.id!, days: _selectedDays);
      
      // Calcular métricas básicas manualmente
      final currentWeight = predictions['peso_actual']?.toDouble() ?? widget.user.weight;
      final predictedWeight = predictions['peso_predicho']?.toDouble() ?? widget.user.weight;
      final weightChange = predictions['cambio_estimado']?.toDouble() ?? 0.0;
      
      // Calcular TMB (Tasa Metabólica Basal) usando fórmula de Harris-Benedict
      final tmb = widget.user.gender == 'Masculino' 
          ? (88.362 + (13.397 * currentWeight) + (4.799 * widget.user.height) - (5.677 * widget.user.age))
          : (447.593 + (9.247 * currentWeight) + (3.098 * widget.user.height) - (4.330 * widget.user.age));
      
      // Calcular TDEE basado en nivel de actividad
      double activityMultiplier = 1.2; // Sedentario por defecto
      switch (widget.user.activityLevel) {
        case 'Bajo':
          activityMultiplier = 1.375;
          break;
        case 'Moderado':
          activityMultiplier = 1.55;
          break;
        case 'Alto':
          activityMultiplier = 1.725;
          break;
        case 'Muy Alto':
          activityMultiplier = 1.9;
          break;
      }
      final tdee = tmb * activityMultiplier;
      
      // Calcular calorías objetivo basado en objetivo
      double targetCalories = tdee;
      switch (widget.user.objective) {
        case 'perder_peso':
          targetCalories = tdee - 500; // Déficit de 500 cal
          break;
        case 'ganar_peso':
        case 'ganar_musculo':
          targetCalories = tdee + 300; // Superávit de 300 cal
          break;
        case 'mantener_peso':
        default:
          targetCalories = tdee;
          break;
      }
      
      // Macronutrientes basados en calorías objetivo
      final macros = Macronutrients(
        protein: currentWeight * 2.2, // 2.2g por kg de peso
        fat: targetCalories * 0.25 / 9, // 25% de calorías de grasa
        carbs: (targetCalories - (currentWeight * 2.2 * 4) - (targetCalories * 0.25)) / 4,
      );
      
      // Progreso semanal simulado basado en predicción
      final weeklyProgress = List<WeeklyProgress>.generate(4, (index) {
        final progressWeight = currentWeight + (weightChange * (index + 1) / 4);
        return WeeklyProgress(
          week: index + 1,
          weight: progressWeight,
          progress: ((progressWeight - currentWeight) / weightChange * 100).clamp(0, 100),
        );
      });
      
      // Crear estimación
      final estimation = HealthEstimation(
        tmb: tmb,
        tdee: tdee,
        targetCalories: targetCalories,
        expectedWeightChange: weightChange,
        timeToGoal: 4, // 4 semanas basado en predicción de 30 días
        targetWeight: predictedWeight,
        macros: macros,
        weeklyProgress: weeklyProgress,
        objective: widget.user.objective,
      );
      
      setState(() {
        _estimation = estimation;
        _isCalculating = false;
      });
    } catch (e) {
      print('Error al obtener predicción IA: $e');
      
      // Fallback: usar cálculo local si falla la IA
      try {
        await Future.delayed(const Duration(seconds: 1));
        final estimation = HealthCalculatorService.calculateEstimation(widget.user);
        
        setState(() {
          _estimation = estimation;
          _isCalculating = false;
        });
      } catch (fallbackError) {
        print('Error en cálculo fallback: $fallbackError');
        setState(() {
          _estimation = null;
          _isCalculating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCalculating) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F9FF), // blue-50
              Color(0xFFF0FDF4), // green-50
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSummaryTab(),
                    _buildNutritionTab(),
                    _buildProgressTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F9FF), // blue-50
              Color(0xFFF0FDF4), // green-50
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Calculando tu estimación...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Analizando tus métricas y objetivos',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              const LinearProgressIndicator(
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
              const SizedBox(height: 16),
              const Text(
                'Procesando con IA...',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Estimación Personalizada',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Selector de días para predicción
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Predicción a:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedDays,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('1 semana')),
                        DropdownMenuItem(value: 14, child: Text('2 semanas')),
                        DropdownMenuItem(value: 30, child: Text('1 mes')),
                        DropdownMenuItem(value: 60, child: Text('2 meses')),
                        DropdownMenuItem(value: 90, child: Text('3 meses')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDays = value;
                          });
                          _calculateEstimation(); // Recalcular con nuevos días
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Resumen'),
          Tab(text: 'Nutrición'),
          Tab(text: 'Progreso'),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          _buildObjectiveCard(),
          const SizedBox(height: 16),
          _buildMetabolicMetrics(),
          const SizedBox(height: 16),
          _buildAIRecommendations(),
        ],
      ),
    );
  }

  Widget _buildObjectiveCard() {
    final objectiveTitle = widget.user.objective == 'volumen' 
        ? 'Volumen' 
        : widget.user.objective == 'definicion' 
            ? 'Definición' 
            : 'Mantenimiento';

    return InfoCard(
      title: 'Tu Objetivo: $objectiveTitle',
      icon: Icon(
        widget.user.objective == 'volumen' 
            ? Icons.fitness_center
            : widget.user.objective == 'definicion'
                ? Icons.monitor_weight_outlined
                : Icons.balance,
        color: AppColors.primaryBlue,
        size: 20,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  value: _estimation!.targetWeight.toStringAsFixed(1),
                  label: 'Peso objetivo (kg)',
                  valueColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  value: '${_estimation!.timeToGoal}',
                  label: 'Semanas estimadas',
                  valueColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progreso esperado',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${_estimation!.expectedWeightChange > 0 ? '+' : ''}${_estimation!.expectedWeightChange} kg/semana',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.25, // Progreso inicial
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetabolicMetrics() {
    return InfoCard(
      title: 'Métricas Metabólicas',
      icon: const Icon(Icons.local_fire_department, color: AppColors.warning, size: 20),
      child: Column(
        children: [
          _buildMetricRow('TMB (Metabolismo Basal)', '${_estimation!.tmb.round()} kcal'),
          const Divider(height: 16),
          _buildMetricRow('TDEE (Gasto Total)', '${_estimation!.tdee.round()} kcal'),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calorías Objetivo',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.user.objective == 'definicion' 
                      ? AppColors.error.withOpacity(0.2)
                      : AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${_estimation!.targetCalories.round()} kcal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.user.objective == 'definicion' 
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAIRecommendations() {
    // TODO: Aquí puedes integrar recomendaciones generadas por IA
    // Ejemplo: await AIRecommendationService.getPersonalizedAdvice(widget.user, _estimation);
    final recommendations = HealthCalculatorService.getRecommendations(widget.user.objective);
    
    return InfoCard(
      title: 'Recomendaciones IA',
      icon: const Icon(Icons.psychology, color: AppColors.success, size: 20),
      child: Column(
        children: recommendations.map((recommendation) {
          final index = recommendations.indexOf(recommendation);
          final colors = [AppColors.error, AppColors.primaryBlue, AppColors.success, AppColors.warning];
          final icons = [Icons.restaurant, Icons.fitness_center, Icons.timeline, Icons.bedtime];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors[index % colors.length].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors[index % colors.length].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icons[index % icons.length],
                  color: colors[index % colors.length],
                  size: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNutritionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          _buildDailyCaloriesCard(),
          const SizedBox(height: 16),
          _buildMacronutrientsCard(),
          const SizedBox(height: 16),
          _buildMealDistributionCard(),
        ],
      ),
    );
  }

  Widget _buildDailyCaloriesCard() {
    return InfoCard(
      title: 'Plan Nutricional Diario',
      icon: const Icon(Icons.restaurant, color: AppColors.success, size: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.1),
                  AppColors.primaryGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            ),
            child: Column(
              children: [
                Text(
                  '${_estimation!.targetCalories.round()}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Calorías totales por día',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrientsCard() {
    final macros = _estimation!.macros;
    final totalCalories = _estimation!.targetCalories;

    return InfoCard(
      title: 'Distribución de Macronutrientes',
      child: Column(
        children: [
          _buildMacroRow(
            'Proteínas',
            '${macros.protein.round()}g',
            '${macros.proteinCalories.round()} kcal',
            '${macros.proteinPercentage(totalCalories).round()}%',
            AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildMacroRow(
            'Carbohidratos',
            '${macros.carbs.round()}g',
            '${macros.carbsCalories.round()} kcal',
            '${macros.carbsPercentage(totalCalories).round()}%',
            AppColors.primaryBlue,
          ),
          const SizedBox(height: 12),
          _buildMacroRow(
            'Grasas',
            '${macros.fat.round()}g',
            '${macros.fatCalories.round()} kcal',
            '${macros.fatPercentage(totalCalories).round()}%',
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String name, String grams, String calories, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  grams,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                calories,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                percentage,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealDistributionCard() {
    final totalCalories = _estimation!.targetCalories;

    return InfoCard(
      title: 'Distribución de Comidas',
      child: Column(
        children: [
          _buildMealRow('Desayuno (25%)', MealDistribution.breakfastCalories(totalCalories)),
          _buildMealRow('Almuerzo (35%)', MealDistribution.lunchCalories(totalCalories)),
          _buildMealRow('Cena (30%)', MealDistribution.dinnerCalories(totalCalories)),
          _buildMealRow('Snacks (10%)', MealDistribution.snacksCalories(totalCalories)),
        ],
      ),
    );
  }

  Widget _buildMealRow(String meal, double calories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            meal,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '${calories.round()} kcal',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          _buildTimelineCard(),
          const SizedBox(height: 16),
          _buildGoalCard(),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return InfoCard(
      title: 'Progreso Estimado (12 semanas)',
      icon: const Icon(Icons.timeline, color: AppColors.primaryBlue, size: 20),
      child: Column(
        children: _estimation!.weeklyProgress.take(6).map((week) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${week.week}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semana ${week.week}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Peso estimado: ${week.weight.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${week.progress.round()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: week.progress / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalCard() {
    return InfoCard(
      title: 'Meta Final',
      icon: const Icon(Icons.flag, color: AppColors.success, size: 20),
      backgroundColor: AppColors.success.withOpacity(0.05),
      borderColor: AppColors.success.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: MetricCard(
              value: _estimation!.targetWeight.toStringAsFixed(1),
              label: 'Peso objetivo',
              valueColor: AppColors.success,
              backgroundColor: AppColors.success.withOpacity(0.1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MetricCard(
              value: '${_estimation!.timeToGoal}',
              label: 'Semanas',
              valueColor: AppColors.success,
              backgroundColor: AppColors.success.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
