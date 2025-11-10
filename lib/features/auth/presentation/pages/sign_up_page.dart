import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/widgets/sueltito_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fechaNacimientoController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('es'),
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 años atrás
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaNacimientoController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Hola! Ingresa tus datos para poder comenzar',
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 32),
                        const SueltitoTextField(hintText: 'Nombre'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: const SueltitoTextField(
                                hintText: 'Primer Apellido',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: const SueltitoTextField(
                                hintText: 'Segundo Apellido',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: const SueltitoTextField(
                                hintText: 'C.I.',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SueltitoTextField(
                                hintText: 'Fecha de Nacimiento',
                                controller: _fechaNacimientoController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const SueltitoTextField(
                          hintText: 'Numero Celular:',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        const SueltitoTextField(
                          hintText: 'Correo',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/passenger_home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.textWhite,
                ),
                child: const Text('Continuar'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya formas parte de Sueltito? ',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/passenger_home');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Inicia sesion',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
