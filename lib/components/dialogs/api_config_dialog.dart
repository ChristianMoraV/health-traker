import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';
import '../forms/custom_text_field.dart';
import '../buttons/primary_button.dart';

class ApiConfigDialog extends StatefulWidget {
  const ApiConfigDialog({super.key});

  @override
  State<ApiConfigDialog> createState() => _ApiConfigDialogState();
}

class _ApiConfigDialogState extends State<ApiConfigDialog> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _urlController.text = ApiService.baseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      ApiService.updateBaseUrl(_urlController.text);
      Navigator.of(context).pop(true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración de API actualizada'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  void _setLocalhost() {
    _urlController.text = 'http://localhost:8000';
  }

  void _setCurrentTunnel() {
    // Ejemplo con ngrok
    _urlController.text = 'https://aaf8-2800-bf0-be42-70ae-6961-642b-b339-45b7.ngrok-free.app';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Configurar API',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Configura la URL base de la API:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'URL de la API',
              placeholder: 'https://ejemplo.localtunnel.me',
              controller: _urlController,
              prefixIcon: Icons.link,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La URL es requerida';
                }
                if (!value.startsWith('http://') && !value.startsWith('https://')) {
                  return 'La URL debe empezar con http:// o https://';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Botones rápidos
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _setLocalhost,
                    child: const Text('Local'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _setCurrentTunnel,
                    child: const Text('Túnel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        PrimaryButton(
          text: 'Guardar',
          onPressed: _saveConfig,
        ),
      ],
    );
  }
}
