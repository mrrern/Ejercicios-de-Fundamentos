void main() {
  String nombre;
  int edad;
  String? apellido;
  double altura;

  nombre = 'Jesus';
  edad = 18;
  altura = 1.78;

  print("Bienvenido $nombre $apellido");
  print("Tu edad es $edad");
  print("Tu altura  es $altura\m");

  print("");

  print('Calcluladora');
  //   calculdora();

  //   print('resta');
  //   resta();

  //   print('multiplicacion');
  //   multiplicacion();
  //   print('divicion');
  //   divicion();
  calcAvanzada();
}

void calculdora() {
  double? numero1;
  double? numero2;
  double suma;

  numero1 = 23.1;
  numero2 = 25.2;
  suma = numero1 + numero2;

  print(suma);
}

void resta() {
  double? numero1;
  double? numero2;
  double resta;

  numero1 = 23.1;
  numero2 = 25.2;
  resta = numero1 - numero2;

  print(resta);
}

void multiplicacion() {
  double? numero1;
  double? numero2;
  double multiplicacion;

  numero1 = 23.1;
  numero2 = 25.2;
  multiplicacion = numero1 * numero2;

  print(multiplicacion);
}

void divicion() {
  double? numero1;
  double? numero2;
  double divicion;

  numero1 = 23.1;
  numero2 = 25.2;
  divicion = numero1 / numero2;

  print(divicion);
}

void calcAvanzada() {
  double? numero1;
  double? numero2;
  double? resultado;
  String operador;

  int num1;
  int num2;

  operador = "+";
  numero1 = 123.2;
  numero2 = 12.12;

  if (operador == '/') {
    resultado = numero1 / numero2;
    print(resultado);
  }
  if (operador == '/int') {
    num1 = numero1.toInt();
    num2 = numero2.toInt();
    resultado = (num1 ~/ num2).toDouble();
    print(resultado);
  }
  if (operador == '+') {
    resultado = numero1 + numero2;
    print(resultado);
  }

  if (operador == '-') {
    resultado = numero1 - numero2;
    print(resultado);
  }
  if (operador == '*') {
    resultado = numero1 * numero2;
    print(resultado);
  }
}
