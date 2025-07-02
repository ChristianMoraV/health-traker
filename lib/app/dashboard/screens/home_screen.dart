import 'package:flutter/material.dart';
import '../../../components/cards/info_card.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../models/user.dart';
import '../../../services/metrics_service.dart';
import '../../../services/prediction_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final VoidCallback onNavigateToEstimation;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onNavigateToAddMetrics;
  final VoidCallback? onNavigateToCorporalMetrics;
  final VoidCallback onLogout;
  
  const HomeScreen({
    super.key,
    required this.user,
    required this.onNavigateToEstimation,
    required this.onNavigateToSettings,
    required this.onNavigateToAddMetrics,
    this.onNavigateToCorporalMetrics,
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

    try {
      // Verificar que el usuario tenga ID
      if (widget.user.id == null) {
        throw Exception('Usuario sin ID válido');
      }

      final userId = widget.user.id!;
      print('🔍 Cargando métricas para usuario: $userId');

      // Cargar métricas del usuario desde el backend
      final latestMetric = await MetricsService.getLatestMetric(userId);
      print('📊 Última métrica: ${latestMetric?.peso ?? 'null'}');
      
      final recentMetrics = await MetricsService.getMetricsInRange(userId, 30);
      print('📈 Métricas recientes: ${recentMetrics.length} registros');
      
      // Calcular progreso si hay métricas
      Map<String, dynamic> progress = {};
      if (recentMetrics.isNotEmpty) {
        progress = MetricsService.calculateWeightProgress(recentMetrics);
      }

      // Obtener predicciones de IA si hay datos suficientes
      Map<String, dynamic>? predictions;
      List<Map<String, dynamic>>? recommendations;
      
      if (recentMetrics.length >= 2) {
        // Obtener predicciones
        try {
          predictions = await PredictionService.predictWeight(userId, days: 30);
        } catch (e) {
          print('Error obteniendo predicciones: $e');
        }
        
        // Obtener recomendaciones por separado
        try {
          recommendations = await PredictionService.getRecommendations(userId);
        } catch (e) {
          print('Error obteniendo recomendaciones: $e');
          recommendations = []; // Lista vacía en caso de error
        }
      }

      // Calcular IMC actual basado en el peso más reciente
      double currentWeight = latestMetric?.peso ?? widget.user.weight;
      double currentIMC = widget.user.height > 0 
          ? currentWeight / ((widget.user.height / 100) * (widget.user.height / 100))
          : widget.user.bmi;
      
      print('🔍 Debug info:');
      print('  - latestMetric peso: ${latestMetric?.peso}');
      print('  - widget.user.weight: ${widget.user.weight}');
      print('  - widget.user.height: ${widget.user.height}');
      print('⚖️ Peso actual calculado: $currentWeight kg');
      print('📏 IMC calculado: $currentIMC');
      print('🤖 Predicciones: ${predictions != null ? 'Disponibles' : 'No disponibles'}');
      print('💡 Recomendaciones: ${recommendations?.length ?? 0} items');

      setState(() {
        _healthMetrics = {
          'currentWeight': currentWeight,
          'currentIMC': currentIMC,
          'imcStatus': _getIMCStatus(currentIMC),
          'weeklyProgress': progress['weeklyAverage'] ?? 0.0,
          'totalChange': progress['totalChange'] ?? 0.0,
          'trend': progress['trend'] ?? 'estable',
          'hasMetrics': recentMetrics.isNotEmpty,
          'metricsCount': recentMetrics.length,
          'lastMetricDate': latestMetric?.fecha,
          // Predicciones de IA
          'aiPredictedWeight': predictions?['peso_predicho'],
          'aiPredictedChange': predictions?['cambio_estimado'],
          'aiConfidence': predictions?['confianza'],
          'aiTrend': predictions?['tendencia'],
          // Recomendaciones
          'recommendations': recommendations ?? [],
          'hasRecommendations': recommendations?.isNotEmpty == true,
        };
        _isLoadingMetrics = false;
        print('🎯 _healthMetrics actualizado - Peso: ${_healthMetrics!['currentWeight']} kg, IMC: ${_healthMetrics!['currentIMC']}');
      });
    } catch (e) {
      print('Error cargando métricas: $e');
      // En caso de error, usar datos básicos del usuario
      if (mounted) {
        setState(() {
          _healthMetrics = {
            'currentWeight': widget.user.weight,
            'currentIMC': widget.user.bmi,
            'imcStatus': _getIMCStatus(widget.user.bmi),
            'weeklyProgress': 0.0,
            'totalChange': 0.0,
            'trend': 'estable',
            'hasMetrics': false,
            'metricsCount': 0,
            'error': 'No se pudieron cargar las métricas',
          };
          _isLoadingMetrics = false;
        });
      }
    }
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
              'Registrar Peso',
              'Registra tu peso actual',
              Icons.monitor_weight,
              AppColors.primaryBlue,
              widget.onNavigateToAddMetrics,
            ),
            _buildActionCard(
              'Métricas Corporales',
              'Registra métricas completas',
              Icons.health_and_safety,
              AppColors.primaryGreen,
              widget.onNavigateToCorporalMetrics ?? () {
                // TODO: Implement navigation
              },
            ),
            _buildActionCard(
              'Mi Progreso',
              'Seguimiento de tu evolución',
              Icons.trending_up,
              AppColors.success,
              () {
                // TODO: Navegar a progreso
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
                  value: '${(_healthMetrics!['currentWeight'] as double).toStringAsFixed(1)}',
                  label: 'Peso Actual',
                  unit: 'kg',
                  valueColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  value: '${_healthMetrics!['currentIMC'].toStringAsFixed(1)}',
                  label: 'IMC',
                  valueColor: _getIMCColor(_healthMetrics!['currentIMC']),
                  backgroundColor: _getIMCColor(_healthMetrics!['currentIMC']).withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getIMCColor(_healthMetrics!['currentIMC']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getIMCColor(_healthMetrics!['currentIMC']).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: _getIMCColor(_healthMetrics!['currentIMC']),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _healthMetrics!['imcStatus'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getIMCColor(_healthMetrics!['currentIMC']),
                        ),
                      ),
                    ],
                  ),
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

    final hasMetrics = _healthMetrics!['hasMetrics'] ?? false;
    final weeklyProgress = (_healthMetrics!['weeklyProgress'] ?? 0.0) as double;
    final totalChange = (_healthMetrics!['totalChange'] ?? 0.0) as double;
    final trend = _healthMetrics!['trend'] ?? 'estable';
    final metricsCount = _healthMetrics!['metricsCount'] ?? 0;

    return InfoCard(
      title: hasMetrics ? 'Progreso Reciente' : 'Sin Métricas',
      icon: const Icon(Icons.calendar_today, color: AppColors.primaryGreen, size: 20),
      child: Column(
        children: [
          if (hasMetrics) ...[
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    value: weeklyProgress >= 0 
                        ? '+${weeklyProgress.toStringAsFixed(1)}' 
                        : weeklyProgress.toStringAsFixed(1),
                    label: 'kg/semana promedio',
                    unit: '',
                    valueColor: weeklyProgress > 0.1 
                        ? AppColors.success 
                        : weeklyProgress < -0.1 
                            ? AppColors.warning
                            : AppColors.primaryBlue,
                    backgroundColor: (weeklyProgress > 0.1 
                        ? AppColors.success 
                        : weeklyProgress < -0.1 
                            ? AppColors.warning
                            : AppColors.primaryBlue).withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    value: totalChange >= 0 
                        ? '+${totalChange.toStringAsFixed(1)}' 
                        : totalChange.toStringAsFixed(1),
                    label: 'cambio total',
                    unit: 'kg',
                    valueColor: totalChange > 0 
                        ? AppColors.success 
                        : totalChange < 0 
                            ? AppColors.warning
                            : AppColors.primaryBlue,
                    backgroundColor: (totalChange > 0 
                        ? AppColors.success 
                        : totalChange < 0 
                            ? AppColors.warning
                            : AppColors.primaryBlue).withOpacity(0.1),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tendencia',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        trend == 'subiendo' ? '📈 Subiendo' : 
                        trend == 'bajando' ? '📉 Bajando' : '➡️ Estable',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Registros',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$metricsCount',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.scale_outlined,
                    size: 48,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No hay métricas registradas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Registra tu peso para ver tu progreso',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    if (_isLoadingMetrics) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    }

    final hasRecommendations = _healthMetrics!['hasRecommendations'] ?? false;
    final recommendations = _healthMetrics!['recommendations'] as List? ?? [];
    final aiPredictedWeight = _healthMetrics!['aiPredictedWeight'];
    final aiPredictedChange = _healthMetrics!['aiPredictedChange'];
    final aiConfidence = _healthMetrics!['aiConfidence'];

    return InfoCard(
      title: hasRecommendations || aiPredictedWeight != null ? 'Predicciones IA' : 'IA No Disponible',
      icon: const Icon(Icons.psychology, color: AppColors.primaryBlue, size: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (aiPredictedWeight != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppColors.primaryBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Predicción de Peso (30 días)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Peso estimado',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${aiPredictedWeight.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (aiPredictedChange != null) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Cambio esperado',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${aiPredictedChange >= 0 ? '+' : ''}${aiPredictedChange.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: aiPredictedChange >= 0 ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (aiConfidence != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: aiConfidence == 'alta' 
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Confianza: $aiConfidence',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: aiConfidence == 'alta' ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasRecommendations) const SizedBox(height: 12),
          ],
          if (hasRecommendations) ...[
            const Text(
              'Recomendaciones Personalizadas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendations.take(3).map((rec) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec['mensaje'] ?? rec.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          if (!hasRecommendations && aiPredictedWeight == null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'IA No Disponible',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Registra más datos para obtener predicciones y recomendaciones personalizadas',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
