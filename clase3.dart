import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting

void main() {
  runApp(const MyApp());
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
        useMaterial3: true,
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
        title: const Row(
          children: [
            Icon(Icons.currency_exchange),
            SizedBox(width: 21),
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
  bool loading = false;
  DateTime sTime = DateTime.now();
  Map<String, dynamic> currenciesRates = {};

  // Function to fetch exchange rates
  Future<Map<String, dynamic>> exchangeRates(
    String currency,
    DateTime date,
  ) async {
    final timeformat =
        "${date.year.toString().padLeft(4, "0")}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final urls = [
      "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$timeformat/v1/currencies/$currency.json",
      "https://$timeformat.currency-api.pages.dev/v1/currencies/$currency.json",
    ];

    for (var url in urls) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final decodedBody = json.decode(response.body);
          if (decodedBody != null && decodedBody.containsKey(currency)) {
            // Access the nested currency map
            return decodedBody[currency] as Map<String, dynamic>;
          }
        }
      } catch (e) {
        debugPrint("Error fetching currency from $url: $e");
      }
    }

    throw Exception(
      "Could not load exchange rates for $currency on $timeformat",
    );
  }

  // Function to load rates
  void cargarRates() async {
    if (_sCurrency.isEmpty) return;
    setState(() {
      loading = true;
    });

    try {
      final rates = await exchangeRates(_sCurrency, sTime);
      setState(() {
        currenciesRates = rates;
        loading = false;
        // Update the date controller text
        dateContrl.text = DateFormat('yyyy-MM-dd').format(sTime);
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: sTime,
      firstDate: DateTime(2000), // Allowing older dates
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != sTime) {
      setState(() {
        sTime = picked;
      });
      cargarRates();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize date controller text
    dateContrl.text = DateFormat('yyyy-MM-dd').format(sTime);
    cargarRates();
  }

  @override
  void dispose() {
    dateContrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16.0,
        ), // Added padding for better aesthetics
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Fix: Make column children stretch horizontally
          children: [
            Row(
              children: [
                Expanded(
                  // Fix: Wrap DropdownButton in Expanded to take available space
                  child: DropdownButton<String>(
                    value: _sCurrency,
                    // isExpanded: true is not needed when wrapped in Expanded
                    items: currencies.entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(
                              "${entry.value} (${entry.key.toUpperCase()})",
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue != _sCurrency) {
                        setState(() {
                          _sCurrency = newValue;
                        });
                        cargarRates();
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 8,
                ), // Spacing between dropdown and date input
                SizedBox(
                  width: 120, // Give TextField a fixed width
                  child: TextField(
                    controller: dateContrl,
                    readOnly: true, // Make it read-only
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    onTap: pickDate, // Open date picker on tap
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: pickDate,
                ),
              ],
            ),
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : currenciesRates.isEmpty
                ? const Center(
                    child: Text(
                      "No data available for selected currency and date.",
                    ),
                  )
                : ListView.builder(
                    shrinkWrap:
                        true, // Important for ListView inside SingleChildScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                    itemCount: currenciesRates.length,
                    itemBuilder: (context, index) {
                      final entry = currenciesRates.entries.elementAt(index);
                      final targetCurrencyCode = entry.key;
                      final rate = entry.value;
                      final targetCurrencyName =
                          currencies[targetCurrencyCode] ??
                          targetCurrencyCode.toUpperCase();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$targetCurrencyName (${targetCurrencyCode.toUpperCase()})",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                rate.toStringAsFixed(4), // Format rate
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
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
