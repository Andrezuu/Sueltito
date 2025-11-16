import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/widgets/sueltito_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers
  final nameCtrl = TextEditingController();
  final apellido1Ctrl = TextEditingController();
  final apellido2Ctrl = TextEditingController();
  final ciCtrl = TextEditingController();
  final complementoCtrl = TextEditingController();
  final expedidoCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  // PIN controllers
  final pinCtrl = List.generate(4, (_) => TextEditingController());

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
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Hola! Ingresa tus datos para poder comenzar',
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Nombre
                      SueltitoTextField(
                        hintText: 'Nombre',
                        controller: nameCtrl,
                      ),
                      const SizedBox(height: 16),

                      // Apellidos
                      Row(
                        children: [
                          Expanded(
                            child: SueltitoTextField(
                              hintText: 'Primer Apellido',
                              controller: apellido1Ctrl,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SueltitoTextField(
                              hintText: 'Segundo Apellido',
                              controller: apellido2Ctrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // CI + Expedición
                      Row(
                        children: [
                          Expanded(
                            child: SueltitoTextField(
                              hintText: 'C.I.',
                              controller: ciCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SueltitoTextField(
                              hintText: 'Expedido (LP)',
                              controller: expedidoCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Complemento
                      SueltitoTextField(
                        hintText: 'Complemento (opcional)',
                        controller: complementoCtrl,
                      ),
                      const SizedBox(height: 16),

                      // Fecha de nacimiento
                      SueltitoTextField(
                        hintText: "Fecha de Nacimiento (YYYY-MM-DD)",
                        controller: fechaCtrl,
                        keyboardType: TextInputType.none,
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primaryGreen,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (picked != null) {
                            fechaCtrl.text =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Celular
                      SueltitoTextField(
                        hintText: 'Celular',
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        prefixText: "+591 ",
                      ),
                      const SizedBox(height: 16),

                      // Email
                      SueltitoTextField(
                        hintText: 'Correo',
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 32),

                      // PIN
                      Text(
                        "Crea tu PIN de seguridad",
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (i) {
                          return SizedBox(
                            width: 55,
                            child: TextField(
                              controller: pinCtrl[i],
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                counterText: "",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && i < 3) {
                                  FocusScope.of(context).nextFocus();
                                }
                                if (value.isEmpty && i > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Botón continuar
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/nfc_scan');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya formas parte de Sueltito? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/passenger_home');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Inicia sesión',
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
