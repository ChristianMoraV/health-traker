import '../models/user.dart';
import 'api_service.dart';
import 'auth_service.dart';

class UserService {
  /// Registrar nuevo usuario usando el endpoint real del backend
  static Future<User> register(User userData) async {
    try {
      await ApiService.post('/api/v1/usuarios/', userData.toJsonForBackend());
      
      // Después del registro, hacer login automático
      final loginResponse = await AuthService.login(userData.email, userData.password!);
      
      return loginResponse;
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Actualizar datos del usuario usando el endpoint real del backend
  static Future<User> updateUser(User userData) async {
    if (AuthService.currentUserId == null) {
      throw Exception('No hay usuario logueado');
    }

    try {
      final response = await ApiService.put(
        '/api/v1/usuarios/${AuthService.currentUserId}', 
        userData.toJsonForBackend()
      );
      
      return User.fromJsonBackend(response);
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  /// Obtener usuario por ID usando el endpoint real del backend
  static Future<User> getUserById(String userId) async {
    try {
      final response = await ApiService.get('/api/v1/usuarios/$userId');
      return User.fromJsonBackend(response);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }
}
