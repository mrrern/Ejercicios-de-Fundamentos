import 'package:flutter/material.dart';

void main() {
  runApp(MyPrimeraApp());
}

class MyPrimeraApp extends StatelessWidget {
  //Aqui podemos definir variables de clase

  //Estructura interna del componente que vamos a construir
  @override
  Widget build(BuildContext context) {
    // aqui podemos establecer variables locales
    return MaterialApp(
      // Aqui va toda nuestra aplicacion
      title: "Mi primera aplicacion", // Titulo de App
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        //Definimos el tema con la clase ThemeData
        colorScheme: ColorScheme.fromSeed(
          //parte del tema
          seedColor: const Color.fromARGB(185, 61, 239, 141), //patrte del tema
        ),
      ), // final del tema

      home: CuerpoPrincipal(),
    );
  }
}

Map<String, Map<String, Map<String, dynamic>>> alumnos = {
  "Richard": {
    "Datos": {
      "Apellido": "Brito",
      "Segundo Nombre": "Jose",
      "Altura": 170.0,
      "Tiene Carro": false,
      "Mascotas": 9,
    },
  },
  "Rebeca": {
    "Datos": {
      "Apellido": "Carrero",
      "Segundo Nombre": "Maria",
      "Altura": 165.6,
      "Tiene Carro": false,
      "Mascotas": 9,
    },
  },
  "Naicy": {
    "Datos": {
      "Apellido": "Rojas",
      "Segundo Nombre": "De Brito",
      "Altura": 156.3,
      "Tiene Carro": false,
      "Mascotas": 1,
    },
  },
};

class CuerpoPrincipal extends StatefulWidget {
  @override
  State<CuerpoPrincipal> createState() => _CuerpoPrincipalState();
}

class _CuerpoPrincipalState extends State<CuerpoPrincipal> {
  //mis variables locales
  void agregarAlumno({
    required String alumno,
    required String segundoNombre,
    required String apellido,
    required double altura,
    required bool tieneCarro,
    required int mascotas,
  }) {
    alumnos.putIfAbsent(
      alumno,
      () => {
        //la usamos para agregar nuevos alumnos
        "Datos": {
          "Apellido": apellido,
          "Segundo Nombre": segundoNombre,
          "Altura": altura,
          "Tiene Carro": tieneCarro,
          "Mascotas": mascotas,
        },
      },
    );

    setState(() {}); // Esto es para refrescar el estado de la Interfase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AgregarAlumnos(onAgregar: agregarAlumno),
          );
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.account_box, color: Colors.white),
            Text("Alumnos"),
            Container(width: 200),
          ],
        ),
      ),
      body: ListView(
        children: alumnos.entries.map((sujeto) {
          var nombre = sujeto.key;
          return ExpansionTile(
            title: Text(nombre),
            children: sujeto.value.entries.map((data) {
              var datos = data.key;

              return ListTile(
                title: Text(datos),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Segundo Nombre: ${data.value["Segundo Nombre"]}"),
                    Text("Apellido: ${data.value["Apellido"]}"),
                    Text("Altura: ${data.value["Altura"]}"),
                    Text("Tiene Carro: ${data.value["Tiene Carro"]}"),
                    Text("Numero de Mascotas: ${data.value["Mascotas"]}"),
                  ],
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class AgregarAlumnos extends StatefulWidget {
  //Esta funcion es una variable de clase
  final Function({
    required String alumno,
    required String segundoNombre,
    required String apellido,
    required double altura,
    required bool tieneCarro,
    required int mascotas,
  })
  onAgregar;

  AgregarAlumnos({super.key, required this.onAgregar});

  @override
  State<AgregarAlumnos> createState() => _AgregarAlumnosState();
}

class _AgregarAlumnosState extends State<AgregarAlumnos> {
  //Vamos a definir las variables locales
  final TextEditingController ingresaAlumno = TextEditingController();
  final TextEditingController ingresaNombre = TextEditingController();
  final TextEditingController ingresaApellido = TextEditingController();
  final TextEditingController ingresaAltura = TextEditingController();
  bool ingresaCarro = false;
  final TextEditingController ingresaMascota = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("➕ Agregar Alumno"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: ingresaAlumno,
              decoration: InputDecoration(
                labelText: "Ingresa Alumno",
                hintText: "Primer Nombre del Alumno",
              ),
            ),
            TextField(
              controller: ingresaNombre,
              decoration: InputDecoration(
                labelText: "Nombre Alumno",
                hintText: "Segundo Nombre del Alumno",
              ),
            ),
            TextField(
              controller: ingresaApellido,
              decoration: InputDecoration(
                labelText: "Apellido",
                hintText: "Apellido del Alumno",
              ),
            ),
            TextField(
              controller: ingresaAltura,
              decoration: InputDecoration(
                labelText: "Altura",
                hintText: "Altura del Alumno",
              ),
            ),
            Row(
              children: [
                const Text("Tiene Carro?"),
                Checkbox(
                  value: ingresaCarro,
                  onChanged: (v) {
                    setState(() {
                      ingresaCarro = v ?? false;
                    });
                  },
                ),
              ],
            ),
            TextField(
              controller: ingresaMascota,
              decoration: InputDecoration(
                labelText: "Mascotas",
                hintText: "Ingresa # de Mascotas del Alumno",
              ),
            ),
          ],
        ),
      ), // El SingleChildScrollView sirve para poner mucha informacion en un contenedor pequeño

      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: () {
            final nombre = ingresaAlumno.text.trim();
            final segundo = ingresaNombre.text.trim();
            final apellido = ingresaApellido.text.trim();
            final double? altura = double.tryParse(ingresaAltura.text);
            final int? mascotas = int.tryParse(ingresaMascota.text);
            final bool tieneCarro = ingresaCarro;
            if (nombre.isNotEmpty &&    //Aqui valido que todos los campos esten llenos o no sube la informacion
                segundo.isNotEmpty &&
                apellido.isNotEmpty &&
                altura != null &&
                mascotas != null) {
              widget.onAgregar(       //Aqui llamo al componente AgregarUsuario con el termino widget y llamo la variable de clase onAgregar e ingreso los datos recolectados
                alumno: nombre,
                segundoNombre: segundo,
                apellido: apellido,
                altura: altura,
                tieneCarro: tieneCarro,
                mascotas: mascotas,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text("Agregar"),
        ),
      ],
    );
  }
}
