import 'api_service.dart';

class PredictionService {
  /// Predecir peso con IA para un usuario
  static Future<Map<String, dynamic>> predictWeight(String userId, {int days = 30}) async {
    try {
      final response = await ApiService.get('/api/v1/ia/$userId/predecir-peso?dias=$days');
      print('🔮 Response de predicción: $response');
      
      if (response['success'] == true) {
        final prediccion = response['prediccion'] as Map<String, dynamic>;
        
        // Convertir todos los números a double para evitar errores de tipo
        final result = Map<String, dynamic>.from(prediccion);
        
        // Conversiones seguras a double
        if (result['peso_actual'] != null) {
          result['peso_actual'] = (result['peso_actual'] as num).toDouble();
        }
        if (result['peso_predicho'] != null) {
          result['peso_predicho'] = (result['peso_predicho'] as num).toDouble();
        }
        if (result['cambio_estimado'] != null) {
          result['cambio_estimado'] = (result['cambio_estimado'] as num).toDouble();
        }
        if (result['dias_prediccion'] != null) {
          result['dias_prediccion'] = (result['dias_prediccion'] as num).toInt();
        }
        
        // Manejar intervalo de confianza
        if (result['intervalo_confianza'] is Map) {
          final intervalo = result['intervalo_confianza'] as Map<String, dynamic>;
          if (intervalo['min'] != null) {
            intervalo['min'] = (intervalo['min'] as num).toDouble();
          }
          if (intervalo['max'] != null) {
            intervalo['max'] = (intervalo['max'] as num).toDouble();
          }
        }
        
        // Manejar predicciones de modelos
        if (result['predicciones_modelos'] is Map) {
          final modelos = result['predicciones_modelos'] as Map<String, dynamic>;
          modelos.forEach((key, value) {
            if (value is num) {
              modelos[key] = value.toDouble();
            }
          });
        }
        
        return result;
      } else {
        throw Exception('Error en predicción');
      }
    } catch (e) {
      throw Exception('Error al predecir peso: $e');
    }
  }

  /// Entrenar modelo personalizado para el usuario
  static Future<Map<String, dynamic>> trainModel(String userId) async {
    try {
      final response = await ApiService.post('/api/v1/ia/$userId/entrenar', {});
      
      if (response['success'] == true) {
        return response['entrenamiento'];
      } else {
        throw Exception('Error en entrenamiento');
      }
    } catch (e) {
      throw Exception('Error al entrenar modelo: $e');
    }
  }

  /// Obtener recomendaciones con IA
  static Future<List<Map<String, dynamic>>> getRecommendations(String userId) async {
    try {
      final response = await ApiService.get('/api/v1/ia/$userId/recomendaciones');
      print('🤖 Response de recomendaciones RAW: $response');
      print('🤖 Response type: ${response.runtimeType}');
      
      if (response is Map && response['success'] == true) {
        final recomendaciones = response['recomendaciones'];
        print('🎯 Recomendaciones RAW: $recomendaciones (tipo: ${recomendaciones.runtimeType})');
        
        // Manejar diferentes tipos de respuesta SIN hacer cast forzado
        if (recomendaciones is List) {
          return recomendaciones.map<Map<String, dynamic>>((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            } else {
              return {'mensaje': item.toString()};
            }
          }).toList();
        } else if (recomendaciones is Map) {
          if (recomendaciones.containsKey('recomendaciones') && recomendaciones['recomendaciones'] is List) {
            return (recomendaciones['recomendaciones'] as List).map<Map<String, dynamic>>((item) {
              if (item is Map) {
                return Map<String, dynamic>.from(item);
              } else {
                return {'mensaje': item.toString()};
              }
            }).toList();
          } else {
            // Si es un Map simple, convertirlo a lista con un elemento
            return [Map<String, dynamic>.from(recomendaciones)];
          }
        } else if (recomendaciones is String) {
          // Si es un string, crear un mapa básico
          print('📝 Recomendación es String: $recomendaciones');
          return [{'tipo': 'general', 'mensaje': recomendaciones}];
        } else {
          print('⚠️ Tipo de recomendaciones no reconocido: ${recomendaciones.runtimeType}');
          return [];
        }
      } else {
        print('❌ Response no exitosa: $response');
        return [];
      }
    } catch (e) {
      print('❌ Error en getRecommendations: $e');
      return []; // Retornar lista vacía en lugar de lanzar excepción
    }
  }

  /// Análisis completo con IA (entrenamiento + predicción + recomendaciones)
  static Future<Map<String, dynamic>> getCompleteAnalysis(String userId, {bool includePrediction = true}) async {
    try {
      final response = await ApiService.get('/api/v1/ia/$userId/analisis-completo?incluir_prediccion=$includePrediction');
      
      if (response['success'] == true) {
        return response['analisis'];
      } else {
        throw Exception('Error en análisis completo');
      }
    } catch (e) {
      throw Exception('Error al obtener análisis completo: $e');
    }
  }

  /// Predicción simple de peso futuro (algoritmo básico)
  static Future<Map<String, dynamic>> predictFutureWeight(String userId, {int days = 30}) async {
    try {
      final response = await ApiService.get('/api/v1/ia/$userId/peso-futuro?dias=$days');
      return response;
    } catch (e) {
      throw Exception('Error al predecir peso futuro: $e');
    }
  }

  /// Calcular tiempo para alcanzar objetivo
  static Future<Map<String, dynamic>> getTimeToGoal(String userId, double targetWeight) async {
    try {
      final response = await ApiService.get('/api/v1/ia/$userId/tiempo-objetivo?peso_objetivo=$targetWeight');
      return response;
    } catch (e) {
      throw Exception('Error al calcular tiempo objetivo: $e');
    }
  }

  /// Entrenar modelo personalizado
  static Future<Map<String, dynamic>> trainPersonalModel(String userId) async {
    try {
      final response = await ApiService.post('/api/v1/ia/$userId/entrenar', {});
      
      if (response['success'] == true) {
        return response['entrenamiento'];
      } else {
        throw Exception('Error en entrenamiento');
      }
    } catch (e) {
      throw Exception('Error al entrenar modelo: $e');
    }
  }

  /// Obtener recomendaciones básicas (endpoint alternativo)
  static Future<Map<String, dynamic>> getBasicRecommendations(String userId) async {
    try {
      final response = await ApiService.get('/api/v1/ia/$userId/recomendaciones');
      return response;
    } catch (e) {
      throw Exception('Error al obtener recomendaciones básicas: $e');
    }
  }
}
