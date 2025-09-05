import 'dart:async';
import 'package:flutter/material.dart';

/*
 * Procesa pagos por internet con tarjeta de crédito en más de 135 divisas.
 * https://stripe.com/es
 * 
 * - Cómo recoger información del usuario.
 * - Cómo realizar un cargo asociado a un importe.
 * - Gestión de productos y precios.
 * - Manejo de errores.
 */

void main() => runApp(MyApp());

//Widget Principal ubicado en lib/myApp.dart

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Simulacion de Stripe",
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: CheckOutPage(),
    );
  }
}

// Estructura
// =========
// Modelo
//===================================

class Product {
  final int id;
  final String name;
  final double price;
  Product({required this.id, required this.name, required this.price});
}
//===================================

// Logica
//===================================

final List<Product> cart = [];
final currencies = ["USD", "EUR", "VES", "COP"];
final String currency = "USD";

final Map<String, int> currencyDecimal = {
  "USD": 2,
  "EUR": 2,
  "COP": 1,
  "VES": 2
};

 int pow10(int n) {
  int x = 1;
  for (int i = 0; i< n ; i++) {
    x *= 10;
  }
  return x;
}

int toMinorUnits(double amount, String currency){
  final decimals =  currencyDecimal[currency] ?? 2;
  final factor = pow10(decimals);
  return (amount * factor).round();
}

double get cartTotal => cart.fold<double>(0.0, ( sum, Product p) => sum + p.price);

Future<void> pay(
  BuildContext context, {
  required String name,
  required String email,
  required String cardNumber,
  required String holder,
}) async {
  FocusScope.of(context).unfocus();

  if (name.isEmpty || email.isEmpty || holder.isEmpty) {
    // In a real app, this would show an AlertDialog or SnackBar
    debugPrint('Rellena nombre, email y titular de tarjeta.');
  }
  if (!email.contains('@') || !email.contains(".")) {
    debugPrint("Email inválido.");
  }
  if (cardNumber.length < 16) {
    debugPrint("Numero de tarjeta invalido");
  }
  
  final amountMajor = cartTotal;
  final amountMinor = toMinorUnits(amountMajor, currency);
  
  try{
    final server =
  }catch(e) {
    
  }
  
}
//===================================


// Rutas
// Costantes
//===================================
//===================================
// Paginas
//===================================
class CheckOutPage extends StatefulWidget {
  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

//===================================
// Widgets reutilizables








// Valores de prueba

final List<Product> catalog = <Product>[
  Product(id: 1, name: "In Ears", price: 9.25),
  Product(id: 2, name: "Smartwatch", price: 129.99),
  Product(id: 3, name: "Wireless Keyboard", price: 75.50),
  Product(id: 4, name: "Gaming Mouse", price: 49.99),
  Product(id: 5, name: "USB-C Hub", price: 34.00),
  Product(id: 6, name: "External SSD 1TB", price: 110.00),
  Product(id: 7, name: "Bluetooth Speaker", price: 59.95),
  Product(id: 8, name: "Noise Cancelling Headphones", price: 199.99),
  Product(id: 9, name: "Webcam Full HD", price: 65.20),
  Product(id: 10, name: "Monitor 27-inch", price: 299.00),
  Product(id: 11, name: "Ergonomic Chair", price: 350.75),
  Product(id: 12, name: "Laptop Stand", price: 25.00),
  Product(id: 13, name: "Portable Charger", price: 39.99),
  Product(id: 14, name: "Travel Backpack", price: 89.90),
  Product(id: 15, name: "Tablet Stylus", price: 15.00),
  Product(id: 16, name: "Digital Drawing Tablet", price: 180.00),
  Product(id: 17, name: "Mini Projector", price: 220.50),
  Product(id: 18, name: "Smart Plug", price: 19.99),
  Product(id: 19, name: "Robot Vacuum", price: 289.00),
  Product(id: 20, name: "Air Purifier", price: 150.00),
  Product(id: 21, name: "Electric Kettle", price: 45.00),
  Product(id: 22, name: "Coffee Maker", price: 99.99),
  Product(id: 23, name: "Blender", price: 70.00),
  Product(id: 24, name: "Smart Scale", price: 40.00),
  Product(id: 25, name: "Fitness Tracker", price: 60.00),
  Product(id: 26, name: "Instant Camera", price: 85.00),
];

final bool simulationServerError = false;

//Logs para mostrar
final List<String> logs = [];
final bool isPlaying = false; 


// Simulador de Stripe

class FakeStripeServer {
  final bool simulatedError;
  final bool simulate3DS;
  
  FakeStripeServer({this.simulate3DS = false, this.simulatedError = false});
  
  Future<Map<String, dynamic>> createPaymentIntent({required int amountMinor, required String currency, Map<String, String>? metadata}) async{
    await Future.delayed(const Duration(milliseconds: 500));
    if(simulatedError) {
      throw Exception("500 Internal Server Error (simulado)");
    }
    if(amountMinor <= 0) {
      throw Exception("Monto Invalido");
    }
    
    //Devuelve un objeto parecido a un json con los datos de transacción
    return {
      "id" : 12547378934,
      "client_secret": "sakdjaskldñlAJSDÑLAKSJD21343534",
      "amount": amountMinor,
      "currency": currency,
      "metadata": metadata ?? {},
      "status" : "required_confirmation"
    };
  }
  
  Future<Map<String, dynamic>> confirmPayment({required String clientSecret, required Map<String, dynamic> paymentMethod}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    if (simulatedError){
      return {
        "status" : "failed",
        "error" : "Card declined"
      };
    }
    
    if(simulate3DS && paymentMethod["threeDS"] != "completed"){
      return {
        "status" : "requires_action",
        "action" : "secure_challenge"
      };
    }
    
    return {
      "status" : "completed",
       "charged" : [
         {
           "id" : 2345,
           "paid" : true,
         }
       ]
    };
  }
    
    
}