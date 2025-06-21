import 'package:flutter/material.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/forms/custom_text_field.dart';
import '../../../components/forms/custom_dropdown.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../models/user.dart';

class RegisterScreen extends StatefulWidget {
  final Function(User userData) onRegister;
  final VoidCallback onSwitchToLogin;

  const RegisterScreen({
    super.key,
    required this.onRegister,
    required this.onSwitchToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Controllers para los campos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Estados del formulario
  int _currentStep = 0;
  bool _isLoading = false;
  String? _gender;
  String? _activityLevel;
  String? _objective;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_formKeys[_currentStep].currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKeys[2].currentState!.validate() || _objective == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    final user = User(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      age: int.parse(_ageController.text),
      gender: _gender!,
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      activityLevel: _activityLevel!,
      objective: _objective!,
    );

    widget.onRegister(user);

    setState(() {
      _isLoading = false;
    });
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
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                // Header
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Paso ${_currentStep + 1} de 3',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Progress Bar
                _buildProgressBar(),

                const SizedBox(height: 24),

                // Form Content
                Expanded(
                  child: Card(
                    elevation: AppConstants.defaultElevation,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            _getStepTitle(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildStep1(),
                                _buildStep2(),
                                _buildStep3(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildNavigationButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (index) {
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? AppColors.primaryBlue
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: index <= _currentStep
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentStep + 1) / 3,
          backgroundColor: AppColors.surfaceVariant,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
        ),
      ],
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Información Personal';
      case 1:
        return 'Datos Físicos';
      case 2:
        return 'Objetivos';
      default:
        return '';
    }
  }

  Widget _buildStep1() {
    return Form(
      key: _formKeys[0],
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomTextField(
              label: 'Nombre Completo',
              placeholder: 'Tu nombre',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Correo Electrónico',
              placeholder: 'tu@email.com',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El correo es requerido';
                }
                if (!value.contains('@')) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Contraseña',
              placeholder: '••••••••',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La contraseña es requerida';
                }
                if (value.length < AppConstants.minPasswordLength) {
                  return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Confirmar Contraseña',
              placeholder: '••••••••',
              controller: _confirmPasswordController,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirma tu contraseña';
                }
                if (value != _passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKeys[1],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Edad',
                    placeholder: '25',
                    controller: _ageController,
                    prefixIcon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La edad es requerida';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < AppConstants.minAge || age > AppConstants.maxAge) {
                        return 'Edad entre ${AppConstants.minAge} y ${AppConstants.maxAge}';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomDropdown(
                    label: 'Género',
                    placeholder: 'Seleccionar',
                    value: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona tu género';
                      }
                      return null;
                    },
                    items: const [
                      DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                      DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
                      DropdownMenuItem(value: 'otro', child: Text('Otro')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Altura (cm)',
                    placeholder: '175',
                    controller: _heightController,
                    prefixIcon: Icons.height,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La altura es requerida';
                      }
                      final height = double.tryParse(value);
                      if (height == null || height < AppConstants.minHeight || height > AppConstants.maxHeight) {
                        return 'Altura entre ${AppConstants.minHeight.toInt()} y ${AppConstants.maxHeight.toInt()} cm';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Peso (kg)',
                    placeholder: '70',
                    controller: _weightController,
                    prefixIcon: Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El peso es requerido';
                      }
                      final weight = double.tryParse(value);
                      if (weight == null || weight < AppConstants.minWeight || weight > AppConstants.maxWeight) {
                        return 'Peso entre ${AppConstants.minWeight.toInt()} y ${AppConstants.maxWeight.toInt()} kg';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: 'Nivel de Actividad',
              placeholder: 'Selecciona tu nivel',
              value: _activityLevel,
              onChanged: (value) {
                setState(() {
                  _activityLevel = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecciona tu nivel de actividad';
                }
                return null;
              },
              items: const [
                DropdownMenuItem(value: 'sedentario', child: Text('Sedentario (poco o nada de ejercicio)')),
                DropdownMenuItem(value: 'ligero', child: Text('Ligero (ejercicio ligero 1-3 días/semana)')),
                DropdownMenuItem(value: 'moderado', child: Text('Moderado (ejercicio moderado 3-5 días/semana)')),
                DropdownMenuItem(value: 'activo', child: Text('Activo (ejercicio intenso 6-7 días/semana)')),
                DropdownMenuItem(value: 'muy-activo', child: Text('Muy activo (ejercicio muy intenso, trabajo físico)')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Form(
      key: _formKeys[2],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Objetivo Principal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildObjectiveOption(
              'volumen',
              'Volumen',
              'Ganar masa muscular',
              Icons.fitness_center,
              AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            _buildObjectiveOption(
              'definicion',
              'Definición',
              'Reducir grasa corporal',
              Icons.monitor_weight_outlined,
              AppColors.primaryGreen,
            ),
            const SizedBox(height: 12),
            _buildObjectiveOption(
              'mantenimiento',
              'Mantenimiento',
              'Mantener peso actual',
              Icons.balance,
              AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectiveOption(
    String value,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _objective == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _objective = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: PrimaryButton(
                  text: 'Anterior',
                  onPressed: _prevStep,
                  isOutlined: true,
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: _currentStep == 2 ? 'Crear Cuenta' : 'Siguiente',
                onPressed: _currentStep == 2 ? _handleSubmit : _nextStep,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
        if (_currentStep == 0) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿Ya tienes cuenta? ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: widget.onSwitchToLogin,
                child: const Text(
                  'Inicia sesión',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
