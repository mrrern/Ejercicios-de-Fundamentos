import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const DigimonApp());

class DigimonApp extends StatelessWidget {
  const DigimonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digimon API Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const DigimonHomePage(),
    );
  }
}

/// MODELO
class Digimon {
  final int id;
  final String name;
  final String image;
  final String level;
  final String types;
  final List<String> attrib;
  final List<String> descrip;

  Digimon({
    required this.id,
    required this.name,
    required this.image,
    required this.level,
    required this.types,
    required this.attrib,
    required this.descrip,
  });

  factory Digimon.fromJson(Map<String, dynamic> json) {
    return Digimon(
      id: json['id'] ?? 0,
      name: json["name"] ?? "Desconocido",
      image: (json["images"] != null && json["images"].isNotEmpty)
          ? json["images"][0]['href'] ?? ''
          : "",
      level: (json['levels'] != null && json["levels"].isNotEmpty)
          ? json["levels"][0]["level"] ?? ""
          : "",
      types: (json['types'] != null && json["types"].isNotEmpty)
          ? json["types"][0]["type"] ?? ""
          : "",
      attrib: (json['attributes'] != null)
          ? List<String>.from(
              json['attributes'].map((a) => a['attribute'] ?? ''),
            )
          : [],
      descrip: (json['descriptions'] != null)
          ? List<String>.from(
              json['descriptions'].map((d) => d['description'] ?? ''),
            )
          : [],
    );
  }
}

/// WIDGET PRINCIPAL
class DigimonHomePage extends StatefulWidget {
  const DigimonHomePage({super.key});

  @override
  State<DigimonHomePage> createState() => _DigimonHomePageState();
}

class _DigimonHomePageState extends State<DigimonHomePage> {
  List<Digimon> _digimons = [];
  List<Digimon> _filtered = [];
  bool _loading = false;
  bool _loadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDigimons();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// FETCH con detalles + paginación
  Future<void> fetchDigimons() async {
    if (_loadingMore) return; // evitar llamadas duplicadas

    setState(() {
      _loading = _digimons.isEmpty; // spinner solo en la carga inicial
      _loadingMore = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://digi-api.com/api/v1/digimon?page=$_currentPage&pageSize=$_pageSize'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> digimonList = data['content'];

        List<Digimon> fetched = [];

        for (var digimonData in digimonList) {
          try {
            final detailResponse = await http.get(
              Uri.parse(
                'https://digi-api.com/api/v1/digimon/${digimonData['id']}',
              ),
            );

            if (detailResponse.statusCode == 200) {
              final detailData = json.decode(detailResponse.body);
              fetched.add(Digimon.fromJson(detailData));
            }
          } catch (e) {
            debugPrint('Error al cargar digimon ${digimonData['id']}: $e');
          }
        }

        setState(() {
          _digimons.addAll(fetched);
          _filtered = _digimons;
          _currentPage++;
          _loading = false;
          _loadingMore = false;
        });
      } else {
        throw Exception('Error al cargar lista');
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar Digimons: $e')),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore) {
      fetchDigimons();
    }
  }

  void _filterDigimons(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _digimons;
      } else {
        _filtered = _digimons
            .where((d) =>
                d.name.toLowerCase().contains(query.toLowerCase()) ||
                d.level.toLowerCase().contains(query.toLowerCase()) ||
                d.types.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digimon Explorer"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar Digimon...",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onChanged: _filterDigimons,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _filtered.length +
                        (_loadingMore ? 1 : 0), // loading indicator al final
                    itemBuilder: (context, index) {
                      if (index == _filtered.length && _loadingMore) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return DigimonCard(digimon: _filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// TARJETA con animación
class DigimonCard extends StatefulWidget {
  final Digimon digimon;

  const DigimonCard({super.key, required this.digimon});

  @override
  State<DigimonCard> createState() => _DigimonCardState();
}

class _DigimonCardState extends State<DigimonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.digimon;
    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    d.image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  d.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                if (d.level.isNotEmpty) Text("Nivel: ${d.level}"),
                if (d.types.isNotEmpty) Text("Tipo: ${d.types}"),
                if (d.attrib.isNotEmpty)
                  Text("Atributos: ${d.attrib.join(", ")}"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
