import 'api_service.dart';

class CorporalMetricsService {
  /// Obtener todas las métricas corporales de un usuario
  static Future<Map<String, dynamic>> getCorporalMetrics(String userId) async {
    try {
      final response = await ApiService.get('/api/v1/metricas/$userId/corporales');
      return response;
    } catch (e) {
      throw Exception('Error al obtener métricas corporales: $e');
    }
  }

  /// Registrar métricas corporales completas
  static Future<Map<String, dynamic>> addCorporalMetrics(
    String userId, 
    Map<String, dynamic> metricsData
  ) async {
    try {
      final response = await ApiService.post('/api/v1/metricas/$userId/corporales', metricsData);
      return response;
    } catch (e) {
      throw Exception('Error al registrar métricas corporales: $e');
    }
  }

  /// Actualizar métricas corporales de una fecha específica
  static Future<Map<String, dynamic>> updateCorporalMetrics(
    String userId,
    String fecha,
    Map<String, dynamic> metricsData
  ) async {
    try {
      final response = await ApiService.put('/api/v1/metricas/$userId/corporales/$fecha', metricsData);
      return response;
    } catch (e) {
      throw Exception('Error al actualizar métricas corporales: $e');
    }
  }

  /// Obtener historial de métricas corporales con filtros
  static Future<List<Map<String, dynamic>>> getCorporalMetricsHistory(
    String userId, {
    String? fechaInicio,
    String? fechaFin,
    int? limite,
  }) async {
    try {
      String endpoint = '/api/v1/metricas/$userId/corporales';
      
      // Agregar parámetros de consulta
      List<String> params = [];
      if (fechaInicio != null) params.add('fecha_inicio=$fechaInicio');
      if (fechaFin != null) params.add('fecha_fin=$fechaFin');
      if (limite != null) params.add('limite=$limite');
      
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }
      
      final response = await ApiService.get(endpoint);
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map && response['metricas'] is List) {
        return List<Map<String, dynamic>>.from(response['metricas']);
      }
      
      return [];
    } catch (e) {
      throw Exception('Error al obtener historial de métricas corporales: $e');
    }
  }

  /// Validar datos de métricas corporales antes de enviar
  static Map<String, dynamic> validateMetricsData(Map<String, dynamic> data) {
    final validatedData = <String, dynamic>{};
    
    // Fecha de registro (requerida)
    if (data['FechaRegistro'] != null) {
      if (data['FechaRegistro'] is DateTime) {
        // Enviar solo la fecha en formato YYYY-MM-DD
        validatedData['FechaRegistro'] = (data['FechaRegistro'] as DateTime).toIso8601String().split('T')[0];
      } else {
        validatedData['FechaRegistro'] = data['FechaRegistro'].toString();
      }
    } else {
      // Usar fecha actual si no se proporciona
      validatedData['FechaRegistro'] = DateTime.now().toIso8601String().split('T')[0];
    }
    
    // Validar y convertir campos numéricos opcionales
    if (data['CaloriasConsumidas'] != null) {
      validatedData['CaloriasConsumidas'] = (data['CaloriasConsumidas'] as num).toInt();
    }
    if (data['CaloriasQuemadas'] != null) {
      validatedData['CaloriasQuemadas'] = (data['CaloriasQuemadas'] as num).toInt();
    }
    if (data['ConsumoAgua'] != null) {
      validatedData['ConsumoAgua'] = (data['ConsumoAgua'] as num).toDouble();
    }
    if (data['HorasSueno'] != null) {
      validatedData['HorasSueno'] = (data['HorasSueno'] as num).toDouble();
    }
    if (data['MinutosEjercicio'] != null) {
      validatedData['MinutosEjercicio'] = (data['MinutosEjercicio'] as num).toInt();
    }
    if (data['NumeroPasos'] != null) {
      validatedData['NumeroPasos'] = (data['NumeroPasos'] as num).toInt();
    }
    if (data['FrecuenciaCardiacaPromedio'] != null) {
      validatedData['FrecuenciaCardiacaPromedio'] = (data['FrecuenciaCardiacaPromedio'] as num).toInt();
    }
    if (data['IndiceMasaCorporal'] != null) {
      validatedData['IndiceMasaCorporal'] = (data['IndiceMasaCorporal'] as num).toDouble();
    }
    if (data['PorcentajeGrasaCorporal'] != null) {
      validatedData['PorcentajeGrasaCorporal'] = (data['PorcentajeGrasaCorporal'] as num).toDouble();
    }
    if (data['MasaMuscular'] != null) {
      validatedData['MasaMuscular'] = (data['MasaMuscular'] as num).toDouble();
    }
    
    return validatedData;
  }
}
