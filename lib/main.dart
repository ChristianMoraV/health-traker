import 'package:flutter/material.dart';
import 'app/auth/screens/login_screen.dart';
import 'app/auth/screens/register_screen.dart';
import 'app/dashboard/screens/home_screen.dart';
import 'app/dashboard/screens/settings_screen.dart';
import 'app/dashboard/screens/update_physical_data_screen.dart';
import 'app/dashboard/screens/change_objective_screen.dart';
import 'app/dashboard/screens/add_metric_screen.dart';
import 'app/dashboard/screens/add_corporal_metrics_screen.dart';
import 'app/estimation/screens/estimation_screen.dart';
import 'models/user.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
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
  String _currentScreen = 'dashboard'; // 'dashboard', 'estimation', 'settings', 'update_physical', 'change_objective'

  void _handleLogin(String email, String password) async {
    try {
      // Login real usando el backend
      final user = await AuthService.login(email, password);
      
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      // Mostrar error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de login: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleRegister(User userData) async {
    try {
      // Registro real usando el backend
      final user = await UserService.register(userData);
      
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      // Mostrar error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de registro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleUserUpdate(User updatedUser) async {
    try {
      // Actualización real usando el backend
      final user = await UserService.updateUser(updatedUser);
      
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      // Mostrar error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLogout() {
    // Limpiar sesión del AuthService
    AuthService.logout();
    
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

  void _navigateToUpdatePhysical() {
    setState(() {
      _currentScreen = 'update_physical';
    });
  }

  void _navigateToChangeObjective() {
    setState(() {
      _currentScreen = 'change_objective';
    });
  }

  void _navigateToAddMetrics() {
    setState(() {
      _currentScreen = 'add_metrics';
    });
  }
  
  void _navigateToAddCorporalMetrics() {
    setState(() {
      _currentScreen = 'add_corporal_metrics';
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
            onNavigateToUpdatePhysical: _navigateToUpdatePhysical,
            onNavigateToChangeObjective: _navigateToChangeObjective,
          );
        case 'update_physical':
          return UpdatePhysicalDataScreen(
            user: _currentUser!,
            onUserUpdate: _handleUserUpdate,
            onBack: _navigateBackToDashboard,
          );
        case 'change_objective':
          return ChangeObjectiveScreen(
            user: _currentUser!,
            onUserUpdate: _handleUserUpdate,
            onBack: _navigateBackToDashboard,
          );
        case 'add_metrics':
          return AddMetricScreen(
            user: _currentUser!,
            onBack: _navigateBackToDashboard,
            onMetricAdded: () {
              // Callback opcional cuando se agrega una métrica
            },
          );
        case 'add_corporal_metrics':
          return AddCorporalMetricsScreen(
            userId: _currentUser!.id!,
            onBack: _navigateBackToDashboard,
          );
        case 'dashboard':
        default:
          return HomeScreen(
            user: _currentUser!,
            onNavigateToEstimation: _navigateToEstimation,
            onNavigateToSettings: _navigateToSettings,
            onNavigateToAddMetrics: _navigateToAddMetrics,
            onNavigateToCorporalMetrics: _navigateToAddCorporalMetrics,
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
