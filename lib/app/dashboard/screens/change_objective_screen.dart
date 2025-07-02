import 'package:flutter/material.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../models/user.dart';
import '../../../services/user_service.dart';

class ChangeObjectiveScreen extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdate;
  final VoidCallback onBack;

  const ChangeObjectiveScreen({
    super.key,
    required this.user,
    required this.onUserUpdate,
    required this.onBack,
  });

  @override
  State<ChangeObjectiveScreen> createState() => _ChangeObjectiveScreenState();
}

class _ChangeObjectiveScreenState extends State<ChangeObjectiveScreen> {
  String _selectedObjective = 'volumen';
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> _objectives = {
    'volumen': {
      'title': 'Ganar Volumen',
      'subtitle': 'Aumentar masa muscular',
      'description': 'Enfócate en ganar peso y construir músculo con un superávit calórico controlado.',
      'icon': Icons.fitness_center,
      'color': AppColors.primaryBlue,
      'benefits': [
        'Superávit calórico de 300-500 kcal',
        'Enfoque en ejercicios de fuerza',
        'Mayor ingesta de proteínas',
        'Ganancia gradual de peso'
      ]
    },
    'definicion': {
      'title': 'Definición',
      'subtitle': 'Reducir grasa corporal',
      'description': 'Reduce la grasa corporal manteniendo la masa muscular con un déficit calórico.',
      'icon': Icons.trending_down,
      'color': AppColors.warning,
      'benefits': [
        'Déficit calórico de 300-500 kcal',
        'Combina cardio y pesas',
        'Alta ingesta de proteínas',
        'Pérdida gradual de grasa'
      ]
    },
    'mantenimiento': {
      'title': 'Mantenimiento',
      'subtitle': 'Mantener peso actual',
      'description': 'Mantén tu peso y composición corporal actual con un balance calórico.',
      'icon': Icons.balance,
      'color': AppColors.primaryGreen,
      'benefits': [
        'Equilibrio calórico',
        'Ejercicio regular variado',
        'Alimentación balanceada',
        'Estabilidad a largo plazo'
      ]
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedObjective = widget.user.objective;
  }

  Future<void> _saveObjective() async {
    if (_selectedObjective == widget.user.objective) {
      // No hay cambios
      widget.onBack();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = User(
        id: widget.user.id,
        name: widget.user.name,
        email: widget.user.email,
        age: widget.user.age,
        gender: widget.user.gender,
        height: widget.user.height,
        weight: widget.user.weight,
        activityLevel: widget.user.activityLevel,
        objective: _selectedObjective,
      );

      final savedUser = await UserService.updateUser(updatedUser);
      widget.onUserUpdate(savedUser);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Objetivo actualizado correctamente'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar objetivo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                      _buildInfoCard(),
                      const SizedBox(height: 20),
                      ..._objectives.entries.map((entry) {
                        return _buildObjectiveCard(entry.key, entry.value);
                      }).toList(),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Guardar Objetivo',
                        onPressed: _saveObjective,
                        isLoading: _isLoading,
                      ),
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
              'Cambiar Objetivo',
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

  Widget _buildInfoCard() {
    return Card(
      elevation: AppConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.primaryBlue,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Cuál es tu objetivo?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona el objetivo que mejor se adapte a tus metas actuales. Esto ajustará tus recomendaciones calóricas y de ejercicio.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectiveCard(String key, Map<String, dynamic> objective) {
    final isSelected = _selectedObjective == key;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedObjective = key;
          });
        },
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Card(
          elevation: isSelected ? 8 : AppConstants.defaultElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            side: BorderSide(
              color: isSelected ? objective['color'] : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: objective['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        objective['icon'],
                        color: objective['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            objective['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? objective['color'] : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            objective['subtitle'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: objective['color'],
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  objective['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Características:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...objective['benefits'].map<Widget>((benefit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: objective['color'],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            benefit,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
