import 'package:flutter/material.dart';
import 'dart:convert'; // --- NUEVO --- (Para json.decode y utf8.decode)
import 'package:nfc_manager/nfc_manager.dart'; // --- NUEVO --- (El paquete NFC)

// Core
import 'package:sueltito/core/config/app_theme.dart';

// Feature: Auth
import 'package:sueltito/features/auth/presentation/pages/splash_page.dart';
import 'package:sueltito/features/auth/presentation/pages/welcome_page.dart';
import 'package:sueltito/features/auth/presentation/pages/sign_up_page.dart';

// Feature: Main Navigation (Shell)
import 'package:sueltito/features/main_navigation/presentation/pages/main_navigation_page.dart';

// --- NUEVO IMPORT ---
import 'package:sueltito/features/payment/presentation/pages/minibus_payment_page.dart';

// --- NUEVO ---
// Clave global para poder navegar desde el listener de NFC (que no tiene context)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async { // --- MODIFICADO --- (convertido a async)
  // --- NUEVO ---
  // Aseguramos que Flutter esté inicializado antes de llamar código nativo
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- NUEVO ---
  // Iniciamos el "oyente" de NFC y esperamos a que se configure
  await _setupNfcListener();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // --- NUEVO --- (Asignamos la clave global)
      debugShowCheckedModeBanner: false,
      title: 'Sueltito',
      theme: getAppTheme(),
      home: const SplashPage(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/sign_up': (context) => const SignUpPage(),
        '/passenger_home': (context) => const MainNavigationPage(),
        '/minibus_payment': (context) => const MinibusPaymentPage(),
      },
    );
  }
}
Future<void> _setupNfcListener() async {
  bool isAvailable = await NfcManager.instance.isAvailable();

  if (isAvailable) {
    try {
      NfcManager.instance.startSession(
        // Opciones de polling
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        
        onDiscovered: (NfcTag tag) async {
          try {
            // ------ ESTA ES LA LÍNEA DEL PROBLEMA ------
            // (El error de 'Ndef' debería desaparecer después del Paso 2)
            var ndef = Ndef.from(tag); 
            // ------------------------------------------

            if (ndef == null || ndef.cachedMessage == null) {
              print("NFC Error: No se encontró mensaje NDEF.");
              return;
            }

            final record = ndef.cachedMessage!.records.first;
            final String mimeType = utf8.decode(record.type);

            if (mimeType == "application/vnd.sueltito") {
              final String jsonString = utf8.decode(record.payload);
              final Map<String, dynamic> conductorData = json.decode(jsonString);

              print("¡Tag 'sueltito' detectado! Datos: $conductorData");

              navigatorKey.currentState?.pushNamed(
                '/minibus_payment',
                arguments: conductorData,
              );
            } else {
              print("Tag NFC detectado, pero no es 'vnd.sueltito'. Es: $mimeType");
            }
            
          } catch (e) {
            print("Error al leer el tag NFC: $e");
          }
        },
      );
    } catch (e) {
      print("Error al iniciar la sesión NFC: $e");
    }
  } else {
    print("NFC no está disponible en este dispositivo.");
  }
}