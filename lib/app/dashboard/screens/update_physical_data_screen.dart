import 'package:flutter/material.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/forms/custom_text_field.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../models/user.dart';
import '../../../services/user_service.dart';

class UpdatePhysicalDataScreen extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdate;
  final VoidCallback onBack;

  const UpdatePhysicalDataScreen({
    super.key,
    required this.user,
    required this.onUserUpdate,
    required this.onBack,
  });

  @override
  State<UpdatePhysicalDataScreen> createState() => _UpdatePhysicalDataScreenState();
}

class _UpdatePhysicalDataScreenState extends State<UpdatePhysicalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _selectedGender = 'masculino';
  String _selectedActivityLevel = 'moderado';
  bool _isLoading = false;

  final List<String> _genderOptions = ['masculino', 'femenino'];
  final List<String> _activityLevels = [
    'sedentario',
    'ligero', 
    'moderado',
    'activo',
    'muy-activo'
  ];

  final Map<String, String> _activityLabels = {
    'sedentario': 'Sedentario (poco o ningún ejercicio)',
    'ligero': 'Ligero (ejercicio ligero 1-3 días/semana)',
    'moderado': 'Moderado (ejercicio moderado 3-5 días/semana)',
    'activo': 'Activo (ejercicio fuerte 6-7 días/semana)',
    'muy-activo': 'Muy Activo (ejercicio muy fuerte, trabajo físico)',
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    _weightController.text = widget.user.weight.toString();
    _heightController.text = widget.user.height.toString();
    _ageController.text = widget.user.age.toString();
    _selectedGender = widget.user.gender;
    _selectedActivityLevel = widget.user.activityLevel;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = User(
        id: widget.user.id,
        name: widget.user.name,
        email: widget.user.email,
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        activityLevel: _selectedActivityLevel,
        objective: widget.user.objective,
      );

      final savedUser = await UserService.updateUser(updatedUser);
      widget.onUserUpdate(savedUser);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos actualizados correctamente'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar datos: $e'),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildPhysicalDataCard(),
                        const SizedBox(height: 16),
                        _buildActivityCard(),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: 'Guardar Cambios',
                          onPressed: _saveData,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
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
              'Actualizar Datos Físicos',
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

  Widget _buildPhysicalDataCard() {
    return Card(
      elevation: AppConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.accessibility_new, color: AppColors.primaryBlue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Datos Físicos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Edad
            CustomTextField(
              label: 'Edad',
              placeholder: '25',
              controller: _ageController,
              prefixIcon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La edad es requerida';
                }
                final age = int.tryParse(value);
                if (age == null || age < 15 || age > 100) {
                  return 'Ingresa una edad válida (15-100)';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Género
            const Text(
              'Género',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _genderOptions.map((gender) {
                return Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      gender == 'masculino' ? 'Masculino' : 'Femenino',
                      style: const TextStyle(fontSize: 14),
                    ),
                    value: gender,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                    activeColor: AppColors.primaryBlue,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Altura
            CustomTextField(
              label: 'Altura (cm)',
              placeholder: '170',
              controller: _heightController,
              prefixIcon: Icons.height,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La altura es requerida';
                }
                final height = double.tryParse(value);
                if (height == null || height < 100 || height > 250) {
                  return 'Ingresa una altura válida (100-250 cm)';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Peso
            CustomTextField(
              label: 'Peso (kg)',
              placeholder: '70',
              controller: _weightController,
              prefixIcon: Icons.monitor_weight,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El peso es requerido';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight < 30 || weight > 300) {
                  return 'Ingresa un peso válido (30-300 kg)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return Card(
      elevation: AppConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.fitness_center, color: AppColors.primaryGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  'Nivel de Actividad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ..._activityLevels.map((level) {
              return RadioListTile<String>(
                title: Text(
                  _activityLabels[level]!,
                  style: const TextStyle(fontSize: 14),
                ),
                value: level,
                groupValue: _selectedActivityLevel,
                onChanged: (value) {
                  setState(() {
                    _selectedActivityLevel = value!;
                  });
                },
                activeColor: AppColors.primaryGreen,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
