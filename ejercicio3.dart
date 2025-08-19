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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Text(data.value["Segundo Nombre"]),
                    Text(data.value["Apellido"]),
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
