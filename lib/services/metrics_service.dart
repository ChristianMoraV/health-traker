import '../models/metrica_corporal.dart';
import 'api_service.dart';

class MetricsService {
  // Obtener historial de peso de un usuario
  static Future<List<MetricaCorporal>> getUserMetrics(String userId) async {
    try {
      print('📊 Obteniendo historial de peso para: $userId');
      final response = await ApiService.get('/api/v1/metricas/$userId/peso');
      print('📋 Respuesta del backend: $response');
      
      if (response is List) {
        final metrics = (response as List)
            .cast<Map<String, dynamic>>()
            .map((metric) => MetricaCorporal.fromJsonBackend(metric))
            .toList();
        print('✅ Métricas convertidas: ${metrics.length} registros');
        return metrics;
      }
      
      print('⚠️ Respuesta no es una lista, retornando lista vacía');
      return [];
    } catch (e) {
      print('❌ Error al obtener métricas: $e');
      throw Exception('Error al obtener métricas: $e');
    }
  }

  // Registrar nuevo peso
  static Future<MetricaCorporal> addWeightMetric(String userId, double peso, {String? observaciones}) async {
    try {
      final weightData = {
        'Peso': peso,
        'TipoRegistro': 'manual',
        'IndiceConfianza': 1.0,
        if (observaciones != null) 'Observaciones': observaciones,
      };
      
      final response = await ApiService.post(
        '/api/v1/metricas/$userId/peso', 
        weightData
      );
      
      return MetricaCorporal.fromJsonBackend(response);
    } catch (e) {
      throw Exception('Error al registrar peso: $e');
    }
  }

  // Obtener peso actual (último peso registrado)
  static Future<MetricaCorporal?> getLatestMetric(String userId) async {
    try {
      print('🔍 Intentando obtener peso actual para: $userId');
      // Primero intentar el endpoint directo
      final response = await ApiService.get('/api/v1/metricas/$userId/peso/actual');
      print('✅ Respuesta del endpoint /peso/actual: $response');
      return MetricaCorporal.fromJsonBackend(response);
    } catch (e) {
      print('❌ Error en /peso/actual: $e');
      // Si falla, obtener del historial y tomar el más reciente
      try {
        print('🔄 Intentando obtener del historial...');
        final metrics = await getUserMetrics(userId);
        print('📊 Métricas del historial: ${metrics.length} registros');
        if (metrics.isNotEmpty) {
          // Ordenar por fecha y tomar el más reciente
          metrics.sort((a, b) => b.fecha.compareTo(a.fecha));
          final latest = metrics.first;
          print('✅ Peso más reciente del historial: ${latest.peso} kg');
          return latest;
        }
      } catch (e2) {
        print('❌ Error obteniendo peso del historial: $e2');
      }
      return null;
    }
  }

  // Obtener tendencia de peso
  static Future<Map<String, dynamic>> getWeightTrend(String userId, {int days = 30}) async {
    try {
      final response = await ApiService.get('/api/v1/metricas/$userId/peso/tendencia?dias=$days');
      return response;
    } catch (e) {
      throw Exception('Error al obtener tendencia: $e');
    }
  }

  // Obtener métricas de los últimos N días (implementación local)
  static Future<List<MetricaCorporal>> getMetricsInRange(
    String userId, 
    int days
  ) async {
    try {
      final metrics = await getUserMetrics(userId);
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      return metrics
          .where((metric) => metric.fecha.isAfter(cutoffDate))
          .toList()
        ..sort((a, b) => a.fecha.compareTo(b.fecha));
    } catch (e) {
      throw Exception('Error al obtener métricas del rango: $e');
    }
  }

  // Calcular progreso de peso (implementación local)
  static Map<String, dynamic> calculateWeightProgress(
    List<MetricaCorporal> metrics
  ) {
    if (metrics.length < 2) {
      return {
        'totalChange': 0.0,
        'weeklyAverage': 0.0,
        'trend': 'estable',
      };
    }

    final sortedMetrics = List<MetricaCorporal>.from(metrics)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    final firstWeight = sortedMetrics.first.peso;
    final lastWeight = sortedMetrics.last.peso;
    final totalChange = lastWeight - firstWeight;

    final daysDiff = sortedMetrics.last.fecha
        .difference(sortedMetrics.first.fecha)
        .inDays;

    final weeklyAverage = daysDiff > 0 
        ? (totalChange / daysDiff) * 7 
        : 0.0;

    String trend;
    if (totalChange > 0.5) {
      trend = 'subiendo';
    } else if (totalChange < -0.5) {
      trend = 'bajando';
    } else {
      trend = 'estable';
    }

    return {
      'totalChange': totalChange,
      'weeklyAverage': weeklyAverage,
      'trend': trend,
      'firstWeight': firstWeight,
      'lastWeight': lastWeight,
      'daysPeriod': daysDiff,
    };
  }
}
