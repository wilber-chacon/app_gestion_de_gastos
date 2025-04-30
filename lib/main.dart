import 'package:flutter/material.dart';
import 'package:proyecto_gastos/screens/constants.dart';
import 'package:proyecto_gastos/screens/home/home_screen.dart';


void main() {
  runApp(const GastosApp());
}
//Clase principal
class GastosApp extends StatelessWidget {
  const GastosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( //Widget principal, configura la app
      title: 'Gastos personales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Color principal
        colorScheme: ColorScheme.fromSeed(seedColor: MainColor),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(), //Establece pantalla principal
    );
  }
}
