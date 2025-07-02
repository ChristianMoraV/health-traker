import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  // Variable para almacenar el ID del usuario actual
  static String? _currentUserId;
  static User? _currentUser;
  
  static String? get currentUserId => _currentUserId;

  /// Login usando el endpoint real del backend
  static Future<User> login(String email, String password) async {
    try {
      print('🔐 Intentando login con: $email');
      // El backend espera query parameters, no JSON body
      final response = await ApiService.post('/api/v1/usuarios/login?email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}', {});
      
      print('📋 Respuesta completa del login: $response');
      print('� Keys de la respuesta: ${response.keys.toList()}');
      
      // Verificar la estructura de la respuesta
      if (response['success'] == true && response['usuario'] != null) {
        print('👤 Estructura usuario anidada: ${response['usuario']}');
        
        // Mapear los campos del login a los campos del backend
        final userData = response['usuario'];
        final mappedUserData = {
          'IdUsuario': userData['id'],
          'Nombre': userData['nombre'],
          'CorreoElectronico': userData['email'],
          'Edad': userData['edad'],
          'Genero': userData['genero'],
          'Altura': userData['altura'],
          'PesoInicial': userData['peso_inicial'],
          'NivelActividad': userData['nivel_actividad'],
          'ObjetivoFisico': userData['objetivo_fisico'],
        };
        
        _currentUser = User.fromJsonBackend(mappedUserData);
        _currentUserId = _currentUser!.id;
        
        print('✅ Usuario parseado correctamente: ${_currentUser!.name}');
        print('🆔 ID del usuario: ${_currentUserId}');
        
        return _currentUser!;
      } else if (response['IdUsuario'] != null) {
        // Si los datos del usuario están directamente en la respuesta
        print('👤 Estructura usuario directa: $response');
        _currentUserId = response['IdUsuario'];
        return User.fromJsonBackend(response);
      } else {
        throw Exception('Respuesta de login inválida');
      }
    } catch (e) {
      print('❌ Error en login: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener usuario actual usando el endpoint real del backend
  static Future<User> getUserCurrent() async {
    if (_currentUserId == null) {
      throw Exception('No hay usuario logueado');
    }

    try {
      final response = await ApiService.get('/api/v1/usuarios/actual/$_currentUserId');
      
      // Verificar si la respuesta fue exitosa
      if (response['success'] != true) {
        throw Exception('Usuario no encontrado');
      }
      
      return User.fromJsonBackend(response['usuario']);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  /// Logout simple
  static void logout() {
    _currentUserId = null;
    _currentUser = null;
  }

  /// Verificar si hay usuario logueado
  static bool get isLoggedIn => _currentUserId != null;
}
