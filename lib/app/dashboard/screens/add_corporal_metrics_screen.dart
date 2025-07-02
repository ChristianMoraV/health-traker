import 'package:flutter/material.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/forms/custom_text_field.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../services/corporal_metrics_service.dart';

class AddCorporalMetricsScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onBack;

  const AddCorporalMetricsScreen({
    super.key,
    required this.userId,
    required this.onBack,
  });

  @override
  State<AddCorporalMetricsScreen> createState() => _AddCorporalMetricsScreenState();
}

class _AddCorporalMetricsScreenState extends State<AddCorporalMetricsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para los campos
  final _caloriasConsumidasController = TextEditingController();
  final _caloriasQuemadasController = TextEditingController();
  final _consumoAguaController = TextEditingController();
  final _horasSuenoController = TextEditingController();
  final _minutosEjercicioController = TextEditingController();
  final _numeroPasosController = TextEditingController();
  final _frecuenciaCardiacaController = TextEditingController();
  final _imcController = TextEditingController();
  final _porcentajeGrasaController = TextEditingController();
  final _masaMuscularController = TextEditingController();

  @override
  void dispose() {
    _caloriasConsumidasController.dispose();
    _caloriasQuemadasController.dispose();
    _consumoAguaController.dispose();
    _horasSuenoController.dispose();
    _minutosEjercicioController.dispose();
    _numeroPasosController.dispose();
    _frecuenciaCardiacaController.dispose();
    _imcController.dispose();
    _porcentajeGrasaController.dispose();
    _masaMuscularController.dispose();
    super.dispose();
  }

  Future<void> _saveMetrics() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final metricsData = <String, dynamic>{};

      // Solo agregar campos que tienen valor
      if (_caloriasConsumidasController.text.isNotEmpty) {
        metricsData['CaloriasConsumidas'] = int.parse(_caloriasConsumidasController.text);
      }
      if (_caloriasQuemadasController.text.isNotEmpty) {
        metricsData['CaloriasQuemadas'] = int.parse(_caloriasQuemadasController.text);
      }
      if (_consumoAguaController.text.isNotEmpty) {
        metricsData['ConsumoAgua'] = double.parse(_consumoAguaController.text);
      }
      if (_horasSuenoController.text.isNotEmpty) {
        metricsData['HorasSueno'] = double.parse(_horasSuenoController.text);
      }
      if (_minutosEjercicioController.text.isNotEmpty) {
        metricsData['MinutosEjercicio'] = int.parse(_minutosEjercicioController.text);
      }
      if (_numeroPasosController.text.isNotEmpty) {
        metricsData['NumeroPasos'] = int.parse(_numeroPasosController.text);
      }
      if (_frecuenciaCardiacaController.text.isNotEmpty) {
        metricsData['FrecuenciaCardiacaPromedio'] = int.parse(_frecuenciaCardiacaController.text);
      }
      if (_imcController.text.isNotEmpty) {
        metricsData['IndiceMasaCorporal'] = double.parse(_imcController.text);
      }
      if (_porcentajeGrasaController.text.isNotEmpty) {
        metricsData['PorcentajeGrasaCorporal'] = double.parse(_porcentajeGrasaController.text);
      }
      if (_masaMuscularController.text.isNotEmpty) {
        metricsData['MasaMuscular'] = double.parse(_masaMuscularController.text);
      }

      if (metricsData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ingresa al menos una métrica'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      // Validar y enviar datos
      final validatedData = CorporalMetricsService.validateMetricsData(metricsData);
      await CorporalMetricsService.addCorporalMetrics(widget.userId, validatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Métricas registradas exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar métricas: $e'),
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
              Color(0xFFF0F9FF),
              Color(0xFFF0FDF4),
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
                        _buildNutritionSection(),
                        const SizedBox(height: 20),
                        _buildActivitySection(),
                        const SizedBox(height: 20),
                        _buildBodyCompositionSection(),
                        const SizedBox(height: 30),
                        _buildSaveButton(),
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
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          const Text(
            'Registrar Métricas Corporales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSection() {
    return _buildSection(
      'Nutrición',
      Icons.restaurant,
      [
        CustomTextField(
          controller: _caloriasConsumidasController,
          label: 'Calorías Consumidas',
          placeholder: 'Ej: 2000',
          keyboardType: TextInputType.number,
          suffixIcon: const Text('kcal'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _caloriasQuemadasController,
          label: 'Calorías Quemadas',
          placeholder: 'Ej: 500',
          keyboardType: TextInputType.number,
          suffixIcon: const Text('kcal'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _consumoAguaController,
          label: 'Consumo de Agua',
          placeholder: 'Ej: 2.5',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffixIcon: const Text('L'),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return _buildSection(
      'Actividad Física',
      Icons.fitness_center,
      [
        CustomTextField(
          controller: _horasSuenoController,
          label: 'Horas de Sueño',
          placeholder: 'Ej: 8.5',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffixIcon: const Text('h'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _minutosEjercicioController,
          label: 'Minutos de Ejercicio',
          placeholder: 'Ej: 45',
          keyboardType: TextInputType.number,
          suffixIcon: const Text('min'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _numeroPasosController,
          label: 'Número de Pasos',
          placeholder: 'Ej: 10000',
          keyboardType: TextInputType.number,
          suffixIcon: const Text('pasos'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _frecuenciaCardiacaController,
          label: 'Frecuencia Cardíaca Promedio',
          placeholder: 'Ej: 75',
          keyboardType: TextInputType.number,
          suffixIcon: const Text('bpm'),
        ),
      ],
    );
  }

  Widget _buildBodyCompositionSection() {
    return _buildSection(
      'Composición Corporal',
      Icons.monitor_weight,
      [
        CustomTextField(
          controller: _imcController,
          label: 'Índice de Masa Corporal (IMC)',
          placeholder: 'Ej: 24.5',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffixIcon: const Text('kg/m²'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _porcentajeGrasaController,
          label: 'Porcentaje de Grasa Corporal',
          placeholder: 'Ej: 15.5',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffixIcon: const Text('%'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _masaMuscularController,
          label: 'Masa Muscular',
          placeholder: 'Ej: 45.2',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffixIcon: const Text('kg'),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return PrimaryButton(
      onPressed: _isLoading ? null : _saveMetrics,
      text: _isLoading ? 'Guardando...' : 'Guardar Métricas',
      isLoading: _isLoading,
    );
  }
}
