import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Widget Principal ubicado en lib/myApp.dart

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartModel>(
      create: (context) => CartModel(),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Simulacion de Stripe",
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: CheckOutPage(),
      ),
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

  // Override hashCode and == for proper removal from lists
  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is Product && other.id == id;
}

class CartModel extends ChangeNotifier {
  final List<Product> _productsInCart = <Product>[];
  final String _currency = "USD";

  List<Product> get productsInCart => List.unmodifiable(_productsInCart);
  String get currency => _currency;

  double get total =>
      _productsInCart.fold<double>(0.0, (sum, Product p) => sum + p.price);

  void addProduct(Product product) {
    _productsInCart.add(product);
    notifyListeners();
  }

  void removeProduct(Product product) {
    _productsInCart.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _productsInCart.clear();
    notifyListeners();
  }
}

//===================================

// Logica
//===================================

final Map<String, int> currencyDecimal = {
  "USD": 2,
  "EUR": 2,
  "COP": 1,
  "VES": 2,
};

int pow10(int n) {
  int x = 1;
  for (int i = 0; i < n; i++) {
    x *= 10;
  }
  return x;
}

int toMinorUnits(double amount, String currency) {
  final decimals = currencyDecimal[currency] ?? 2;
  final factor = pow10(decimals);
  return (amount * factor).round();
}

Future<bool> showDialog3DS(BuildContext context) async {
  //concatenacion de valor con visual. Donde al mostrar el Dialog, retorna una respuesta true al server
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Autenticación Requerida"),
          content: const Text(
            "Este pago requiere una verificación 3D Secure. \n Presiona Aceptar para continuar",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Aceptar"),
            ),
          ],
        ),
      ) ??
      false;
}

