import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: DigimonCard())),
    );
  }
}

class DigimonCard extends StatefulWidget {
  final Digimon digimon;

  DigimonCard({required this.digimon});

  @override
  _DigimonCardState createState() => _DigimonCardState();
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
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          margin: EdgeInsets.all(15),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Image.network(widget.digimon.image, fit: BoxFit.cover),
                  Text(
                    widget.digimon.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    children: [
                      // Nivel
                      if (widget.digimon.level.isNotEmpty)
                        Column(
                          children: [
                            Text(
                              "Nivel",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              widget.digimon.level,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      //Atributos
                      if (widget.digimon.attrib.isNotEmpty)
                        Column(
                          children: [
                            Text(
                              "Atributos",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Wrap(
                              children: widget.digimon.attrib.map((at) {
                                return Text(at);
                              }).toList(),
                            ),
                          ],
                        ),

                      //Tipo
                      if (widget.digimon.level.isNotEmpty)
                        Column(
                          children: [
                            Text(
                              "Tipo",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              widget.digimon.types,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      //Descripcion
                      if (widget.digimon.descrip.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.digimon.attrib.last,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Digimon {
  final id;
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
      image: (json["images"] != null && json['image'].isNotEmpty)
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
              json['attributes'].map((atrrib) => atrrib['attribute'] ?? ''),
            )
          : [],
      descrip: (json['descriptions'] != null)
          ? List<String>.from(
              json['descriptions'].map((atrrib) => atrrib['description'] ?? ''),
            )
          : [],
    );
  }
}
