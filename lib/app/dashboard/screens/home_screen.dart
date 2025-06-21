import 'package:flutter/material.dart';
import '../../../components/cards/info_card.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../models/user.dart';

class HomeScreen extends StatefulWidget {  final User user;
  final VoidCallback onNavigateToEstimation;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onLogout;
  const HomeScreen({
    super.key,
    required this.user,
    required this.onNavigateToEstimation,
    required this.onNavigateToSettings,
    required this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: Aquí puedes agregar tu lógica de negocio con IA
  // - Análisis de progreso con modelos de regresión
  // - Predicciones personalizadas basadas en datos históricos
  // - Recomendaciones inteligentes usando ML
  Map<String, dynamic>? _healthMetrics;
  bool _isLoadingMetrics = true;

  @override
  void initState() {
    super.initState();
    _loadHealthMetrics();
  }

  Future<void> _loadHealthMetrics() async {
    setState(() {
      _isLoadingMetrics = true;
    });

    // TODO: Aquí puedes integrar tu API/servicio de IA
    // Ejemplo: await AIHealthService.analyzeUserData(widget.user);
    await Future.delayed(const Duration(seconds: 1));

    // Datos simulados - reemplazar con datos reales de IA
    setState(() {
      _healthMetrics = {
        'currentIMC': widget.user.bmi,
        'imcStatus': _getIMCStatus(widget.user.bmi),
        'weeklyProgress': 0.3, // kg ganados/perdidos esta semana
        'goalProgress': 65.0, // % de progreso hacia el objetivo
        'recommendedCalories': 2500,
        'waterIntake': 2.1, // litros
        'sleepHours': 7.5,
        'workoutsThisWeek': 4,
        // TODO: Agregar métricas calculadas por IA
        'aiPredictedGoalDate': '2025-09-15',
        'aiConfidenceScore': 87.5,
      };
      _isLoadingMetrics = false;
    });
  }

  String _getIMCStatus(double imc) {
    if (imc < 18.5) return 'Bajo peso';
    if (imc < 25) return 'Normal';
    if (imc < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Color _getIMCColor(double imc) {
    if (imc < 18.5) return AppColors.warning;
    if (imc < 25) return AppColors.success;
    if (imc < 30) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
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
          child: RefreshIndicator(
            onRefresh: _loadHealthMetrics,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildHealthOverview(),
                  const SizedBox(height: 24),
                  _buildWeeklyProgress(),
                  const SizedBox(height: 24),
                  _buildAIInsights(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = 'Buenos días';
    if (hour >= 12 && hour < 18) {
      greeting = 'Buenas tardes';
    } else if (hour >= 18) {
      greeting = 'Buenas noches';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                widget.user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tu compañero de salud personal',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: widget.onNavigateToSettings,
              icon: const Icon(
                Icons.settings,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              'Calcular IMC',
              'Analiza tu índice de masa corporal',
              Icons.calculate,
              AppColors.primaryBlue,
              () {
                // TODO: Navegar a calculadora de IMC
              },
            ),
            _buildActionCard(
              'Mi Progreso',
              'Seguimiento de tu evolución',
              Icons.trending_up,
              AppColors.primaryGreen,
              () {
                // TODO: Navegar a progreso
              },
            ),
            _buildActionCard(
              'Objetivos',
              'Define tus metas de salud',
              Icons.flag,
              AppColors.primaryBlue,
              () {
                // TODO: Navegar a objetivos
              },
            ),
            _buildActionCard(
              'Estimación',
              'Predicción de progreso',
              Icons.insights,
              AppColors.primaryGreen,
              widget.onNavigateToEstimation,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthOverview() {
    if (_isLoadingMetrics) {
      return const InfoCard(
        title: 'Resumen de Salud',
        icon: Icon(Icons.health_and_safety, color: AppColors.primaryBlue, size: 20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return InfoCard(
      title: 'Resumen Rápido',
      icon: const Icon(Icons.health_and_safety, color: AppColors.primaryBlue, size: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  value: '${_healthMetrics!['currentIMC'].toStringAsFixed(1)}',
                  label: 'IMC Actual',
                  valueColor: _getIMCColor(_healthMetrics!['currentIMC']),
                  backgroundColor: _getIMCColor(_healthMetrics!['currentIMC']).withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  value: _healthMetrics!['imcStatus'],
                  label: 'Estado',
                  valueColor: _getIMCColor(_healthMetrics!['currentIMC']),
                  backgroundColor: _getIMCColor(_healthMetrics!['currentIMC']).withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Objetivo',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.user.objective == 'definicion' 
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.info.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.user.objective == 'definicion' ? 'Definición' : 
                    widget.user.objective == 'volumen' ? 'Volumen' : 'Mantenimiento',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: widget.user.objective == 'definicion' 
                          ? AppColors.success
                          : AppColors.info,
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

  Widget _buildWeeklyProgress() {
    if (_isLoadingMetrics) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    }

    return InfoCard(
      title: 'Esta Semana',
      icon: const Icon(Icons.calendar_today, color: AppColors.primaryGreen, size: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  value: _healthMetrics!['weeklyProgress'] > 0 
                      ? '+${_healthMetrics!['weeklyProgress']}' 
                      : '${_healthMetrics!['weeklyProgress']}',
                  label: 'kg esta semana',
                  unit: '',
                  valueColor: _healthMetrics!['weeklyProgress'] > 0 
                      ? AppColors.success 
                      : AppColors.primaryBlue,
                  backgroundColor: (_healthMetrics!['weeklyProgress'] > 0 
                      ? AppColors.success 
                      : AppColors.primaryBlue).withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  value: '${_healthMetrics!['workoutsThisWeek']}',
                  label: 'entrenamientos',
                  valueColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressCard(
            title: 'Objetivo Calórico',
            progress: 85.0,
            subtitle: '${(_healthMetrics!['recommendedCalories'] * 0.85).toInt()}/${_healthMetrics!['recommendedCalories']} kcal',
            progressColor: AppColors.primaryBlue,
          ),
          const SizedBox(height: 8),
          ProgressCard(
            title: 'Hidratación',
            progress: 92.0,
            subtitle: '${_healthMetrics!['waterIntake']} / 2.5 L',
            progressColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    if (_isLoadingMetrics) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    }

    return InfoCard(
      title: 'Predicciones IA',
      icon: const Icon(Icons.psychology, color: AppColors.primaryBlue, size: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.1),
                  AppColors.primaryGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights,
                      color: AppColors.primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Análisis Predictivo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Basado en tu progreso actual, podrías alcanzar tu objetivo el ${_healthMetrics!['aiPredictedGoalDate']}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Confianza del modelo: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    Text(
                      '${_healthMetrics!['aiConfidenceScore']}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // TODO: Aquí puedes agregar recomendaciones generadas por IA
          // Ejemplo: AIRecommendationService.getPersonalizedTips(user)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recomendación Personalizada',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Considerando tu progreso, te sugerimos aumentar la intensidad cardiovascular en un 15% esta semana.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Ver Estimación Completa',
            onPressed: widget.onNavigateToEstimation,
            icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}
