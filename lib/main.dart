import 'package:flutter/material.dart';
import 'app/auth/screens/login_screen.dart';
import 'app/auth/screens/register_screen.dart';
import 'app/dashboard/screens/home_screen.dart';
import 'app/dashboard/screens/settings_screen.dart';
import 'app/estimation/screens/estimation_screen.dart';
import 'models/user.dart';
import 'utils/colors.dart';

void main() {
  runApp(const HealthTrackerApp());
}

class HealthTrackerApp extends StatelessWidget {
  const HealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AuthFlow(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  bool _isLogin = true;
  User? _currentUser;
  String _currentScreen = 'dashboard'; // 'dashboard', 'estimation', 'settings'

  void _handleLogin(String email, String password) {
    // TODO: Aquí puedes agregar tu lógica de autenticación real
    // Ejemplo: await AuthService.login(email, password);
    setState(() {
      _currentUser = User(
        name: 'Usuario Demo',
        email: email,
        password: password,
        age: 25,
        gender: 'masculino',
        height: 175,
        weight: 70,
        activityLevel: 'moderado',
        objective: 'volumen',
      );
    });
  }

  void _handleRegister(User userData) {
    // TODO: Aquí puedes agregar tu lógica de registro real
    // Ejemplo: await AuthService.register(userData);
    setState(() {
      _currentUser = userData;
    });
  }

  void _handleUserUpdate(User updatedUser) {
    // TODO: Aquí puedes guardar los cambios del usuario
    setState(() {
      _currentUser = updatedUser;
    });
  }

  void _handleLogout() {
    setState(() {
      _currentUser = null;
      _isLogin = true;
      _currentScreen = 'dashboard';
    });
  }

  void _switchToRegister() {
    setState(() {
      _isLogin = false;
    });
  }

  void _switchToLogin() {
    setState(() {
      _isLogin = true;
    });
  }

  void _navigateToEstimation() {
    setState(() {
      _currentScreen = 'estimation';
    });
  }

  void _navigateToSettings() {
    setState(() {
      _currentScreen = 'settings';
    });
  }

  void _navigateBackToDashboard() {
    setState(() {
      _currentScreen = 'dashboard';
    });
  }
  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
      // Usuario logueado - mostrar dashboard, estimación o configuraciones
      switch (_currentScreen) {
        case 'estimation':
          return EstimationScreen(
            user: _currentUser!,
            onBack: _navigateBackToDashboard,
          );
        case 'settings':
          return SettingsScreen(
            user: _currentUser!,
            onBack: _navigateBackToDashboard,
            onLogout: _handleLogout,
            onUserUpdate: _handleUserUpdate,
          );
        case 'dashboard':
        default:
          return HomeScreen(
            user: _currentUser!,
            onNavigateToEstimation: _navigateToEstimation,
            onNavigateToSettings: _navigateToSettings,
            onLogout: _handleLogout,
          );
      }
    }

    // Mostrar pantallas de autenticación
    if (_isLogin) {
      return LoginScreen(
        onLogin: _handleLogin,
        onSwitchToRegister: _switchToRegister,
      );
    } else {
      return RegisterScreen(
        onRegister: _handleRegister,
        onSwitchToLogin: _switchToLogin,
      );
    }
  }
}
