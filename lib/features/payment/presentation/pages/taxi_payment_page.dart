// --- NUEVO: Imports necesarios ---
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// --- FIN NUEVO ---

import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/features/payment/domain/enums/payment_status_enum.dart';
import 'package:sueltito/features/payment/presentation/widgets/payment_confirmation_dialog.dart';
import 'package:sueltito/features/payment/domain/entities/pasaje.dart';

class TaxiPaymentPage extends StatefulWidget {
  const TaxiPaymentPage({super.key});

  @override
  State<TaxiPaymentPage> createState() => _TaxiPaymentPageState();
}

class _TaxiPaymentPageState extends State<TaxiPaymentPage> {
  // --- NUEVO: Variable para los datos del NFC ---
  Map<String, dynamic>? _conductorData;
  // --- FIN NUEVO ---

  final List<Pasaje> _pasajesSeleccionados = [];
  bool _simulateSuccess = true;
  final TextEditingController _montoController = TextEditingController();
  String? _montoError;

  @override
  void initState() {
    super.initState();
    _montoController.addListener(_actualizarMonto);
  }

  // --- NUEVO: Recibir datos del NFC ---
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_conductorData == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        setState(() {
          _conductorData = args;
        });
      } else {
        print("Error: TaxiPaymentPage se abrió sin datos del conductor.");
      }
    }
  }
  // --- FIN NUEVO ---

  @override
  void dispose() {
    _montoController.removeListener(_actualizarMonto);
    _montoController.dispose();
    super.dispose();
  }

  // --- LÓGICA ---
  void _actualizarMonto() {
    double? monto = double.tryParse(_montoController.text);
    setState(() {
      _pasajesSeleccionados.clear(); // Limpiamos la lista
      if (monto != null && monto > 0) {
        // Si el monto es válido, lo añadimos como el único pasaje
        _pasajesSeleccionados.add(Pasaje(nombre: 'Pasaje Taxi', precio: monto));
        _montoError = null;
      } else if (_montoController.text.isNotEmpty) {
        _montoError = "Monto inválido"; // Error si escriben "abc"
      } else {
        _montoError = null; // Sin error si está vacío
      }
    });
  }

  double get totalAPagar =>
      _pasajesSeleccionados.fold(0.0, (sum, item) => sum + item.precio);

  // --- BUILD ---
  @override
  Widget build(BuildContext context) {
    // --- NUEVO: Loading state ---
    if (_conductorData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // --- FIN NUEVO ---

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- MODIFICADO: Pasamos los datos ---
                  _buildDriverInfoCard(_conductorData!), 
                  const SizedBox(height: 24),
                  _buildFareSelection(context),
                  const SizedBox(height: 24),
                  _buildPayButton(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildSummaryCard(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'Bienvenido al Taxi\nFabricio',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // --- MODIFICADO: Tarjeta Dinámica ---
  Widget _buildDriverInfoCard(Map<String, dynamic> driverData) {
    final propietario = driverData['propietario'] as Map<String, dynamic>? ?? {};
    final servicio = driverData['servicio'] as Map<String, dynamic>? ?? {};

    final String nombre = propietario['nombre'] as String? ?? 'Conductor no encontrado';
    final String placa = servicio['identificador'] as String? ?? 'S/N';
    final String nombreEmpresa = servicio['nombre'] as String? ?? 'Radio Taxi';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Placa: $placa',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                nombre,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              Text(
                nombreEmpresa, // Ej: "RADIO TAXI MAGNIFICO"
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          const Icon(Icons.local_taxi, size: 40, color: AppColors.textBlack),
        ],
      ),
    );
  }
  // --- FIN MODIFICADO ---

  Widget _buildFareSelection(BuildContext context) {
    // (Esta parte está bien, es tu input de monto manual)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingrese el monto a Pagar',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _montoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixText: 'Bs ',
            prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            errorText: _montoError,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(BuildContext context) {
    bool hasItems = _pasajesSeleccionados.isNotEmpty;

    return Column(
      children: [
        ElevatedButton(
          onPressed: hasItems
              ? () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) {
                      return PaymentConfirmationDialog(
                        pasajes: _pasajesSeleccionados,
                        total: totalAPagar,
                        onConfirm: () async {
                          
                          // --- NUEVO: Preparar Payload para Backend ---
                          final List<Map<String, dynamic>> pasajesJSON =
                              _pasajesSeleccionados.map((p) => {
                                    'nombre': p.nombre,
                                    'precio': p.precio,
                                  }).toList();

                          final Map<String, dynamic> payloadToSend = {
                            'info_conductor': _conductorData,
                            'detalle_pago': {
                              'pasajes': pasajesJSON,
                              'total_pagado': totalAPagar,
                            },
                            'pasajero_id': 'fabricio_id',
                            'timestamp': DateTime.now().toIso8601String(),
                          };
                          
                          print("--- ENVIANDO PAGO TAXI ---");
                          print(json.encode(payloadToSend));
                          // --- FIN NUEVO ---

                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );

                          final PaymentStatus resultStatus;
                          if (_simulateSuccess) {
                            resultStatus = PaymentStatus.success;
                          } else {
                            resultStatus = PaymentStatus.rejected;
                          }

                          setState(() {
                            _simulateSuccess = !_simulateSuccess;
                          });

                          Navigator.of(dialogContext).pop();

                          Navigator.of(context).pushNamed(
                            '/payment_status',
                            arguments: resultStatus,
                          );

                          // --- NUEVO: GUARDAR EN HISTORIAL ---
                          if (resultStatus == PaymentStatus.success) {
                            try {
                              final prefs = await SharedPreferences.getInstance();
                              final List<String> historialJson =
                                  prefs.getStringList('historial') ?? [];
                              final String timestamp =
                                  DateTime.now().toIso8601String();

                              // Guardamos como tipo 'taxi'
                              final List<String> nuevosItemsJson =
                                  _pasajesSeleccionados.map((pasaje) {
                                final Map<String, dynamic> transaccion = {
                                  'type': 'taxi', // <--- TIPO TAXI
                                  'timestamp': timestamp,
                                  'nombre': pasaje.nombre, // Dirá "Pasaje Taxi"
                                  'precio': pasaje.precio,
                                };
                                return json.encode(transaccion);
                              }).toList();

                              historialJson.addAll(nuevosItemsJson);
                              await prefs.setStringList(
                                  'historial', historialJson);
                              print("Historial Taxi guardado!");
                              
                            } catch (e) {
                              print("Error guardando historial: $e");
                            }

                            // Limpiar
                            setState(() {
                              _pasajesSeleccionados.clear();
                              _montoController.clear();
                            });
                          }
                          // --- FIN NUEVO ---
                        },
                      );
                    },
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
            backgroundColor: hasItems
                ? const Color.fromARGB(255, 84, 209, 190)
                : Colors.grey[400],
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[500],
          ),
          child: const Icon(Icons.attach_money, size: 35),
        ),
        const SizedBox(height: 8),
        Text(
          'ENVIAR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: hasItems ? AppColors.primaryGreen : Colors.grey,
          ),
        ),
      ],
    );
  }

  // ... (El resto de _buildSummaryCard y _buildSummaryItem queda igual)
  Widget _buildSummaryCard(BuildContext context) {
    Map<String, int> pasajeCounts = {};
    for (var pasaje in _pasajesSeleccionados) {
      pasajeCounts[pasaje.nombre] = (pasajeCounts[pasaje.nombre] ?? 0) + 1;
    }

    List<Widget> itemsWidget = pasajeCounts.entries.map((entry) {
      String nombre = entry.key;
      int cantidad = entry.value;
      double precioUnitario = _pasajesSeleccionados
          .firstWhere((p) => p.nombre == nombre)
          .precio;
      double subtotal = cantidad * precioUnitario;

      return _buildSummaryItem(
        context,
        nombre,
        '$cantidad carrera', // Singular para taxi usualmente
        subtotal,
        () {
          setState(() {
            _pasajesSeleccionados.clear();
            _montoController.clear();
          });
        },
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Selección de Pasajes',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_pasajesSeleccionados.isEmpty)
            const Text(
              'Ingrese un monto para comenzar...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ...itemsWidget,
          const Divider(height: 32, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Bs. ${totalAPagar.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String subtitle,
    double subtotal,
    VoidCallback onQuitar,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Bs ${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onQuitar,
                child: Text(
                  'quitar',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}