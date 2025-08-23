import 'package:flutter/material.dart';
import 'dart:convert'; // Although imported, not used in the provided snippet. Kept for completeness.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Primera App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(185, 61, 239, 141),
        ),
      ),
      home: AppPrincipal(),
    );
  }
}

const Map<String, String> currencies = {
  "usd": "US Dollar",
  "eur": "Euro",
  "btc": "Bitcoin",
  "eth": "Ethereum",
  "jpy": "Japanese Yen",
  "mxn": "Mexican Peso",
  "ars": "Argentine Peso",
  "brl": "Brazilian Real",
  "gbp": "British Pound",
  "cad": "Canadian Dollar",
};

class AppPrincipal extends StatefulWidget {
  @override
  State<AppPrincipal> createState() => _AppPrincipalState();
}

class _AppPrincipalState extends State<AppPrincipal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.currency_exchange),
            const SizedBox(width: 21),
            Text("Mi Cambio App"),
          ],
        ),
      ),
      body: ContenidoPrincipal(),
    );
  }
}

class ContenidoPrincipal extends StatefulWidget {
  @override
  State<ContenidoPrincipal> createState() => _ContenidoPrincipalState();
}

class _ContenidoPrincipalState extends State<ContenidoPrincipal> {
  final TextEditingController dateContrl = TextEditingController();
  String _sCurrency = "usd";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
          
            DropdownButton<String>(
              value: _sCurrency,
              isExpanded: true, // This makes the dropdown expand horizontally.
              items: currencies.entries
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text("${entry.value} ${entry.key.toLowerCase()}"),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                // Update the selected currency
                setState(() {
                  _sCurrency = newValue!;
                });
              },
            ),
            
        ),
      ),
    );
  }
}
