import 'package:flutter/material.dart';
import '../../../components/cards/info_card.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/dialogs/api_config_dialog.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../models/user.dart';
import '../../../services/metrics_service.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final Function(User) onUserUpdate;
  final VoidCallback onNavigateToUpdatePhysical;
  final VoidCallback onNavigateToChangeObjective;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.onBack,
    required this.onLogout,
    required this.onUserUpdate,
    required this.onNavigateToUpdatePhysical,
    required this.onNavigateToChangeObjective,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkModeEnabled = false;
  
  // Variables para métricas actuales
  double? _currentWeight;
  double? _currentIMC;
  bool _isLoadingMetrics = true;
  
  // Método para mostrar configuración de API
  Future<void> _showApiConfigDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ApiConfigDialog(),
    );
    
    if (result == true) {
      // La configuración se actualizó exitosamente
    }
  }
  
  // TODO: Aquí puedes agregar tu lógica de configuración con IA
  // - Personalización automática basada en patrones de uso
  // - Ajustes inteligentes de notificaciones
  // - Optimización de la experiencia del usuario usando ML
  
  @override
  void initState() {
    super.initState();
    _loadCurrentMetrics();
  }
  
  Future<void> _loadCurrentMetrics() async {
    if (widget.user.id == null) return;
    
    try {
      final latestMetric = await MetricsService.getLatestMetric(widget.user.id!);
      final currentWeight = latestMetric?.peso ?? widget.user.weight;
      final currentIMC = widget.user.height > 0 
          ? currentWeight / ((widget.user.height / 100) * (widget.user.height / 100))
          : widget.user.bmi;
          
      setState(() {
        _currentWeight = currentWeight;
        _currentIMC = currentIMC;
        _isLoadingMetrics = false;
      });
    } catch (e) {
      // En caso de error, usar datos del usuario
      setState(() {
        _currentWeight = widget.user.weight;
        _currentIMC = widget.user.bmi;
        _isLoadingMetrics = false;
      });
    }
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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      _buildProfileSection(),
                      const SizedBox(height: 16),
                      _buildHealthSettingsSection(),
                      const SizedBox(height: 16),
                      _buildAppSettingsSection(),
                      const SizedBox(height: 16),
                      _buildAISettingsSection(),
                      const SizedBox(height: 16),
                      _buildDataSection(),
                      const SizedBox(height: 16),
                      _buildLogoutSection(),
                    ],
                  ),
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
      child: Row(
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
              'Configuración',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return InfoCard(
      title: 'Perfil',
      icon: const Icon(Icons.person, color: AppColors.primaryBlue, size: 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.user.objective == 'volumen' 
                            ? 'Objetivo: Volumen'
                            : widget.user.objective == 'definicion'
                                ? 'Objetivo: Definición'
                                : 'Objetivo: Mantenimiento',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Navegar a edición de perfil
                },
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProfileStat('Edad', '${widget.user.age} años'),
              ),
              Expanded(
                child: _buildProfileStat('Altura', '${widget.user.height.toInt()} cm'),
              ),
              Expanded(
                child: _isLoadingMetrics 
                    ? _buildProfileStat('Peso', '...')
                    : _buildProfileStat('Peso', '${_currentWeight?.toStringAsFixed(1) ?? widget.user.weight.toStringAsFixed(1)} kg'),
              ),
              Expanded(
                child: _isLoadingMetrics 
                    ? _buildProfileStat('IMC', '...')
                    : _buildProfileStat('IMC', _currentIMC?.toStringAsFixed(1) ?? widget.user.bmi.toStringAsFixed(1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthSettingsSection() {
    return InfoCard(
      title: 'Configuración de Salud',
      icon: const Icon(Icons.favorite, color: AppColors.primaryGreen, size: 20),
      child: Column(
        children: [
          _buildSettingsTile(
            'Actualizar Datos Físicos',
            'Peso, altura, nivel de actividad',
            Icons.scale,
            widget.onNavigateToUpdatePhysical,
          ),
          const Divider(),
          _buildSettingsTile(
            'Historial Médico',
            'Condiciones y medicamentos',
            Icons.medical_services,
            () {
              // TODO: Navegar a historial médico
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return InfoCard(
      title: 'Configuración de la App',
      icon: const Icon(Icons.settings, color: AppColors.primaryBlue, size: 20),
      child: Column(
        children: [
          _buildSwitchTile(
            'Notificaciones',
            'Recordatorios y actualizaciones',
            Icons.notifications,
            _notificationsEnabled,
            (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // TODO: Aquí puedes actualizar las preferencias de notificaciones
            },
          ),
          const Divider(),
          _buildSwitchTile(
            'Autenticación Biométrica',
            'Usar huella digital o Face ID',
            Icons.fingerprint,
            _biometricEnabled,
            (value) {
              setState(() {
                _biometricEnabled = value;
              });
              // TODO: Configurar autenticación biométrica
            },
          ),
          const Divider(),
          _buildSwitchTile(
            'Modo Oscuro',
            'Cambiar el tema de la aplicación',
            Icons.dark_mode,
            _darkModeEnabled,
            (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              // TODO: Cambiar tema de la app
            },
          ),
          const Divider(),
          _buildActionTile(
            'Configurar API',
            'Cambiar servidor de la aplicación',
            Icons.api,
            _showApiConfigDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAISettingsSection() {
    return InfoCard(
      title: 'Configuración de IA',
      icon: const Icon(Icons.psychology, color: AppColors.warning, size: 20),
      child: Column(
        children: [
          _buildSettingsTile(
            'Preferencias de Recomendaciones',
            'Personalizar sugerencias de IA',
            Icons.tune,
            () {
              // TODO: Configurar preferencias de IA
              _showAIPreferencesDialog();
            },
          ),
          const Divider(),
          _buildSettingsTile(
            'Datos para Entrenamiento',
            'Contribuir al mejoramiento del modelo',
            Icons.model_training,
            () {
              // TODO: Configurar contribución de datos
              _showDataContributionDialog();
            },
          ),
          const Divider(),
          _buildSettingsTile(
            'Historial de Predicciones',
            'Ver exactitud de estimaciones pasadas',
            Icons.history,
            () {
              // TODO: Mostrar historial de predicciones
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return InfoCard(
      title: 'Datos y Privacidad',
      icon: const Icon(Icons.security, color: AppColors.error, size: 20),
      child: Column(
        children: [
          _buildSettingsTile(
            'Exportar Datos',
            'Descargar tu información personal',
            Icons.download,
            () {
              // TODO: Exportar datos del usuario
              _showExportDataDialog();
            },
          ),
          const Divider(),
          _buildSettingsTile(
            'Política de Privacidad',
            'Leer términos y condiciones',
            Icons.privacy_tip,
            () {
              // TODO: Mostrar política de privacidad
            },
          ),
          const Divider(),
          _buildSettingsTile(
            'Eliminar Cuenta',
            'Borrar permanentemente tu cuenta',
            Icons.delete_forever,
            () {
              // TODO: Confirmar eliminación de cuenta
              _showDeleteAccountDialog();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Column(
      children: [
        PrimaryButton(
          text: 'Cerrar Sesión',
          onPressed: widget.onLogout,
          isOutlined: true,
          icon: const Icon(Icons.logout, color: AppColors.primaryBlue, size: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          'Health Tracker v1.0.0',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDestructive ? AppColors.error : AppColors.textLight,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryBlue,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showAIPreferencesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferencias de IA'),
        content: const Text(
          'Aquí puedes configurar qué tipo de recomendaciones prefieres recibir y con qué frecuencia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Guardar preferencias de IA
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDataContributionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contribución de Datos'),
        content: const Text(
          'Tus datos pueden ayudar a mejorar nuestros modelos de IA para todos los usuarios. Los datos son anonimizados y protegidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Configurar contribución de datos
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Datos'),
        content: const Text(
          '¿Deseas exportar todos tus datos personales y de salud?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Iniciar exportación de datos
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exportación iniciada. Te enviaremos un email cuando esté lista.'),
                ),
              );
            },
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Eliminar Cuenta',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          '¿Estás seguro? Esta acción no se puede deshacer y se perderán todos tus datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Confirmar eliminación de cuenta
              Navigator.pop(context);
              widget.onLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primaryBlue,
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textSecondary,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
