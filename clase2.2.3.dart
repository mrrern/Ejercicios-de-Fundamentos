import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //Si definimos variables en esta seccion seran variables de clase
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    //Si definimos variables en esta seccion son variables locales
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

Map<String, Map<String, Map<String, dynamic>>> inventario = {
  "Electronica": {
    "Laptop": {"Precio": 120, "Stock": 20},
  },
  "Mobiliario": {
    "Mesa": {"Precio": 50.8, "Stock": 12},
  },
};

class AppPrincipal extends StatefulWidget {
  @override
  State<AppPrincipal> createState() => _AppPrincipalState();
}

class _AppPrincipalState extends State<AppPrincipal> {
  //Si definimos variables aqui, seran variables locales

  List<MapEntry<String, Map<String, dynamic>>> listarProductos(
    String categoria,
  ) {
    if (!inventario.containsKey(categoria)) return [];
    return inventario[categoria]!.entries.toList();
  }

  void agregarProducto({
    required String categoria,
    required String producto,
    required double precio,
    required int stock,
  }) {
    inventario.putIfAbsent(categoria, () => {});
    inventario[categoria]![producto] = {"Precio": precio, "Stock": stock};

    setState(() {}); // refresca la Interfaz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("📦 Inventario"),
      ),
      body: ListView(
        children: inventario.entries.map((categoria) {
          var categorias = categoria.key;
          return ExpansionTile(
            title: Text(
              "📂 $categorias",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: categoria.value.entries
                .map(
                  (prod) => ListTile(
                    title: Text(
                      prod.key,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Precio: ${prod.value["Precio"]}\$"),
                        Text("Stock: ${prod.value["Stock"]} unidades"),
                      ],
                    ),
                  ),
                )
                .toList(),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
          showDialog(
          context: context,
          builder: (context) {
            return AgregarProducto(
            onAgregar: agregarProducto,
            );
          }
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AgregarProducto extends StatefulWidget {
  final Function({
    required String categoria,
    required String producto,
    required double precio,
    required int stock,
  })
  onAgregar;

  AgregarProducto({super.key, required this.onAgregar});

  @override
  State<AgregarProducto> createState() => _AgregarProductoState();
}

class _AgregarProductoState extends State<AgregarProducto> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController categoriaField = TextEditingController();
    final TextEditingController productoField = TextEditingController();
    final TextEditingController precioField = TextEditingController();
    final TextEditingController stockField = TextEditingController();

    return AlertDialog(
      title: const Text("➕ Agregar Producto"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: categoriaField,
              decoration: InputDecoration(
                labelText: 'Categoria',
                hintText: "Introduzca Categoria",
              ),
            ),
            TextField(
              controller: productoField,
              decoration: InputDecoration(
                labelText: 'Producto',
                hintText: "Introduzca Producto",
              ),
            ),
            TextField(
              controller: precioField,
              decoration: InputDecoration(
                labelText: 'precio',
                hintText: "Introduzca Precio",
              ),
            ),
            TextField(
              controller: stockField,
              decoration: InputDecoration(
                labelText: 'Inventario',
                hintText: "Introduzca cuantos hay",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text("Agregar"),
          onPressed: () {
            final categoria = categoriaField.text.trim();
            final producto = productoField.text.trim();
            final double? precio = double.tryParse(precioField.text);
            final int? stock = int.tryParse(stockField.text);

            if (categoria.isNotEmpty &&
                producto.isNotEmpty &&
                precio != null &&
                stock != null) {
              widget.onAgregar(
                categoria: categoria,
                producto: producto,
                precio: precio,
                stock: stock,
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