void snack({required BuildContext context, required String msg}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

Future<void> pay(
  BuildContext context, {
  required String name,
  required String email,
  required String cardNumber,
  required String holder,
}) async {
  FocusScope.of(context).unfocus();

  final cartModel = Provider.of<CartModel>(context, listen: false);

  if (name.isEmpty || email.isEmpty || holder.isEmpty) {
    snack(context: context, msg: 'Rellena nombre, email y titular de tarjeta.');
    return;
  }
  if (!email.contains('@') || !email.contains(".")) {
    snack(context: context, msg: "Email inválido.");
    return;
  }
  if (cardNumber.length < 16) {
    snack(context: context, msg: "Numero de tarjeta invalido");
    return;
  }
  if (cartModel.total <= 0) {
    snack(context: context, msg: "El carrito está vacío.");
    return;
  }

  final amountMajor = cartModel.total;
  final amountMinor = toMinorUnits(amountMajor, cartModel.currency);

  try {
    debugPrint(
      "Creando pago por $amountMajor ${cartModel.currency} (${amountMinor} menores unidades)",
    );

    final server = FakeStripeServer(simulate3DS: false, simulatedError: false);

    final pi = await server.createPaymentIntent(
      currency: cartModel.currency,
      amountMinor: amountMinor,
      metadata: {
        'customer_name': name,
        'customer_email': email,
        'items': cartModel.productsInCart.map<int>((p) => p.id).join(","),
      },
    );

    debugPrint("Intento de Pago Creado: ${pi["id"]}");

    final confirm1 = await server.confirmPayment(
      clientSecret: pi['client_secret'] as String,
      paymentMethod: {"cardNumber": cardNumber, "holder": holder},
    );

    if (confirm1['status'] == "requires_action") {
      final ok = await showDialog3DS(context);
      if (!ok) {
        snack(context: context, msg: "Usuario canceló el pago");
        return;
      }
      final confirm2 = await server.confirmPayment(
        clientSecret: pi["client_secret"] as String,
        paymentMethod: {
          "cardNumber": cardNumber,
          "holder": holder,
          "threeDS": "completed",
        },
      );
      if (confirm2['status'] == "completed") {
        snack(context: context, msg: "Pago Exitoso");
        cartModel.clearCart();
      } else {
        snack(context: context, msg: "Transacción Fallida");
      }
    } else if (confirm1['status'] == 'completed') {
      snack(context: context, msg: "Pago Aprobado ✅");
      cartModel.clearCart();
    } else {
      snack(context: context, msg: "Pago no Aprobado X.X");
    }
  } catch (e) {
    debugPrint("Error: $e");
    snack(context: context, msg: "Error al procesar el pago");
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

class _CheckOutPageState extends State<CheckOutPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simulación de Stripe"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: "Productos", icon: Icon(Icons.shopping_bag)),
            Tab(text: "Carrito", icon: Icon(Icons.shopping_cart)),
            Tab(text: "Pago", icon: Icon(Icons.payment)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ProductCatalogView(),
          ShoppingCartView(),
          PaymentFormView(),
        ],
      ),
    );
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

class ProductCatalogView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Selecciona productos para agregar al carrito:",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: catalog.length,
            itemBuilder: (context, index) {
              final product = catalog[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      Provider.of<CartModel>(
                        context,
                        listen: false,
                      ).addProduct(product);
                      snack(
                        context: context,
                        msg: "${product.name} añadido al carrito!",
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ShoppingCartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        if (cart.productsInCart.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  "Tu carrito está vacío",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          );
        }
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Total del carrito: ${cart.currency} ${cart.total.toStringAsFixed(2)}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cart.productsInCart.length,
                itemBuilder: (context, index) {
                  final product = cart.productsInCart[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_shopping_cart,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          cart.removeProduct(product);
                          snack(
                            context: context,
                            msg: "${product.name} eliminado del carrito.",
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  cart.clearCart();
                  snack(context: context, msg: "Carrito vaciado.");
                },
                icon: const Icon(Icons.clear_all),
                label: const Text("Vaciar Carrito"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50), // Make button wider
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PaymentFormView extends StatefulWidget {
  @override
  State<PaymentFormView> createState() => _PaymentFormViewState();
}

class _PaymentFormViewState extends State<PaymentFormView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(
    text: "Jane Doe",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "jane.doe@example.com",
  );
  final TextEditingController _cardNumberController = TextEditingController(
    text: "4242424242424242",
  ); // Test card
  final TextEditingController _holderController = TextEditingController(
    text: "Jane A. Doe",
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cardNumberController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Detalles de Pago",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre Completo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Por favor ingresa tu nombre";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Correo Electrónico",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Por favor ingresa tu correo";
                }
                if (!value.contains('@') || !value.contains(".")) {
                  return "Correo electrónico inválido";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Número de Tarjeta",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              maxLength: 16,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Por favor ingresa el número de tarjeta";
                }
                if (value.length != 16 || int.tryParse(value) == null) {
                  return "Número de tarjeta inválido (16 dígitos)";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _holderController,
              decoration: const InputDecoration(
                labelText: "Titular de la Tarjeta",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Por favor ingresa el titular de la tarjeta";
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            Consumer<CartModel>(
              builder: (context, cart, child) {
                return ElevatedButton.icon(
                  onPressed: cart.total > 0
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            pay(
                              context,
                              name: _nameController.text,
                              email: _emailController.text,
                              cardNumber: _cardNumberController.text,
                              holder: _holderController.text,
                            );
                          }
                        }
                      : null, // Disable button if cart is empty
                  icon: const Icon(Icons.payment),
                  label: Text(
                    "Pagar Ahora (${cart.currency} ${cart.total.toStringAsFixed(2)})",
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final bool simulationServerError = false;

//Logs para mostrar (not used in UI, kept for consistency with original)
final List<String> logs = [];
final bool isPlaying = false;

// Simulador de Stripe

class FakeStripeServer {
  final bool simulatedError;
  final bool simulate3DS;

  FakeStripeServer({this.simulate3DS = false, this.simulatedError = false});

  Future<Map<String, dynamic>> createPaymentIntent({
    required int amountMinor,
    required String currency,
    Map<String, String>? metadata,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (simulatedError) {
      throw Exception("500 Internal Server Error (simulado)");
    }
    if (amountMinor <= 0) {
      throw Exception("Monto Invalido");
    }

    //Devuelve un objeto parecido a un json con los datos de transacción
    return {
      "id": 12547378934,
      "client_secret": "sakdjaskldñlAJSDÑLAKSJD21343534",
      "amount": amountMinor,
      "currency": currency,
      "metadata": metadata ?? {},
      "status": "required_confirmation",
    };
  }

  Future<Map<String, dynamic>> confirmPayment({
    required String clientSecret,
    required Map<String, dynamic> paymentMethod,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (simulatedError) {
      return {"status": "failed", "error": "Card declined"};
    }

    if (simulate3DS && paymentMethod["threeDS"] != "completed") {
      return {"status": "requires_action", "action": "secure_challenge"};
    }

    return {
      "status": "completed",
      "charged": [
        {"id": 2345, "paid": true},
      ],
    };
  }
}

void main() => runApp(MyApp());
