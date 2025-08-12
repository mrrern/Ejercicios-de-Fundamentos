void main() {
  inventarioIntermedio();
}

void stockSimple() {
  List<String> productos = [];
  Map<String, int> stock = {};

  productos = [
    'Laptop',
    'Teclado',
    "Mouse",
    "Monitor",
    "Mousepad",
    "TV",
    'Router',
  ];

  stock = {
    productos[0]: 4,
    productos[1]: 6,
    productos[2]: 10,
    productos[3]: 6,
    productos[4]: 6,
    productos[5]: 6,
    productos[6]: 1,
  };

  void buscarProducto(String producto, Map<String, int> stock) {
    var productosOrdenados = stock[producto];

    if (!stock.containsKey(producto)) {
      print("⚠ $producto no se encuentra en el sistema");
      return;
    }

    print("📦$producto tiene $productosOrdenados unidades");
  }

  productos.add("Auriculares");

  stock["Auriculares"] = 12;

  buscarProducto("Mesa", stock);
}

void inventarioIntermedio() {
  // Un Map donde la clave es el nombre del producto y el valor es otro Map
  // con sus propiedades (stock, precio).
  Map<String, Map<String, dynamic>> inventario;

  inventario = {
    "Laptop": {'stock': 4, 'precio': 185.3},
    'Teclado': {'stock': 6, 'precio': 85.5},
    'Mouse': {'stock': 12, 'precio': 25.0},
  };

  void listarInventario(Map<String, Map<String, dynamic>> inventario) {
    inventario.forEach((producto, detalles) {
      print(
        "$producto : Tiene ${detalles["stock"]} unidades | Costo : ${detalles['precio']} \$",
      );
    });
  }

  void buscarEnInventario({
    required String product,
    required Map<String, Map<String, dynamic>> datos,
  }) {
    var stockDeProducto = datos[product]!.values.first;

    var precio = datos[product]!.values.last;
    
    if (!datos.containsKey(product)) {
      print("⚠ $product no se encuentra en el sistema");
      return;
    }

    print("📦$product tiene $stockDeProducto unidades | Precio $precio \$");
  }

  print("Inventario Actual:");
  buscarEnInventario(product: "Teclado", datos: inventario);
}
